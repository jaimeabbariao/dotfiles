#!/usr/bin/env bash
set +x
set -euo pipefail

if [ "$#" -gt 1 ] || [ "${1:-}" = '-h' ] || [ "${1:-}" = '--help' ]; then
  printf '%s\n' 'Usage: start-rex.sh [tailscale-hostname]' \
    'Boot hook for the Coder box. The default is $CODER_WORKSPACE_NAME-$CODER_WORKSPACE_OWNER_NAME-rex.'
  exit 0
fi
hostname="${1:-${CODER_WORKSPACE_NAME:-$(hostname -s)}${CODER_WORKSPACE_OWNER_NAME:+-$CODER_WORKSPACE_OWNER_NAME}-rex}"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

if ! command -v rex >/dev/null 2>&1; then
  if [ -z "${REX_PACKAGE_TOKEN:-}" ]; then
    printf '%s\n' 'Rex is missing. Supply REX_PACKAGE_TOKEN through a Coder secret to install it.' >&2
    exit 1
  fi

  (
    umask 077
    installer="$(mktemp)"
    trap 'rm -f "$installer"' EXIT

    # Keep credentials off curl's command line and out of the downloaded file.
    credential="${REX_PACKAGE_TOKEN//\\/\\\\}"
    credential="${credential//\"/\\\"}"
    credential="${credential//$'\n'/\\n}"
    credential="${credential//$'\r'/\\r}"
    printf 'user = "rex:%s"\n' "$credential" |
      curl --disable --config - --fail --silent --show-error --location \
        --proto '=https' --proto-redir '=https' \
        https://pkgs.superlogical.com/rex/install.sh --output "$installer"
    export REX_PACKAGE_TOKEN
    sh "$installer"
  )
fi

unset REX_PACKAGE_TOKEN

# Without cap_net_raw, Tailscale falls back to interface-bound dials that time out on Coder.
# Updates replace the binary and drop the capability, so set it every boot.
sudo -n setcap cap_net_raw=ep "$(readlink -f "$(command -v rex)")" ||
  printf '%s\n' 'Could not set cap_net_raw on rex; Tailscale may fail to connect.' >&2

# A boot hook must start this box's server, even in a remote Rex terminal.
unset REX_SERVER

rex_env_args=()
while IFS= read -r name; do
  case "$name" in
  REX_*) continue ;;
  esac
  rex_env_args+=(--env "$name")
done < <(compgen -e)

# Tailscale is runtime-only, so every boot must pass these flags.
rex server start "${rex_env_args[@]}" --tailscale --tailscale-hostname "$hostname"
rex --autostart=false server status
