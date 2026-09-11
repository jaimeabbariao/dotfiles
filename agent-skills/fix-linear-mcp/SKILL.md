---
name: fix-linear-mcp
description: Repair Linear MCP OAuth on Coder workspaces when authorization callbacks point to localhost instead of the workspace's accessible address. Use for Linear login hangs, refused loopback callbacks, or requests to fix Linear MCP on a Coder box.
---

# Fix Linear MCP on Coder

Restore authentication in the client running on the Coder box. A browser on the user's computer cannot reach that box through its own localhost. Establish which machine owns the OAuth listener before changing anything.

## Locate the failing connection

- Identify the Coder workspace, agent, MCP client, configured Linear server name, and where the browser runs. Discover these from the active environment and connection settings. Ask only for missing information that cannot be inspected.
- Inspect the installed client's version and MCP help on the box. Discover the configured server name. CLI login works for the installed Linear plugin with `codex mcp login linear`. Try the existing server through CLI login; plugin-managed does not imply UI-only or require app-server investigation. Do not add a duplicate server.
- Keep a pending login alive when it can still be completed. Inspect only relevant configuration fields; do not dump credential stores. Displaying a fresh authorization URL for user consent is allowed and required below. Do not save it in files or logs. Never display a returned callback URL containing an authorization code.
- Confirm the listener exists on the box with an available socket inspection tool. Distinguish an unreachable listener from an expired flow, rejected redirect URI, or a Linear permission error.

## Configure a Coder callback

Read the current [Codex OAuth callback documentation](https://learn.chatgpt.com/docs/extend/mcp?surface=cli) and check support in the installed version before applying these settings.

Codex supports `mcp_oauth_callback_url` for remote ingress and `mcp_oauth_callback_port` for the listener. The URL's port does not select the listener port. Per-server OAuth settings can override globals. Non-local callbacks bind to `0.0.0.0`. Prefer a one-login `-c` override to a global edit. For a durable repair, use supported per-server settings and preserve existing client registration. Use the exact callback Codex emits, including any appended callback ID. Custom callback hosts require DCR or a configured OAuth client ID.

On a Coder workspace, use the remote callback immediately. Configure it before starting login. Follow this default sequence without asking the user for values that can be discovered:

1. Read workspace, owner, and agent from environment metadata. Obtain the wildcard domain from the Coder deployment's `/api/v2/applications/host` endpoint using the available authenticated Coder context. Inspect only the needed metadata, not the full environment or credentials.
2. Select an available listener port. Construct its address using the deployment-supported routing format and discovered wildcard domain. Do not assume a fixed hostname format. Keep the port private to its owner. Ask for an Open Ports URL only if discovery fails. See [Coder port forwarding](https://coder.com/docs/user-guides/workspace-access/port-forwarding).
3. Substitute the discovered values into this command and run it on the box in a session that stays alive while the user authorizes:

   ```sh
   codex \
     -c 'mcp_oauth_callback_port=PORT' \
     -c 'mcp_oauth_callback_url="https://VERIFIED_CODER_HOST/callback"' \
     mcp login SERVER --oauth-client-registration dcr
   ```

4. Confirm the listener is running on the selected port and verify that the constructed Coder address reaches it and preserves the callback path. A Coder sign-in page alone does not prove listener reachability. Use a harmless probe without an authorization code; do not consume or terminate the pending flow. Check that the freshly emitted redirect URI uses the intended Coder address. If routing fails, correct it before presenting the link and restart login if its callback configuration changed.
5. Return the freshly emitted authorization URL as a clickable link. Say "Open this link in a browser signed into Coder." Keep the login process running. Let the user complete account selection and consent, then check completion and Linear access as described below.

Do not manually replace `redirect_uri` inside an already-issued authorization request; registration and token exchange must agree on it. Deliver a requested "swapped URL" by starting a fresh login configured with the Coder callback.

## Fallbacks

If the client cannot configure a remote callback, forward the exact listener port from the browser's machine to the box. Confirm local CLI syntax first. For Coder, the command shape is `coder port-forward WORKSPACE --tcp PORT:PORT`. Run it on the browser's machine, keep it alive through login, and retain the original loopback redirect. Check for a local port conflict before starting.

If consent already landed on an unreachable localhost callback, start a fresh login with the Coder callback configured. Do not display, save, or replay the returned authorization code.

Do not reset all MCP credentials, change the Linear endpoint, broaden access scopes, or expose the port publicly to solve a callback-routing problem. Stop retries when the same failure repeats without new evidence. Report the failing stage and the specific user or administrator action needed.

## Verify and report

Require both a successful login in the workspace client and a read-only Linear MCP call from that client, such as reading the current user or listing accessible teams. Discover available tool names. Do not create an issue as a connectivity test. A CLI listing or successful login on another machine is insufficient.

Distinguish the observed stages in status updates:

- Prepared login. Callback routing is verified and the fresh authorization link is available. Authentication and Linear access remain unverified.
- Authenticated. The workspace login process reports success. Linear access remains unverified until a read succeeds.
- Completed repair. Login succeeded and a read-only Linear MCP call from the workspace client succeeded.

The reported Coder trial established a prepared login only. It verified callback routing and produced a login link, but did not establish successful authentication or Linear access. Do not cite it as evidence of a completed repair.

Reload the affected connection or start a fresh session if its tool catalog is stale. Stop temporary forwarding after verification. Report the cause, the changed callback mapping with secrets omitted, whether the repair persists, and the actual Linear read result. If the box is unavailable, provide concrete commands with clearly identified missing values and label the repair unverified.

For failures beyond callback routing, consult [Linear's MCP documentation](https://linear.app/docs/mcp) and diagnose the observed error before attempting another repair.
