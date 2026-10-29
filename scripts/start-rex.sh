#!/usr/bin/env bash
set +x
set -euo pipefail

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

# A boot hook must start this box's server, even in a remote Rex terminal.
unset REX_SERVER

rex_env_args=()
while IFS= read -r name; do
  case "$name" in
  REX_*) continue ;;
  esac
  rex_env_args+=(--env "$name")
done < <(compgen -e)

rex server start "${rex_env_args[@]}" "$@"
rex --autostart=false server status
