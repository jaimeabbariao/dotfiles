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
a background personal server with
[Rex's built-in Tailscale](https://www.superlogical.com/rex/docs/linux/remote-access)
enabled and prints its status. Tailscale is runtime-only in Rex, so the boot hook
must pass these flags each time. A node that signed in before reconnects on its
own; the boot hook never waits for sign-in.
Before starting Rex, it runs `sudo -n setcap cap_net_raw=ep` on the Rex binary.
Without that capability, Tailscale's connections time out on Coder boxes.
Updates replace the binary, so this runs on every boot. If sudo fails, it warns
and starts Rex anyway.
Repeated runs leave an existing server running. It does not require systemd
to start Rex. Keep Rex's state directory on a persistent workspace volume.

The wrapper disables shell tracing, sends download credentials through stdin,
and removes the token from its environment before starting Rex. The upstream
installer and package manager also receive the token and may store repository
credentials. Their token handling has not been audited here. Processes running
as your workspace user or root can access injected secrets.

On a new box, run this helper once by hand to sign in and pair. Do not put it
in your boot hook:

```sh
~/dotfiles/scripts/connect-rex.sh
```

When Rex reports `needs_login`, the helper requests a sign-in link once with
`rex server tailscale login`. Open the link shown in the output. The helper waits up to
5 minutes for sign-in and HTTPS readiness, then shows the server address and
a pairing QR code. If sign-in takes longer, finish signing in and rerun it.
Set `REX_CONNECT_TIMEOUT_SECONDS` to change the wait period.
It never requests login while Rex reports `starting`: a saved node reports that
until it reaches Tailscale's coordination server, and a login request would
discard its key. If it times out in `starting`, the node cannot reach Tailscale;
check `~/.local/state/rex/tsnet/node/tailscaled.log*`. If HTTPS times out, check that MagicDNS
and HTTPS certificates are enabled in your tailnet, then inspect Rex's logs.
The helper requires Python 3 to read Rex's JSON status.
In the Rex Mac app, choose **Add Remote Host** and enter
that address. Your Mac must be connected to the same tailnet.
Pass a different hostname as the first argument, such as
`~/dotfiles/scripts/connect-rex.sh my-coder-box`, and pass the same name to
`start-rex.sh` in your boot hook.
By default, both scripts use `$CODER_WORKSPACE_NAME-$CODER_WORKSPACE_OWNER_NAME-rex`,
such as `payments-dev-alex-rex`, so names stay unique on a shared tailnet.
Outside a Coder-managed environment, they fall back to `<machine-hostname>-rex`.
The helper also renames an already-enabled Rex Tailscale node to this name.
If you previously saved its old address on your Mac, update that remote host.
Startup flags apply only when a new server starts.

The startup script forwards all exported environment variables using Rex's
`--env NAME` option, except `REX_*` variables. This includes Coder-injected
variables regardless of their names. Values stay out of command arguments.
Run the helper from a Coder-managed terminal or agent startup script so those
variables are available. An ordinary SSH session may have a different environment.
Forwarded credentials are available to programs running in Rex terminals.

Environment changes apply only when Rex starts a new server. If a server was
already running with an incomplete environment, finish its sessions before
running `rex server stop`, then rerun the helper from a Coder-managed terminal.
Stopping the server ends its sessions.

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
