---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

Read `../poteto-mode/references/runtime-compatibility.md` before selecting models or spawning workers.

## When to invoke

- The user said "reflect" or "/reflect".
- A complex task (5+ tool calls) just landed cleanly and the recipe is worth keeping.
- The agent hit dead ends, found the working path, and the path generalizes.
- The user corrected the agent's approach mid-task.
- A non-trivial workflow emerged that isn't captured anywhere.

Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

Use the active transcript path only when the runtime explicitly provides one for this task. Never search global history or unrelated project transcripts. If no active path is exposed, write a tight digest of the current conversation and pass that instead.

### 2. Spawn three reviewers in parallel

Spawn three reviewers concurrently with the runtime's native delegation tool. Give them the read tools needed for context lookups referenced in the transcript, but forbid writes; the parent applies edits. Use configured models only when the exact identifiers are confirmed.

| Lens | `model` | Prompt template |
|---|---|---|
| Judgment | your configured reflect-judgment model (default `inherit-parent`) | `references/judgment-reviewer.md` |
| Tooling | your configured reflect-tooling model (default `inherit-parent`) | `references/tooling-reviewer.md` |
| Divergent | your configured reflect-judgment model (default `inherit-parent`) | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in their task results.

### 3. Synthesize

Spawn one synthesizer worker using your configured reflect-judgment model, or inherit the parent when unconfigured. Give it read access needed to spot-verify citations and forbid writes. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. The synthesizer already applies this criterion; this is a final pass before edits land. See the **encode-lessons-in-structure** principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org; do not auto-apply.

Do not file Backlog items externally unless the user asked for tracker updates. Otherwise return them in the report.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): use the runtime's skill-creator workflow when available.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): use the skill-creator workflow and its description-optimization loop.
- `new skill via skill-creator: <kebab-name>`: use the skill-creator workflow. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
