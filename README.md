# dotfiles

```sh
git clone <repo> ~/dotfiles && ~/dotfiles/setup.sh
```

The repo only holds files edited by hand, so `git pull --rebase` stays clean on every machine.

- **Symlinked** (`link` in `setup.sh`): configs only you edit, e.g. zsh, nvim, ghostty, herdr.
- **Copied once** (`seed`): configs the app rewrites itself (`codex/config.toml`). Edit `~/.codex/config.toml` directly; update the repo copy only for settings new machines should start with.
- **Ignored**: runtime state written into linked dirs (herdr sessions/sockets, Codex `.system` skills). nvim's `lazy-lock.json` lives in `~/.local/share/nvim/`.

If a pull hits local changes, the culprit is an app writing state into the repo: gitignore it or switch it to `seed`.

## Start Rex when a Coder workspace boots

In Coder's account settings, open **Secrets** and create a secret with the
environment variable target `REX_PACKAGE_TOKEN`. Paste your Rex package token
into the secret value. Never put the value in this repo or your startup command.
See [Coder user secrets](https://coder.com/docs/user-guides/user-secrets).
If your Coder version lacks user secrets, have your template inject the variable
from your organization's secret manager.

Run this as your normal workspace user:

```sh
~/dotfiles/scripts/start-rex.sh
```

Add that command to your Coder workspace's startup script to run it at every
boot. If Rex is missing, the script downloads and runs the
[official Linux installer](https://www.superlogical.com/rex/docs/linux/installation)
using the injected token. Installation may require sudo. The script then starts
a background personal server and prints its status.
Repeated runs leave an existing server running. It does not require systemd
to start Rex. Keep Rex's state directory on a persistent workspace volume.

The wrapper disables shell tracing, sends download credentials through stdin,
and removes the token from its environment before starting Rex. The upstream
installer and package manager also receive the token and may store repository
credentials. Their token handling has not been audited here. Processes running
as your workspace user or root can access injected secrets.

For remote access through
[Rex's built-in Tailscale](https://www.superlogical.com/rex/docs/linux/remote-access),
run this helper on the Coder box. Use the same command in your boot hook:

```sh
~/dotfiles/scripts/connect-rex.sh
```

On the first run, open the Tailscale sign-in link shown in the status output,
then rerun the helper. It shows the server address and a pairing QR code once
Tailscale is ready. In the Rex Mac app, choose **Add Remote Host** and enter
that address. Your Mac must be connected to the same tailnet.
Pass a different hostname as the first argument, such as
`~/dotfiles/scripts/connect-rex.sh my-coder-box`, when setting up another box.
Without networking flags, Rex listens only locally. Startup flags apply only
when a new server starts.

To inspect startup errors, run `rex server logs --follow` on the Coder box.
This script starts Rex when called. It does not register a boot hook itself.

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
