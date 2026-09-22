# Runtime compatibility

Jimmy runs in ChatGPT and Codex. Treat the runtime's actual tool schema as authoritative.

## Model selection

Read `<repo>/.jimmy/models.md` when it exists. Resolve `<repo>` with `git rev-parse --show-toplevel`, falling back to the current working directory outside Git. A role value of `inherit-parent` or `auto` means to omit the model override. A concrete model identifier is valid only when the runtime exposes or accepts it.

If there is no configuration, inherit the parent model for every role. Do not guess model identifiers from documentation or examples.

When a host exposes multiple Codex models, use distinct confirmed models for a panel only when model diversity improves independent judgment. Extra fan-out must earn its cost.

## Delegation

Use the runtime's native subagent or task mechanism:

- Run independent workers concurrently when the runtime supports it.
- Give each writer an isolated worktree or output path.
- Use read-only workers for review when the runtime supports read-only isolation.
- Keep the parent responsible for reviewing changes and synthesizing results.
- If subagents are unavailable, execute the same slices sequentially and preserve independent passes.

These are standalone skills. Spawn a general worker and instruct it to read the relevant worker skill, such as `jimmy-agent` or `comment-sicko`, before acting.

Use only fields present in the active tool schema.

## Product-specific features

Treat host conveniences as optional accelerators:

- Codex collaboration agents, app task coordination, goals, and automations are optional.

When a named feature is absent, keep the workflow's outcome and use the closest native mechanism. Do not block a core workflow on an optional integration.

## Local executables

Treat local executables as capabilities, not installation assumptions.

- Use Graphite only when the user or repository selects it, or when `gt` is available and the repository is already tracked. Otherwise use the repository's Git workflow.
- Use `gh` only when it is installed and authenticated. Otherwise use an available GitHub connector or browser capability. If none can perform the required operation, report that operation as unavailable.
- Use the bundled Bun helpers only when `bun` is available and the installed plugin directory is writable. Otherwise preserve the playbook's outcome with native runtime tools and the documented plain TSV, JSON, and Markdown files.
- Never install Bun, Graphite, GitHub CLI, or package dependencies merely because the skill was invoked. Install software only when the user requests it or the active task already authorizes dependency installation.

## Background work

Use the runtime's native wait, automation, or scheduled-task mechanism when the user requests monitoring or the playbook requires a later wakeup. If the runtime has no such mechanism, complete the current check and state that recurring monitoring was not scheduled. Do not imply that work will continue after the turn ends.

## Skill resolution

Skills bundled with Jimmy are siblings under the plugin's `skills/` directory. Resolve a named bundled skill through `../<skill-name>/SKILL.md`. A host-provided skill such as `skill-creator` remains a runtime capability. If it is absent, follow the local frontmatter, resource-link, and validation rules instead of blocking ordinary work.
