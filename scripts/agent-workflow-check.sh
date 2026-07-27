#!/bin/sh
# agent-workflow checks. POSIX sh, no language toolchain required.
# Run from the repository root: sh scripts/agent-workflow-check.sh
#
# 1. the manifest describes reality
# 2. referenced paths resolve
# 3. AGENTS.md line budget
# 4. genericity gate over the portable layer
#
# The set of files each check looks at comes from agent-workflow.manifest, so paths
# are declared once. Nothing here hardcodes a portable-layer path.

set -u

MANIFEST=agent-workflow.manifest
LINE_BUDGET=150
status=0

fail() {
	printf 'FAIL %s\n' "$1" >&2
	status=1
}

pass() {
	printf 'ok   %s\n' "$1"
}

if [ ! -f AGENTS.md ] || [ ! -f "$MANIFEST" ]; then
	fail "AGENTS.md or $MANIFEST not found. Run this from the repository root."
	exit 1
fi

rows=$(mktemp) || exit 1
trap 'rm -f "$rows"' EXIT INT TERM
sed 's/#.*//' "$MANIFEST" | grep -v '^[[:space:]]*$' > "$rows"

# --- 1. the manifest describes reality --------------------------------------
# The manifest is load-bearing for anything that installs or upgrades the framework,
# and a wrong entry there fails silently in someone else's repository rather than here.

sources=""
dests=""
problems=""

while read -r kind src dest flags; do
	case "$kind" in
		verbatim|skeleton) ;;
		*) problems="$problems
  unknown kind '$kind' for '$src'"; continue ;;
	esac
	if [ -z "${dest:-}" ] || [ -z "${flags:-}" ]; then
		problems="$problems
  malformed entry for '$src' (expected: kind source dest flags)"
		continue
	fi
	# Skeleton sources live under template/ and are absent in a consuming repository.
	if [ ! -e "$src" ] && { [ "$kind" = verbatim ] || [ -d template ]; }; then
		problems="$problems
  declared source is missing: $src"
	fi
	[ -e "$dest" ] || problems="$problems
  declared destination is missing: $dest"
	sources="$sources
$src"
	dests="$dests
$dest"
done < "$rows"

# Every live spec must be declared, or this repository grows a spec file that no
# consumer ever receives.
for f in specs/*.md; do
	[ -e "$f" ] || continue
	echo "$dests" | grep -Fxq "$f" || problems="$problems
  not declared in $MANIFEST: $f"
done

if [ -d template ]; then
	for f in template/specs/*.md; do
		[ -e "$f" ] || continue
		echo "$sources" | grep -Fxq "$f" || problems="$problems
  not declared in $MANIFEST: $f"
	done
fi

if [ -n "$problems" ]; then
	fail "$MANIFEST disagrees with the repository:$problems"
else
	pass "manifest describes the repository"
fi

# --- 2. referenced paths resolve -------------------------------------------
# An agent contract whose paths dangle silently disables every rule that depends
# on them, and nothing else in the repository will ever notice.

scan_files=""
for f in AGENTS.md specs/*.md template/specs/*.md; do
	[ -f "$f" ] && scan_files="$scan_files $f"
done

missing=""
for f in $scan_files; do
	refs=$(grep -oE '(specs|docs)/[A-Za-z0-9_.-]+\.md' "$f" 2>/dev/null | sort -u)
	for ref in $refs; do
		if [ ! -f "$ref" ]; then
			missing="$missing
  $f -> $ref"
		fi
	done
done

if [ -n "$missing" ]; then
	fail "referenced paths do not resolve:$missing"
else
	pass "referenced paths resolve"
fi

# --- 3. line budget ---------------------------------------------------------
# The budget is the ratchet. Every other part of the improvement loop pushes
# toward more instruction; this is the only thing pushing back.

lines=$(wc -l < AGENTS.md | tr -d ' ')
if [ "$lines" -gt "$LINE_BUDGET" ]; then
	fail "AGENTS.md is $lines lines, over the $LINE_BUDGET line budget.
     The budget is the ratchet: at the cap, anything that adds lines must name
     what it deletes or merges to pay for them. Cut before you add."
else
	pass "AGENTS.md is $lines/$LINE_BUDGET lines"
fi

# --- 4. genericity gate -----------------------------------------------------
# The portable layer is copied verbatim into every consuming repository. The test
# for whether a sentence belongs here is: would it be wrong in someone else's
# repo? Intent decays, so the mechanical part of that test lives here.
#
# Scope comes from the 'gate' flag in the manifest, and applies to sources only.

ipv4_re='(^|[^0-9A-Za-z.])[0-9]{1,3}(\.[0-9]{1,3}){3}([^0-9A-Za-z.]|$)'
cred_re='(password|passwd|token|secret|api[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]]'

hits=""
gated=0
while read -r kind src dest flags; do
	case ",${flags:-}," in *,gate,*) ;; *) continue ;; esac
	[ -f "$src" ] || continue
	gated=$((gated + 1))
	h=$(grep -nE "$ipv4_re" "$src" 2>/dev/null | sed "s|^|  $src:|")
	[ -n "$h" ] && hits="$hits
$h"
	h=$(grep -niE "$cred_re" "$src" 2>/dev/null | sed "s|^|  $src:|")
	[ -n "$h" ] && hits="$hits
$h"
done < "$rows"

if [ -n "$hits" ]; then
	fail "portable layer contains repo-specific or credential-shaped content:$hits
     The portable layer is copied into every consuming repository. If a line
     would be wrong in someone else's repo, it belongs in specs/ instead."
else
	pass "genericity gate over $gated file(s)"
fi

exit "$status"
