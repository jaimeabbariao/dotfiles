#!/usr/bin/env bash
set +x
set -euo pipefail

if [ "$#" -gt 1 ] || [ "${1:-}" = '-h' ] || [ "${1:-}" = '--help' ]; then
  printf '%s\n' 'Usage: connect-rex.sh [tailscale-hostname]' \
    'Run on the Coder box. The default is $CODER_WORKSPACE_NAME-rex, falling back to <machine-hostname>-rex.'
  exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hostname="${1:-${CODER_WORKSPACE_NAME:-$(hostname -s)}-rex}"
wait_seconds="${REX_CONNECT_TIMEOUT_SECONDS:-60}"
if ! [[ "$wait_seconds" =~ ^[0-9]+$ ]]; then
  printf '%s\n' 'REX_CONNECT_TIMEOUT_SECONDS must be a nonnegative integer.' >&2
  exit 2
fi
wait_seconds=$((10#$wait_seconds))
command -v python3 >/dev/null 2>&1 || {
  printf '%s\n' 'Python 3 is required to read Rex status.' >&2
  exit 1
}

"$script_dir/start-rex.sh" --tailscale --tailscale-hostname "$hostname"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
unset REX_SERVER REX_PACKAGE_TOKEN

# Start flags leave an existing server unchanged, so enable its listener too.
rex --autostart=false server tailscale on --hostname "$hostname"
rex --autostart=false server tailscale rename "$hostname"
deadline=$((SECONDS + wait_seconds))
login_requested=false
printf '%s\n' 'Waiting for Tailscale sign-in and HTTPS readiness...'
while :; do
  state="$(rex --autostart=false server status --json | python3 -c '
import json, sys
t = json.load(sys.stdin).get("tailscale", {})
if t.get("error"):
    print("failed")
elif t.get("state") == "running" and t.get("https", {}).get("state") == "available":
    print("ready")
else:
    print(t.get("state", "starting"))
')"
  case "$state" in
  ready)
    rex --autostart=false server tailscale pair
    printf '%s\n' 'In Rex on your Mac, choose Add Remote Host and enter the HTTPS address shown above.'
    exit 0
    ;;
  needs_login)
    if [ "$login_requested" = false ]; then
      rex --autostart=false server tailscale login
      printf '%s\n' 'Open the Tailscale sign-in link above. Waiting for sign-in to complete...'
      login_requested=true
    fi
    ;;
  needs_machine_approval)
    printf '%s\n' 'A tailnet administrator must approve this device in Tailscale.' >&2
    exit 1
    ;;
  disabled | failed)
    rex --autostart=false server status
    printf '%s\n' 'Tailscale is unavailable. Check rex server logs --follow.' >&2
    exit 1
    ;;
  esac
  if [ "$SECONDS" -ge "$deadline" ]; then
    rex --autostart=false server status
    if [ "$state" = needs_login ]; then
      printf '%s\n' 'Sign-in is still pending. Finish signing in, then rerun this script.' >&2
    else
      printf '%s\n' \
        'Tailscale HTTPS is not ready within the wait period.' \
        'Check that MagicDNS and HTTPS certificates are enabled in your tailnet.' \
        'Inspect rex server logs --follow, then rerun this script.' >&2
    fi
    exit 1
  fi
  sleep 2
done
