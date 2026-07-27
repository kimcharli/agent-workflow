# Backlog

## Automated upgrade and drift detection for consumers

Deferred: 2026-07-26
Area: `scripts/`, `docs/framework.md`
Why not now: no second repository has installed the framework, so there is nothing to
upgrade and no evidence about what upgrading is actually like. A tool built now would be
built against guesses, and would become a second thing to version.
Revisit when: two or more repositories are on the framework and a release has shipped that
they need to take.

## A check that counts the every-session reads together

Deferred: 2026-07-26
Area: `scripts/agent-workflow-check.sh`
Why not now: it would impose a line cap on per-repo content, which is the kind of rule a
consumer deletes — and deleting it means deleting the script that carries the other checks.
The prose mitigation may be enough.
Revisit when: rules are observed migrating out of `AGENTS.md` into `specs/project.md` to
duck the budget. Tracked in `specs/improvements.md`.
