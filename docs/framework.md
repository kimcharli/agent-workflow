# The framework

Design notes for `agent-workflow`: what the two layers are, how the improvement loop works,
how lessons move between repositories, and how to install and upgrade. For the contract
itself, read [`AGENTS.md`](../AGENTS.md).

## The two-layer model

Everything in a repository using this framework is in one of two layers.

| | Portable layer | Per-repo layer |
| --- | --- | --- |
| Owned by | this repository | the consuming repository |
| Contains | `AGENTS.md`, the *structure* of `specs/`, the checks, the manifest | the *contents* of `specs/` |
| On install | copied largely unchanged | filled in from the skeletons |
| On upgrade | replaced from a newer tag | never touched |

The boundary has a single test:

> **Would this sentence be wrong in someone else's repository?**

If yes, it is per-repo. That is all. Genericity is definitional here rather than a policy
bolted on afterwards, which is why the portable layer contains no addresses, hostnames,
organisation names, domain jargon, language- or tool-specific commands, or paths outside
`specs/` — not because each of those is separately banned, but because each would fail the
test.

One consequence worth stating, because it is easy to misread: **the boundary sorts
specificity, not sensitivity.** A hostname in a consumer's `specs/project.md` is fine — it
is configuration, and configuration is exactly what the per-repo layer is for. A committed
plaintext credential is a defect in any repository, and nothing about this boundary makes
it acceptable in the per-repo layer. The two axes are unrelated; the check script rejects
credential-shaped content in the portable layer because it would also be *specific*, not
because the per-repo layer is a safe place for it.

## The manifest

`agent-workflow.manifest` at the repository root enumerates the portable layer: every
path that ships, whether it is copied **verbatim** or is a **skeleton** the consumer then
owns, and where it lands in a consuming repository.

It exists so that nothing installing or upgrading the framework has to hardcode a path.
Hardcoded lists break silently every time the framework gains a file — the installer
succeeds, and the consumer is simply missing something nobody notices until it matters.

It is not an extra file for its own sake: `scripts/agent-workflow-check.sh` reads it too,
for the genericity gate's file list and for checking that the declared shape matches what
is on disk. The paths are declared once, in one place, rather than repeated across a check
script and a tool.

The `verbatim` / `skeleton` distinction is what makes mechanical upgrade possible at all.
Verbatim entries are replaced wholesale on upgrade. Skeleton entries are copied once and
never touched again — they become the consumer's `specs/`, which is the per-repo layer and
therefore not the framework's to overwrite.

The manifest is itself portable, so it travels into consumers. Skeleton *sources* live
under `template/`, which does not, so a tool reading the manifest in a consuming repository
must expect source paths to be absent while destination paths are present.

## The improvement loop

The loop's premise is that ordinary work already produces the signal. There is no separate
benchmarking or evaluation exercise, because an evaluation exercise is a thing that gets
skipped.

**Capture on correction.** The strongest available signal is a human correcting the agent,
appended to `specs/improvements.md` in the turn it happens. Asking an agent to notice its
own ambiguity is the weakest possible sensor — if it knew it was guessing it would have
asked. And capturing later loses the reason, which is the only part not recoverable from
the diff.

**Two strikes.** A first occurrence is `Watching`; a second promotes it to `Proposed`.
Severe items may open at `Proposed` with a stated reason. The point is to make "the same
correction twice" observable rather than a matter of someone's impression.

**Resolution order**, strictly preferred:

1. **Mechanize and delete** — turn the rule into a CI step, test, or code guard, then
   remove the prose. The only resolution that shrinks the file while increasing
   enforcement.
2. **Rewrite** the rule.
3. **Delete** the rule. One repeatedly ignored and enforceable by nothing is decoration.
4. **Add** a rule. Last resort: the only option that makes the file longer.

**The budget is the ratchet.** `AGENTS.md` has a hard 150-line cap enforced in CI. At the
cap, a proposal that adds lines must name what it deletes or merges to pay for them. Every
other part of the loop pushes toward more instruction; the cap is the only thing pushing
back. Without it the file grows until nobody reads it, which costs more than any rule in it
saves.

**Retirement.** A proposal that adds a rule must say what would make it removable — usually
"when a check enforces this". Rules that cannot state this tend to be permanent by
accident.

**Review on pull request**, and whenever a human asks. Never on a calendar: a scheduled
review is one nobody does. Review is also the only thing that removes stale `Watching`
entries, which matters — a file of entries nobody recognises is the exact failure the loop
exists to prevent.

## Cross-repo improvement

This is the reason the framework is shared at all rather than living in one repository.

A single repository produces a handful of friction events a month. That is far too slow for
a feedback loop to converge on anything. Pooled across many repositories, the signal rate
becomes high enough that the framework can actually improve.

The two-strike rule applies again, one level up:

- A lesson learned in one repository is `Watching` **at framework level**.
- When the same friction fires in a **second** repository, it is promoted into the portable
  layer.

That second-repository requirement is what stops one repository's quirk becoming everyone's
rule.

**Promotion carries structure and reasoning upward, never content.** If an improvement
cannot be phrased without naming something specific to one repository, then by definition
it is a local lesson and belongs in that repository's `specs/`.

Because consuming repositories are usually private and this one is public, no automated
promotion path can exist — the promotion is a human restating the lesson in portable terms.
The intake is the friction-report issue template on this repository, which asks for the
friction, the proposed portable rule, and confirmation that a second repository hit it, and
deliberately provides nowhere to name a repository.

## Installing

Copy the portable layer, driven by the manifest rather than by a hardcoded list:

```sh
git clone https://github.com/kimcharli/agent-workflow /tmp/agent-workflow
cd /path/to/your/repo

sed 's/#.*//' /tmp/agent-workflow/agent-workflow.manifest |
	grep -v '^[[:space:]]*$' |
	while read -r kind src dest flags; do
		# never overwrite a skeleton the repository already owns
		[ "$kind" = skeleton ] && [ -e "$dest" ] && continue
		mkdir -p "$(dirname "$dest")"
		cp "/tmp/agent-workflow/$src" "$dest"
	done
```

Then fill in `specs/project.md` — its **Verification** section especially, since
`AGENTS.md` defines "done" by pointing at that heading by name — and write the first
`specs/NEXT.md`. Delete the guidance comments from each skeleton as you fill it in.

Confirm the install, and commit:

```sh
sh scripts/agent-workflow-check.sh
```

Note what does **not** get copied: `template/` itself, `docs/`, and the issue template.
Consumers hold the framework, not the framework's own source of truth.

The framework is MIT licensed, which is what makes copying it into your repository legal
as well as intended. MIT asks that the notice travel with copies; the least intrusive way
to honour that is a line crediting `agent-workflow (MIT)` in your `specs/project.md` or a
`NOTICE` file. Do not copy this repository's `LICENSE` over your own.

## Versioning and upgrading

The framework is versioned with semver and tagged in this repository. A consumer records
what it is on as the last line of its `AGENTS.md`:

```
<!-- agent-workflow: v1.0.0 -->
```

Rough semantics: **patch** for wording, **minor** for a new rule or check, **major** for
anything that requires a consumer to change its `specs/` — a renamed spec file or a
renamed heading the contract depends on.

To upgrade, read the marker, then read the delta and apply it by hand. The manifest tells
you which paths are in scope, and which of them an upgrade may touch at all — `verbatim`
entries are replaceable, `skeleton` entries are the consumer's and are not:

```sh
cd /tmp/agent-workflow && git fetch --tags
git diff v1.0.0 v1.1.0 -- $(sed 's/#.*//' agent-workflow.manifest |
	grep -v '^[[:space:]]*$' | awk '$1 == "verbatim" { print $2 }')
```

To check whether a consumer has locally edited its portable layer — worth knowing before
you overwrite it — diff the other way:

```sh
diff /tmp/agent-workflow/AGENTS.md /path/to/your/repo/AGENTS.md
```

Local edits to the portable layer are not forbidden, but they are a signal: an edit that
would be right in every repository should be proposed upstream instead, and one that would
not be right elsewhere probably belongs in `specs/`.

v1 ships no upgrade tooling on purpose. See `specs/decisions.md` for the reasoning and
`specs/backlog.md` for the condition that would revisit it.

## Stability guarantees for external tooling

Delivery tooling is expected to live elsewhere — a skill or action that opens a **pull
request** against a consuming repository to install or upgrade, so the review gate lands on
the PR and local edits to the portable layer surface as diff conflicts rather than being
silently overwritten. The same tooling is expected to run in reverse, reading a consumer's
`specs/improvements.md` and filing a scrubbed, repository-anonymous friction report here.

None of that belongs in this repository. What this repository owes such a tool is that the
things it depends on do not move without a major version:

| Surface | Guarantee |
| --- | --- |
| `agent-workflow.manifest` | Path, column order (`kind source dest flags`), and the `verbatim` / `skeleton` values are stable. New flags may be added; unknown flags must be ignored, not treated as errors. |
| Version marker | Exactly `<!-- agent-workflow: vX.Y.Z -->` on the last line of `AGENTS.md`. Greppable with a fixed pattern. |
| Drift detection | A consumer's `verbatim` entries are byte-identical to the tagged originals unless locally edited, so a plain `diff` is sufficient and no normalisation is needed. |
| Friction report intake | The field `id`s in `.github/ISSUE_TEMPLATE/friction-report.yml` — `friction`, `rule`, `strikes`, `cheaper`, `retires` — are stable so a tool can populate the form. There is deliberately no field for a repository, organisation, or person name: the form cannot be used to carry consumer content upward even by accident. |
| Check script | Runs from the repository root, no arguments, exits non-zero on any failure. Safe to use as the gate on a generated pull request. |

The manifest's `skeleton` kind is the load-bearing part for an upgrader: it is the machine-
readable statement of which files the framework may replace and which belong to the
consumer. An upgrade that touches a `skeleton` destination is a bug.

## The checks

`scripts/agent-workflow-check.sh` is POSIX shell with no dependency on any language
toolchain, because consumers are in many languages and a check they cannot run is a check
they will delete. Every file list it uses comes from the manifest.

1. **The manifest describes reality.** Fails if a declared path is missing, an entry is
   malformed, or a file exists in `specs/` or `template/specs/` without being declared.
   The manifest is load-bearing for anything that installs or upgrades the framework, and a
   wrong entry there fails in someone else's repository rather than in this one. This also
   subsumes template/instance parity: adding a skeleton without a live spec, or the
   reverse, fails here.
2. **Referenced paths resolve.** Fails if `AGENTS.md` or any spec file names a `specs/` or
   `docs/` file that does not exist. This is not hypothetical: it is motivated by an agent
   contract shipped with every path dangling, which silently disabled every rule that
   depended on them and which nothing else would ever have caught.
3. **Line budget.** Fails if `AGENTS.md` exceeds 150 lines, with an error naming the
   ratchet, since an error that only reports a number invites raising the number.
4. **Genericity gate.** Fails on IPv4 literals or credential-shaped assignments in the
   portable layer. Intent decays; this is what keeps the layer generic in practice rather
   than aspirationally. Scope is the manifest entries flagged `gate`, and applies to
   sources only — a destination in a consuming repository is per-repo content, where a
   hostname is configuration rather than a defect.

## Dogfooding

This repository uses the framework on itself: its `AGENTS.md` and `specs/` are live, not
samples. The template and the instance coexist without duplication because they are
different things, not two copies of one thing — `AGENTS.md` is repo-agnostic by
construction and so needs no template variant, while `specs/` contents are repo-specific by
construction and so share only filenames with the skeletons. The parity check pins that one
shared thing. `specs/decisions.md` records the reasoning.
