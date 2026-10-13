# dotfiles

```sh
git clone <repo> ~/dotfiles && ~/dotfiles/setup.sh
```

The repo only holds files edited by hand, so `git pull --rebase` stays clean on every machine.

- **Symlinked** (`link` in `setup.sh`): configs only you edit, e.g. zsh, nvim, ghostty, herdr.
- **Copied once** (`seed`): configs the app rewrites itself (`codex/config.toml`). Edit `~/.codex/config.toml` directly; update the repo copy only for settings new machines should start with.
- **Ignored**: runtime state written into linked dirs (herdr sessions/sockets, Codex `.system` skills). nvim's `lazy-lock.json` lives in `~/.local/share/nvim/`.

If a pull hits local changes, the culprit is an app writing state into the repo: gitignore it or switch it to `seed`.
