---
name: fix-coder-mcp-oauth
description: Repair MCP OAuth callbacks when Codex runs in a Coder workspace but authorization opens in a browser on another machine. Use for localhost callback failures, hanging MCP login, or reusable Coder MCP authentication setup.
---

# Fix Codex MCP OAuth in Coder

Restore authentication in the Codex client running inside the Coder workspace. The browser's loopback address and the workspace's loopback address are different machines.

Use the bundled `scripts/codex-coder-mcp-login` command when available. It configures a one-login callback override without changing the user's shared Codex configuration.

## Diagnose the failing stage

1. Identify the configured MCP server name with `codex mcp list`. Do not add a duplicate server.
2. Check `codex --version` and `codex mcp login --help` for `mcp_oauth_callback_url`, `mcp_oauth_callback_port`, and `--oauth-client-registration` support.
3. Determine where Codex runs and where the authorization browser runs. A browser on the user's computer cannot reach a listener bound to the workspace's `127.0.0.1` without forwarding.
4. Distinguish callback routing failures from expired authorization requests, rejected redirect URIs, insufficient scopes, and provider permission errors.

## Prefer Coder ingress

Run:

```sh
codex-coder-mcp-login SERVER
```

The helper uses `CODER_MCP_CALLBACK_URL` when set. Otherwise it derives the callback from `VSCODE_PROXY_URI`, or from Coder workspace metadata and the deployment's application-host endpoint. It uses a fixed listener port so the external route and Codex listener agree.

The browser must be signed into the Coder deployment. Keep the generated application route private to the workspace owner. The helper defaults to dynamic client registration because custom callback hosts require DCR or a pre-registered client ID.

Use the exact redirect URI emitted by Codex. Codex can append a server-specific callback ID. Never edit `redirect_uri` in an authorization URL that has already been issued.

## Use loopback forwarding when the provider rejects ingress

Some providers accept only pre-registered loopback redirects. On the browser's machine, start the forwarding command printed by:

```sh
codex-coder-mcp-login --loopback --dry-run SERVER
```

Then run the login in the workspace:

```sh
codex-coder-mcp-login --loopback SERVER
```

Keep the forwarding process alive until login completes. Do not expose the listener publicly. If a callback already landed on an unreachable localhost URL, start a fresh login instead of replaying its authorization code.

## Verify

Treat these as separate outcomes:

- Prepared login. The listener and callback route are correct, and Codex emitted a fresh authorization URL.
- Authenticated. `codex mcp login` completed successfully in the workspace.
- Completed repair. After refreshing the Codex session if needed, a harmless read-only tool call through that MCP server succeeds.

Choose a provider-appropriate read operation. For Linear, read the current user or list teams. For GitHub, read the authenticated user or a repository the user names. Never create or modify external data as a connectivity test.

Stop after the same failure repeats without new evidence. Report the failing stage and the user or administrator action needed. Do not clear unrelated MCP credentials, broaden scopes, or change the MCP endpoint to solve callback routing.

Current Codex callback behavior is documented in [OpenAI's MCP documentation](https://learn.chatgpt.com/docs/extend/mcp?surface=cli). Coder documents workspace application routing in [Workspace ports](https://coder.com/docs/user-guides/workspace-access/port-forwarding).
