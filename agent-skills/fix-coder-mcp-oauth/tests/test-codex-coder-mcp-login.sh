#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")/../scripts" && pwd)"
login_script="$script_dir/codex-coder-mcp-login"

assert_contains() {
  local output="$1"
  local expected="$2"
  [[ "$output" == *"$expected"* ]] || {
    printf 'expected output to contain: %s\nactual output:\n%s\n' "$expected" "$output" >&2
    exit 1
  }
}

ingress_output="$(
  VSCODE_PROXY_URI='https://{{port}}--main--demo--jimmy.apps.example.com/' \
    "$login_script" --dry-run linear
)"
assert_contains "$ingress_output" 'OAuth callback: https://32123--main--demo--jimmy.apps.example.com/callback'
assert_contains "$ingress_output" 'mcp login linear --oauth-client-registration dcr'

loopback_output="$(
  CODER_WORKSPACE_NAME=demo CODER_WORKSPACE_AGENT_NAME=main \
    "$login_script" --loopback --dry-run github
)"
assert_contains "$loopback_output" 'coder port-forward demo.main --tcp 32123:32123'
assert_contains "$loopback_output" 'OAuth callback: http://127.0.0.1:32123/callback'

custom_output="$(
  "$login_script" \
    --callback-url 'https://custom.example.test/base' \
    --port 43210 \
    --registration auto \
    --dry-run notion \
    -- --scopes read
)"
assert_contains "$custom_output" 'OAuth callback: https://custom.example.test/base/callback'
assert_contains "$custom_output" 'mcp login notion --oauth-client-registration auto --scopes read'

if "$login_script" --port 70000 --dry-run invalid >/dev/null 2>&1; then
  printf 'invalid port unexpectedly succeeded\n' >&2
  exit 1
fi

if env -u VSCODE_PROXY_URI -u CODER_MCP_CALLBACK_URL -u CODER_URL -u CODER_AGENT_URL \
  "$login_script" --dry-run missing-metadata >/dev/null 2>&1; then
  printf 'missing Coder metadata unexpectedly succeeded\n' >&2
  exit 1
fi

printf 'codex-coder-mcp-login tests passed\n'
