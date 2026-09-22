---
name: setup-jimmy
description: Configure Jimmy's role-to-model mapping for ChatGPT and Codex. Use for setup-jimmy, "configure Jimmy models", or changing Jimmy's model choices.
---

# Setup Jimmy

Create a project-local model configuration that every Jimmy skill can read. The default is intentionally portable: inherit the parent model unless the active runtime confirms another exact identifier.

## 1. Find the project and runtime

Resolve the project root with `git rev-parse --show-toplevel`. Outside Git, use the current working directory. The configuration path is `<repo>/.jimmy/models.md`.

Confirm that the active host is ChatGPT or Codex from the available tools and system context. Read `../jimmy/references/runtime-compatibility.md` before mapping models.

## 2. Detect available models

Use model identifiers exposed by the active subagent tool, host settings, or an official model-list command. Never invent a slug and never trigger a failing task merely to scrape an error message. `inherit-parent` and `auto` are always valid because both mean to omit the model override.

Record confirmed OpenAI model identifiers available to the coding runtime.

If the runtime exposes no list, use `inherit-parent` for every role. The user can supply exact identifiers later.

## 3. Choose a profile

Preserve an existing `<repo>/.jimmy/models.md` as the current state. If it does not exist, import values from `<repo>/.pstack/models.md` when present. Confirm every concrete identifier is still available before importing it. Write the result only to `.jimmy/models.md`; leave the legacy file unchanged.

Offer these profiles when the runtime can support them:

- `inherit`: every role inherits the parent. This is the portable default.
- `codex`: use confirmed Codex identifiers only.
- `mixed`: use multiple confirmed Codex models for judgment panels. Offer this only when the host can actually spawn them.

Use a fast confirmed model for mechanical code and exploration, and the strongest confirmed reasoning model for judgment, prose, and subtle code. For panels, two independent reviewers are the default. More reviewers must have a concrete coverage or diversity benefit.

## 4. Validate

Every concrete identifier must be present in the detected set. A mixed panel must include at least two distinct confirmed Codex model identifiers. If that is unavailable, fall back to a single-model profile and say so.

## 5. Write the configuration

Create `<repo>/.jimmy/` when needed and overwrite `models.md` so setup stays idempotent. Use this shape:

```md
---
runtime: codex
profile: inherit
---
# Jimmy model configuration
# `inherit-parent` and `auto` mean: omit the subagent model override.
feature, refactoring: inherit-parent
bug-fix: inherit-parent
perf-issue: inherit-parent
hillclimb: inherit-parent
judgment and prose: inherit-parent
hardest tasks: inherit-parent
how explorer: inherit-parent
how explainer: inherit-parent
how critics: inherit-parent, inherit-parent
why investigators: inherit-parent
why synthesizer: inherit-parent
reflect tooling: inherit-parent
reflect judgment, divergent, synthesizer: inherit-parent
arena runners: inherit-parent, inherit-parent
arena cross-judge pool: inherit-parent
swarm workers: inherit-parent
architect runners: inherit-parent, inherit-parent
interrogate reviewers: inherit-parent, inherit-parent
```

Lists set panel size. Duplicate `inherit-parent` entries request independent passes on the parent model.

## 6. Offer a verification skill (optional)

Check whether the project already has a `verify-*` skill or another executable harness that can drive the real application. If neither exists, offer once to generate a project-local verifier with `create-verification-skill`. Write it to the active runtime's project skill directory. On no, continue without pushing.

## 7. Confirm

Report the configuration path, runtime, profile, and any unavailable model family. New ChatGPT and Codex tasks can read the same file.
