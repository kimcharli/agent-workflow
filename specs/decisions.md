# Decisions

## The framework is copied into consumers, not depended on

Date: 2026-07-26

Consuming repositories commit their own copy of the portable layer. There is no package,
no submodule, and no install step that must run before the contract works.

Why: an agent opening a repository has to find its instructions already present. Anything
that requires a fetch or an init is a step that will not have happened at the moment it
matters, and the failure is silent — the agent simply works without the contract. Copying
also lets each repository edit the per-repo half freely, which a dependency would not.

## `AGENTS.md` is one file serving as both template and instance

Date: 2026-07-26

There is no `template/AGENTS.md`. The file at the root of this repository is
simultaneously this repository's live contract and the artifact consumers copy.

Why: `AGENTS.md` is repo-agnostic by construction — that is what the genericity gate
enforces — so a separate template copy would be byte-identical and would immediately start
drifting. Keeping one file also makes the dogfooding real rather than ceremonial: if the
portable contract were wrong for this repository, it would be wrong everywhere.

## `specs/` contents are per-repo, so the skeletons live in `template/specs/`

Date: 2026-07-26

`specs/*.md` in this repository hold real content about this repository. The skeletons a
consumer starts from are separate files under `template/specs/`, containing format rules
and no example content.

Why: the two files genuinely differ — one is a format contract, the other is content — so
this is not duplication. What is shared is only the set of filenames, and drift there is
real, so the check script asserts the two directories hold the same files. Shipping
skeletons with example content was rejected: examples get left in place and then read as
if they were true.

## The genericity gate has a declared scope

Date: 2026-07-26

The gate reads `AGENTS.md` and `template/` only. It does not read `docs/`, `specs/`, or
`scripts/`.

Why: two separate reasons, both fatal without the exclusion. The documentation of the gate
has to be able to spell out the patterns the gate rejects, so scanning `docs/` makes the
check fail on its own explanation. And a consumer's `specs/` may legitimately name hosts
and addresses — the boundary sorts specificity, not sensitivity, and configuration in the
per-repo layer is exactly where it belongs.

## The version marker lives in `AGENTS.md`

Date: 2026-07-26

Consumers record their framework version as an HTML comment on the last line of
`AGENTS.md`: `<!-- agent-workflow: v1.0.0 -->`.

Why: it travels with the artifact it versions and therefore cannot drift from it, it costs
no extra file, and it survives the copy that installs the framework. A separate version
file was rejected because it can be updated without the file it describes changing, and
the reverse, which makes it worse than no marker.

## Upgrade in v1 is a documented procedure, not a tool

Date: 2026-07-26

Upgrading means diffing the tagged portable layer against the consumer's copy by hand, as
described in `docs/framework.md`. Drift detection is the same diff read in the other
direction. No tooling ships.

Why: no second repository exists yet. An upgrade tool built now would be built against
imagined requirements, and would itself become something to maintain and version. The
marker plus a documented diff is enough to know what you are on and what changed, which is
the whole requirement until upgrades are frequent enough to be annoying.

## Cross-repo promotion is human-mediated by necessity

Date: 2026-07-26

A lesson is promoted into the portable layer only after the same friction appears in a
second repository, and the promotion is a human retyping the lesson through the
friction-report issue template.

Why: consumers are typically private while this repository is public, and promotion may
carry structure and reasoning but never content. That rules out any automated path by
construction, so the honest design is a small intake form rather than a mechanism that
cannot exist. The second-repository requirement is what stops one repository's quirk
becoming everyone's rule.

## The portable layer is enumerated in a manifest

Date: 2026-07-26

`agent-workflow.manifest` at the root names every path in the portable layer, whether it is
copied verbatim or is a skeleton the consumer then owns, and where it lands. The check
script reads it instead of globbing, including for the genericity gate's scope — which
resolves to the same set as before, now declared rather than hardcoded.

Why: any tool that installs or upgrades the framework must not hardcode paths, because a
hardcoded list breaks silently every time the framework gains a file — the install
succeeds and the consumer is quietly missing something. Having the check script read the
same file is what stops the manifest being a second copy of information that already
exists; it makes the manifest the only copy. The verbatim/skeleton distinction is the part
an upgrader actually needs: it is the machine-readable statement of which files the
framework may replace and which belong to the consumer.

## The framework is MIT licensed

Date: 2026-07-26

MIT, with the notice recorded in `LICENSE`.

Why: this repository's entire purpose is being copied into other people's repositories, and
without a license nobody may legally do that. An unlicensed repository is not permissively
licensed by default — it is the most restrictive state there is, which would make the
framework unusable for exactly its intended use.

## Delivery tooling lives outside this repository

Date: 2026-07-26

Installing, upgrading, and filing friction upstream are expected to be done by tooling that
lives elsewhere. This repository ships none of it. What it does ship is the surface that
tooling depends on — the manifest, a greppable version marker, byte-identical verbatim
files, and an issue form with stable field ids — documented in `docs/framework.md`.

Why: a delivery tool has its own release cycle, its own dependencies, and its own hosting
requirements, none of which the framework should acquire. Keeping it out preserves the
property that the framework needs no toolchain at all. The requirement this places on v1 is
only that the portable layer be mechanically identifiable, which the manifest satisfies
without any tool existing yet. Designing the artifacts for a tool is cheap; building the
tool before a second repository exists is building against guesses.
