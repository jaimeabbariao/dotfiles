---
name: shepherd
description: Shepherd a feature idea into a stack of reviewable PRs. Runs idea → spec → disposable plan → PR slices with a walk order, then hands off. Use when the user wants to turn a feature idea into a stack of PRs, or asks "how should I cut this into PRs", "split this into a stack", "stack this up", "where do the PR boundaries go", "shepherd this feature", or invokes /shepherd. Planning only — does not implement.
---

# Shepherd

Turn a feature idea into a linear stack of PRs, each independently reviewable.
Plan only — you do not implement. Print the walk order and stop.

Do not reimplement stages that other skills own. Route to them.

## Flow

Skip any step whose artifact already exists.

1. **Idea unclear?** → invoke `grilling`. Skip if the idea is already concrete.
2. **Ponytail the feature.** Invoke `ponytail`, then run rung 1 against the
   scope: which parts of this feature should not exist? A slice deleted here is
   a PR nobody writes and nobody reviews. Report what you cut.
3. **No spec?** → invoke `to-spec`. Normal prose — humans read the tracker.
4. **No plan?** → invoke `superpowers:writing-plans`, in `caveman:full`.
   - Write it to `/tmp/shepherd-<slug>.md`.
   - **Do NOT commit the plan. Override `writing-plans`' commit step.** The plan
     is disposable; it dies with the stack. Nothing goes in `docs/`.
5. **Cut the stack.** See below. `caveman:ultra` for the table.
6. **Print the walk order and stop.**

## Cutting the stack

A stack is a **line, not a graph**. Two genuinely independent slices are two
stacks, not one stack with a fork.

Every slice must merge alone and leave `main` green. No half-wired feature, no
slice that only compiles because its child landed too.

Default shape, bottom → top:

1. **Groundwork, no behavior change** — types, migration, dead-code deletion,
   the refactor that opens the seam.
2. **New code, unreferenced** — the implementation, not yet called.
3. **Wire-up** — the callsite switch. This is where behavior changes.
4. **Cleanup** — flag flip, delete the old path.

Rules:

- **Never mix mechanical with judgment.** An 80-file rename hides the 10-line
  logic change inside it. Peel the rename into its own slice.
- One reviewer concern per slice. Needs two different reviewers → two slices.
- Soft ceiling ~400 diff lines. Over that, look for a mechanical portion to peel
  off before you split on logic.

Then ponytail the stack itself: can 4 slices be 2? Is any slice pure scaffolding
for later? Fewest slices that still review cleanly wins.

## Output

A table, one row per slice, bottom of stack first:

| # | branch | does | separate because | reviewer looks at |
|---|--------|------|------------------|-------------------|

Then the walk order:

```
per slice, bottom → top:
  implement                        # ponytail active
  /ponytail-review                 # this slice's diff only, vs its base
  address findings
  gt create -am "<message>"
top of stack:
  gt submit --stack
```

Put the `/ponytail-review` line in the plan file's per-slice header too. The
chat table dies with the session; the plan file has to carry it through the walk.

Stop here. The user implements.
