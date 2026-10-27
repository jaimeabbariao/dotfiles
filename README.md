# dotfiles

```sh
git clone <repo> ~/dotfiles && ~/dotfiles/setup.sh
```

The repo only holds files edited by hand, so `git pull --rebase` stays clean on every machine.

- **Symlinked** (`link` in `setup.sh`): configs only you edit, e.g. zsh, nvim, ghostty, herdr.
- **Copied once** (`seed`): configs the app rewrites itself (`codex/config.toml`). Edit `~/.codex/config.toml` directly; update the repo copy only for settings new machines should start with.
- **Ignored**: runtime state written into linked dirs (herdr sessions/sockets, Codex `.system` skills). nvim's `lazy-lock.json` lives in `~/.local/share/nvim/`.

If a pull hits local changes, the culprit is an app writing state into the repo: gitignore it or switch it to `seed`.

## Switch terminal and editor themes

After setup links your Zsh config, reload it with `source ~/.zshrc`, then run:

```sh
theme light
theme dark
theme toggle
theme status
```

Running `theme` without an argument toggles the mode. Adapted from
[ja153903/dotfiles](https://github.com/ja153903/dotfiles/tree/9888a72b8b3a84a4b72eebd683e228d81262e471),
the command switches Ghostty, Herdr, and Neovim between One Light and One Dark.
It saves the mode in `nvim/theme-mode`, which Git ignores. The default is dark.
Theme changes edit the linked Ghostty and Herdr configs, so those changes appear in `git diff`.

Ghostty reloads through AppleScript on macOS. Herdr reloads its running server
and attached clients. A stopped Herdr server stays stopped. Neovim watches the
saved mode and updates without restarting. Restart existing Neovim sessions
once to load the watcher. macOS appearance stays independent.

The command requires Python 3. It uses `XDG_CONFIG_HOME`, or `~/.config` by
default. `HERDR_CONFIG_PATH` overrides the Herdr config path. If a reload fails,
the command reports the error and exits with a failure status. The configs stay
saved. Run `theme light` or `theme dark` again to retry the reload.

Run the isolated checks with `python3 -m unittest discover -s scripts/tests -v`.
