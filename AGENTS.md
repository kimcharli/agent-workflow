# AGENTS.md

The contract for any AI agent working in this repository. Tool-neutral and canonical.

## Start Here

Read these two, in order, at the start of every session. They are short by design.

1. `specs/NEXT.md` — what is actually next. Session todo lists do not survive the
   session; this file is the handoff that does.
2. `specs/project.md` — layout, conventions, and the commands that verify a change.

Read on request, or when work lands in something they cover. Never by default:

- `specs/decisions.md` — durable facts and the constraints behind them.
- `specs/improvements.md` — proposed changes to this contract.
- `specs/backlog.md` — work that was deferred on purpose.

## Output Discipline

**Edit, never rewrite.** Change files by anchoring on the smallest unique string that
identifies the spot. Write a file whole only when creating it. A rewrite that reproduces
unchanged lines hides the real change inside noise and risks losing work you did not read.

**Work silently.** No prose between tool calls, no preamble, no announcing what you are
about to do. Narration of work in progress has a budget of roughly one short line per
distinct phase, and zero is usually right.

**Say what is risky.** Up to three lines for anything that could bite: a guess you made,
something you could not verify, a side effect outside the stated scope. Brevity never
applies here. Silence about a risk is the one failure that cannot be caught by reading
the diff.

**Close in a fixed shape**, risk lines first, then:

```
<file>: <n> lines changed
<verification command> -> <result>
```

Nothing after it. No summary of the summary, no offer of next steps.

The budget governs narration of work. It does not govern answering a question — when the
user asked for an explanation, the explanation is the deliverable, so give a real one.

## Execution Rules

**Change only what the task requires.** Fix a neighbouring bug only when the change you
are making causes it or depends on it. Unrelated cleanup is a separate request.

**Decide, then note the assumption.** For anything reversible, pick the reasonable option
and state the assumption in the closing report. Ask only when the choice is expensive to
undo, or when two specs contradict each other — that contradiction is the real bug and it
needs a human, not a guess.

**Done means verified.** A change is done when every command in the Verification section
of `specs/project.md` passes and you ran it yourself in this session. Not when the code
looks right, not when it passed before your edit.

**Verify, do not assert.** Never report a result you did not observe. "Should work" is not
a result. If you could not run something, say so in the risk lines.

**Match what is already there.** Follow the surrounding file's patterns even where you
would have chosen differently. Consistency is worth more than your preference.

**Leave the handoff current.** If your work changed what should happen next, update
`specs/NEXT.md` before you finish. The next session starts from that file and nothing else.

**Commit** in coherent units with a message saying why, not what — the diff already says
what. Do not commit unrelated changes together, and never commit a secret.

## Durable Facts

`specs/decisions.md` is the only place durable facts are kept. It is committed, so it
survives a fresh clone and reaches whoever works here next.

Do not start a second memory file, and do not rely on any memory your tool keeps
privately. A fact only one tool can see does not exist for the next agent or the next
human.

Record a decision when a choice constrains future work. Always record the constraint that
forced it — a decision without its reason gets relitigated the first time it is
inconvenient, and the reason is the one part that cannot be recovered from the diff.

## Improvement Proposals

This contract improves from ordinary work. There is no separate review exercise.

**Capture when corrected.** When a human corrects you, append the correction to
`specs/improvements.md` in the same turn, while the reason is still known. Do not wait to
be asked, and do not rely on noticing your own ambiguity — if you had known you were
guessing, you would have asked.

**Two strikes.** A first occurrence is logged `Watching`. A second, from any cause,
promotes it to `Proposed`. Something clearly severe may open at `Proposed` if the entry
says why. This is what makes "that happened twice" a fact rather than an impression.

**Resolve in this order**, and prefer earlier ones:

1. **Mechanize and delete.** Turn the rule into a check, test, or guard, then remove the
   prose. The only resolution that makes this file shorter and the rule stronger at once.
2. **Rewrite** the rule that was misread.
3. **Delete** it. A rule ignored repeatedly and enforced by nothing is decoration.
4. **Add** a rule. Last resort — the only option that makes this file longer.

**The budget is the ratchet.** This file has a hard line cap, enforced by a check. At the
cap, a proposal that adds lines must name what it deletes or merges to pay for them. Every
other part of this loop pushes toward more instruction; the cap is the only thing pushing
back. Without it the file grows until nobody reads it, which costs more than any rule in
it saves. The files under Start Here share that pressure: they are read every session too,
so length there is spent from the same budget even though no check counts it.

**Say what would retire it.** A proposal that adds a rule must state what would make it
removable — usually "when a check enforces this".

**Review on pull request**, and whenever a human asks. Never on a schedule; a review on
the calendar is a review nobody does. At review, drop any `Watching` entry you no longer
recognise as real friction. Nothing else removes them, and a file of stale entries is the
exact failure this loop exists to prevent.

## Standing Principles

**Agent-agnostic.** Any AI coding tool should be able to work from this file alone.
Instructions that apply to one specific tool belong in that tool's own config, not here.

**Repo-portable.** Nothing here may be specific to this repository: no hostnames or
addresses, no organisation or product names, no language- or tool-specific commands, no
paths outside `specs/`. The test is whether the sentence would be wrong in someone else's
repository. If it would, it belongs in `specs/` instead.

<!-- agent-workflow: v1.0.0 -->
