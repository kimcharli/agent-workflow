# Project

## What this is

The source of truth for a portable agentic-development framework that is **copied** into
consuming repositories — not imported, not vendored, not a submodule. Each consumer commits
its own copy, so an agent opening that repository finds the contract already present with
no setup step, and can edit the per-repo parts freely.

This repository is also an instance of the framework. Its own `AGENTS.md` and `specs/` are
live, not samples.

## Layout

| Path | Layer | What it is |
| --- | --- | --- |
| `AGENTS.md` | portable | The contract. Simultaneously this repo's live copy and the artifact consumers copy. |
| `specs/` | per-repo | This repository's own content. Not copied anywhere. |
| `template/specs/` | portable | The skeletons a consumer starts from: format rules, no content. |
| `scripts/agent-workflow-check.sh` | portable | All checks. POSIX sh, no toolchain. |
| `.github/workflows/agent-workflow.yml` | portable | Runs the check script. |
| `docs/framework.md` | portable | The two-layer model, the improvement loop, install and upgrade. |
| `.github/ISSUE_TEMPLATE/` | this repo | Intake for friction reported from a consuming repository. |

`AGENTS.md` and `specs/` exist once each and are never copies of each other; see
`specs/decisions.md` for why that is safe.

## Verification

| Command | Proves |
| --- | --- |
| `sh scripts/agent-workflow-check.sh` | Referenced paths resolve, `AGENTS.md` is within its line budget, the portable layer is free of repo-specific content, and `template/specs/` and `specs/` still hold the same files. |

There is nothing else to run. The framework has no build, no dependencies, and no language
toolchain, and it must stay that way — consumers are in many languages and a check they
cannot run is a check they will delete.

## Conventions

- Documentation states the reason alongside the rule. A rule whose reason is not written
  down is a rule that gets deleted by the next person who finds it inconvenient.
- Prefer fewer, denser files. The framework's own thesis is that instruction nobody reads is
  worse than none, so a growing pile of markdown here is evidence of a design error, not of
  progress.
- The check script is POSIX `sh`. No bashisms, no `find -printf`, no GNU-only flags.

## Boundaries

- Nothing in this repository may name any specific consumer, employer, or private project.
  The genericity gate catches the mechanical part of this; the rest is on review.
- The portable layer is copied verbatim into repositories this project cannot see. Treat
  every line in it as something that has to be true elsewhere.
- This repository has no configuration and needs no credentials. If that ever changes, it is
  a design failure worth reversing rather than documenting.
