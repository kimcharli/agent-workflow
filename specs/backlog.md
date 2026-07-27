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

## Automated friction logging script for agent self-correction

Deferred: 2026-07-26
Area: `scripts/`, `specs/proposals.md`, `AGENTS.md`
Why not now: Requires standardizing the error formats agents produce and ensuring agents can reliably execute the logging script without getting stuck in a loop. Manual logging is sufficient while the user base is small.
Revisit when: The manual friction logging process becomes a bottleneck, or when agents consistently demonstrate the ability to self-diagnose and log their own execution errors upon human interruption.

## LLM-optimized strict context boundaries in spec files

Deferred: 2026-07-26
Area: `template/specs/`
Why not now: Current prose-heavy markdown is still highly readable for humans and hasn't explicitly broken agent context windows across multiple repositories yet. Adding strict XML-style tags or rigid heading hierarchies might reduce the natural readability of the contract.
Revisit when: Agents consistently conflate context (e.g., confusing deferred backlog tasks with active architectural requirements) while scanning across the multiple spec files.

## Shift agent-workflow CI checks to local Git pre-commit hooks

Deferred: 2026-07-26
Area: `scripts/`, local `.git/hooks/`
Why not now: It introduces a dependency on local git configuration and might disrupt human developers' workflows if they aren't accustomed to strict local commit hooks rejecting their work. 
Revisit when: Remote CI pipeline failures (caused by agents bloating `AGENTS.md` past the line cap) become frequent enough that the delayed feedback loop is noticeably slowing down development.

## Lightweight synchronization script for upstream framework distribution

Deferred: 2026-07-26
Area: `scripts/sync-workflow.sh`, `agent-workflow.manifest`
Why not now: Until multiple consumer repositories adopt the framework and actually attempt to pull upstream improvements, the exact friction points of the "copy and commit" model are unknown. Building a sync tool now would be premature optimization based on assumptions.
Revisit when: Two or more repositories are using the framework and need to seamlessly pull a new release, or when a consumer wants to easily push a generalized framework fix back upstream without git history conflicts.
