# Improvements

## Output Discipline is the largest unenforceable block in the contract

Status: Watching
First seen: 2026-07-26
Struck: —

Friction: the Output Discipline section is the biggest single block in `AGENTS.md` and
none of it is checkable. Nothing can verify that an agent stayed silent between tool calls
or kept to the prose budget, and specific tools ship their own output styling that may
override it outright. By the contract's own resolution order, a rule that is enforced by
nothing and ignored repeatedly is decoration.

Proposal: if this section is observably not followed, cut it to the parts that change
outcomes rather than tone — edit-never-rewrite, the risk lines, and the closing shape —
and delete the rest.

Resolution: none yet. Recorded at the point the section was written, because the objection
was raised and overruled during design, and an objection that is not written down is
re-raised from scratch later.

Retires when: the section has been used across at least two repositories and is either
followed or cut.

## `backlog.md` may not earn a fifth spec file

Status: Watching
First seen: 2026-07-26
Struck: —

Friction: five spec files is a lot for a framework whose thesis is that unread instruction
is worse than none. `backlog.md` is the weakest of the five — deferred work is a real
category, but in practice it may collect the same entries as `improvements.md` and be read
as rarely.

Proposal: merge deferred work into `specs/decisions.md` as entries with a revisit
condition, and delete `backlog.md`.

Resolution: none yet. Kept for v1 because the distinction is genuine and the file is cheap;
flagged because "cheap and genuine" is how every file that nobody reads got added.

Retires when: a repository has used the framework long enough to show whether the file gets
opened.

## The line budget caps only one of the every-session reads

Status: Watching
First seen: 2026-07-26
Struck: —

Friction: the check counts lines in `AGENTS.md` and nothing else, but `specs/NEXT.md` and
`specs/project.md` are read every session too. Under budget pressure, rules migrate out of
the capped file into the uncapped ones and the ratchet quietly stops working while still
reporting success.

Proposal: currently prose only — `AGENTS.md` states that the Start Here files spend from
the same budget, and both templates carry a brevity instruction. If migration happens
anyway, mechanize it: check the combined length of the every-session reads instead of
`AGENTS.md` alone.

Resolution: none yet. A hard line cap on per-repo content was rejected outright — an
arbitrary number imposed on someone else's project documentation is the kind of rule
consumers delete, taking the rest of the check script with it.

Retires when: a check counts the every-session reads together, or the migration is observed
not to happen.
