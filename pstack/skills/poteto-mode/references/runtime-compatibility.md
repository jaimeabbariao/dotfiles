# Runtime compatibility

pstack runs in Claude, Codex, and Cursor. Treat the runtime's actual tool schema as authoritative.

## Model selection

Read `<repo>/.pstack/models.md` when it exists. Resolve `<repo>` with `git rev-parse --show-toplevel`, falling back to the current working directory outside Git. A role value of `inherit-parent` or `auto` means to omit the model override. A concrete model identifier is valid only when the runtime exposes or accepts it.

If there is no configuration, inherit the parent model for every role. Do not guess model identifiers from documentation or examples. A runtime that exposes only Claude models or only Codex models still supports the workflow. It does not support a true cross-family panel; report that limitation instead of pretending otherwise.

When a host can run both model families, prefer at least one confirmed Claude model and one confirmed Codex model for a panel whose purpose is independent judgment. Extra fan-out must earn its cost.

## Delegation

Use the runtime's native subagent or task mechanism. Translate the intent, not Cursor-specific field names:

- Run independent workers concurrently when the runtime supports it.
- Give each writer an isolated worktree or output path.
- Use read-only workers for review when the runtime supports read-only isolation.
- Keep the parent responsible for reviewing changes and synthesizing results.
- If subagents are unavailable, execute the same slices sequentially and preserve independent passes.

Claude Code can load the custom agents in `agents/`. Codex does not load that directory, so a Codex parent should spawn a general worker and instruct it to read the relevant pstack skill before acting. Cursor may use either behavior depending on its active plugin runtime.

Never pass unsupported fields copied from another runtime. Examples include Cursor's `subagent_type`, `environment`, `run_in_background`, and `cloud_base_branch`. Use only fields present in the active tool schema.

## Product-specific features

Treat host conveniences as optional accelerators:

- Cursor `/loop`, cloud agents, Bugbot, and `cursor-team-kit` are optional.
- Claude Code custom agents and plugin hooks are optional.
- Codex collaboration agents, app task coordination, goals, and automations are optional.

When a named feature is absent, keep the workflow's outcome and use the closest native mechanism. Do not block a core workflow on an optional integration.
