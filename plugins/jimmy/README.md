# Jimmy

Jimmy is an engineering workflow plugin for ChatGPT and Codex. It packages 48 skills for planning, implementation, review, verification, and shipping.

Use `$jimmy` to apply the full workflow to a task. You can also invoke a bundled skill directly, such as `$jimmy:architect`, `$jimmy:blast-radius`, or `$jimmy:teach`.

## Install a tagged release

Install a tagged release so that your workflow changes only when you choose to update it.

```bash
codex plugin marketplace add figma/jimmy --ref v0.1.1
codex plugin add jimmy@jimmy-team
```

If the repository is private and your team uses SSH, add the SSH URL instead:

```bash
codex plugin marketplace add \
	git@github.com:figma/jimmy.git \
	--ref v0.1.1
codex plugin add jimmy@jimmy-team
```

Start a new task after installation. Codex loads newly installed skills when the task starts.

## Use Jimmy

Invoke the main workflow with a concrete task:

```text
$jimmy implement the account deletion flow and verify it in the running app
```

Run `$setup-jimmy` to configure model choices for Jimmy's worker and reviewer roles. The skill writes project-local settings to `.jimmy/models.md`. Without that file, each role inherits the current task's model.

## Update Jimmy

To move a pinned installation to a new release, replace `v0.2.0` with the tag you want:

```bash
codex plugin marketplace remove jimmy-team
codex plugin marketplace add figma/jimmy --ref v0.2.0
codex plugin add jimmy@jimmy-team
```

If you intentionally installed the marketplace without `--ref`, refresh its current branch instead:

```bash
codex plugin marketplace upgrade jimmy-team
codex plugin add jimmy@jimmy-team
```

Start a new task after the update. The [OpenAI plugin packaging guide](https://developers.openai.com/plugins/build/plugins) documents Git refs and marketplace commands.

## Develop locally

Clone the repository, then register the checkout as a local marketplace:

```bash
git clone git@github.com:figma/jimmy.git
cd jimmy
codex plugin marketplace add "$PWD"
codex plugin add jimmy@jimmy-team
```

After changing the plugin, update its cachebuster and reinstall it:

```bash
python3 /path/to/plugin-creator/scripts/update_plugin_cachebuster.py \
	plugins/jimmy
codex plugin add jimmy@jimmy-team
```

Keep `plugins/jimmy/plugin.json` and `plugins/jimmy/.codex-plugin/plugin.json` on the same version when preparing a release.

## Validate changes

Run the package validator from the repository root:

```bash
python3 plugins/jimmy/scripts/validate.py
```

Run the helper tests and TypeScript check when you change the orchestration or pull-request watcher code:

```bash
cd plugins/jimmy/skills/jimmy/scripts
bun install --frozen-lockfile
bun test orch watch-pr
bun run typecheck
```

Do not commit `node_modules`. The package validator rejects it.

## License and provenance

Jimmy adapts work from pstack and Ponytail. See [SOURCES.json](SOURCES.json) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for pinned revisions and license details.
