# agent-workflow

A portable contract that tells any AI coding agent how to work in your repository, and a
loop that improves that contract from ordinary work. For anyone who works with AI agents on
a codebase and is tired of re-explaining the same thing every session.

You copy it into your repository and commit it. There is no package, no submodule, and no
init step — an agent opening the repo finds everything it needs already there.

## What you get

- **`AGENTS.md`** — one tool-neutral file, capped at 150 lines, saying what to read first,
  how to report, when to ask, and what "done" means. Any agent can use it; none is
  required.
- **`specs/`** — five short files that hold what your repo actually needs remembered:
  what's next, how the project works, decisions and the constraints behind them, proposed
  improvements, deferred work.
- **Three CI checks** — POSIX shell, no toolchain, that stop the contract rotting: paths
  that dangle, a file that grows past the point anyone reads it, repo-specific detail
  leaking into the portable parts.

## Install

See [`docs/framework.md`](docs/framework.md#installing). Roughly: copy `AGENTS.md`, the
`template/specs/` skeletons, the check script and the workflow; fill in `specs/project.md`
and `specs/NEXT.md`; run the check; commit.

## The idea

Two layers. This repository owns the **portable** one — `AGENTS.md`, the structure of
`specs/`, the checks. Your repository owns the **per-repo** one — the contents of `specs/`.
The boundary has one test: *would this sentence be wrong in someone else's repo?* If yes,
it is yours, not the framework's.

The contract then improves from being used. When a human corrects an agent, the correction
gets logged; when the same correction happens twice, it becomes a proposal; proposals are
resolved by preference for turning the rule into a check and deleting the prose, and only
as a last resort by adding another rule. The 150-line cap is what makes that ordering
matter — at the cap, adding lines means naming what you delete to pay for them.

And it is shared for a reason: one repository generates a few friction events a month,
which is far too slow for any of this to converge. Pooled across many, it is fast enough to
actually get better. A lesson from one repo waits until a second repo hits the same thing
before it becomes everyone's rule.

Full reasoning in [`docs/framework.md`](docs/framework.md).

## Status

v1. Used by this repository on itself — its own `AGENTS.md` and `specs/` are live, not
samples. Not yet used anywhere else, so the cross-repo half of the design is untested.

## Contributing

Friction from a repository using the framework is the point of the whole thing — open a
friction report. Please don't include anything from a private repository: promotion carries
structure and reasoning upward, never content.
