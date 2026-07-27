#!/bin/sh
# agent-workflow checks. POSIX sh, no language toolchain required.
# Run from the repository root: sh scripts/agent-workflow-check.sh
#
# 1. referenced paths resolve
# 2. AGENTS.md line budget
# 3. genericity gate over the portable layer
# 4. template/instance parity (only where a template/ directory exists)
#
# Scope note for check 3: the gate reads AGENTS.md and template/ ONLY. It does not
# read docs/, specs/ or scripts/. Documentation has to be able to spell out the
# patterns the gate forbids, and a repository's own specs/ may legitimately name
# hosts and addresses -- that is configuration, not a portability defect.

set -u

LINE_BUDGET=150
status=0

fail() {
	printf 'FAIL %s\n' "$1" >&2
	status=1
}

pass() {
	printf 'ok   %s\n' "$1"
}

if [ ! -f AGENTS.md ]; then
	fail "AGENTS.md not found. Run this from the repository root."
	exit 1
fi

# --- 1. referenced paths resolve -------------------------------------------
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

# --- 2. line budget ---------------------------------------------------------
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

# --- 3. genericity gate -----------------------------------------------------
# The portable layer is copied verbatim into every consuming repository. The test
# for whether a sentence belongs here is: would it be wrong in someone else's
# repo? Intent decays, so the mechanical part of that test lives here.

portable="AGENTS.md"
if [ -d template ]; then
	for f in $(find template -type f 2>/dev/null | sort); do
		portable="$portable $f"
	done
fi

ipv4_re='(^|[^0-9A-Za-z.])[0-9]{1,3}(\.[0-9]{1,3}){3}([^0-9A-Za-z.]|$)'
cred_re='(password|passwd|token|secret|api[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]]'

hits=""
for f in $portable; do
	h=$(grep -nE "$ipv4_re" "$f" 2>/dev/null | sed "s|^|  $f:|")
	[ -n "$h" ] && hits="$hits
$h"
	h=$(grep -niE "$cred_re" "$f" 2>/dev/null | sed "s|^|  $f:|")
	[ -n "$h" ] && hits="$hits
$h"
done

if [ -n "$hits" ]; then
	fail "portable layer contains repo-specific or credential-shaped content:$hits
     The portable layer is copied into every consuming repository. If a line
     would be wrong in someone else's repo, it belongs in specs/ instead."
else
	pass "genericity gate"
fi

# --- 4. template/instance parity -------------------------------------------
# This repository is both the template and an instance of it. That is only safe
# while the two stay structurally identical, so adding a spec file to one side
# without the other has to fail here rather than drift quietly.

if [ -d template/specs ] && [ -d specs ]; then
	a=$(cd template/specs && ls *.md 2>/dev/null | sort)
	b=$(cd specs && ls *.md 2>/dev/null | sort)
	if [ "$a" != "$b" ]; then
		fail "template/specs/ and specs/ hold different files.
     template/specs: $(echo "$a" | tr '\n' ' ')
     specs:          $(echo "$b" | tr '\n' ' ')"
	else
		pass "template/specs and specs agree"
	fi
fi

exit "$status"
