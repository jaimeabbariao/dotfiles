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

"$script_dir/start-rex.sh" --tailscale --tailscale-hostname "$hostname"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
unset REX_SERVER REX_PACKAGE_TOKEN

# Start flags leave an existing server unchanged, so enable its listener too.
rex --autostart=false server tailscale on --hostname "$hostname"
rex --autostart=false server tailscale rename "$hostname"
if ! rex --autostart=false server tailscale pair --json >/dev/null 2>&1; then
  rex --autostart=false server tailscale login
fi
rex --autostart=false server status

if rex --autostart=false server tailscale pair; then
  printf '%s\n' 'In Rex on your Mac, choose Add Remote Host and enter the HTTPS address shown above.'
else
  printf '%s\n' \
    'If sign-in is pending, open the Tailscale login link shown above.' \
    'After signing in, rerun this script to show the address and pairing QR code.'
fi
