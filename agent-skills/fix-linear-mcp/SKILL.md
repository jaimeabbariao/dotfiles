---
name: fix-linear-mcp
description: Repair Linear MCP OAuth on Coder workspaces when authorization callbacks point to localhost instead of the workspace's accessible address. Use for Linear login hangs, refused loopback callbacks, or requests to fix Linear MCP on a Coder box.
---

# Fix Linear MCP on Coder

Restore authentication in the client running on the Coder box. A browser on the user's computer cannot reach that box through its own localhost. Establish which machine owns the OAuth listener before changing anything.

## Locate the failing connection

- Identify the Coder workspace, agent, MCP client, configured Linear server name, and where the browser runs. Discover these from the active environment and connection settings. Ask only for missing information that cannot be inspected.
- Inspect the installed client's version and MCP help on the box. For Codex, start with `codex mcp --help`; discover the server name rather than assuming `linear`. A plugin-managed connection needs its owning client's connection controls, not a duplicate CLI server.
- Keep a pending login alive when it can still be completed. Record its callback host, port, and path without recording authorization codes, state, tokens, or full authorization URLs. Inspect only relevant configuration fields; do not dump credential stores.
- Confirm the listener exists on the box with an available socket inspection tool. Distinguish an unreachable listener from an expired flow, rejected redirect URI, or a Linear permission error.

## Configure a Coder callback

Read the current [Codex OAuth callback documentation](https://learn.chatgpt.com/docs/extend/mcp?surface=cli) and check support in the installed version before applying these settings.

Codex supports `mcp_oauth_callback_url` for remote ingress and `mcp_oauth_callback_port` for the listener. The URL's port does not select the listener port. Per-server OAuth settings can override globals. Non-local callbacks bind to `0.0.0.0`. Prefer a one-login `-c` override to a global edit. For a durable repair, use supported per-server settings and preserve existing client registration. Use the exact callback Codex emits, including any appended callback ID. Custom callback hosts require DCR or a configured OAuth client ID.

Discover the actual URL for the selected port through Coder's Open Ports UI or supported workspace metadata. Do not invent a hostname from a workspace name. Coder deployment domains, agents, and routing formats vary. Keep the port private to its owner. Confirm the proxy maps to the chosen listener and preserves the callback path. Authenticate to Coder in the same browser before starting Linear consent. See [Coder port forwarding](https://coder.com/docs/user-guides/workspace-access/port-forwarding).

Start a fresh login after changing callback configuration. Verify the emitted redirect URI uses the intended Coder address and the listener uses its mapped port. Let the user complete account selection and consent. Do not manually replace `redirect_uri` inside an already-issued authorization request; registration and token exchange must agree on it.

## Fallbacks

If the client cannot configure a remote callback, forward the exact listener port from the browser's machine to the box. Confirm local CLI syntax first. For Coder, the command shape is `coder port-forward WORKSPACE --tcp PORT:PORT`. Run it on the browser's machine, keep it alive through login, and retain the original loopback redirect. Check for a local port conflict before starting.

For an already-completed consent that landed on an unreachable localhost callback, a one-time browser navigation to the verified Coder proxy may deliver the response to the still-waiting listener. Use this only for the same live flow and only when the proxy reaches that listener. Replace the origin while preserving the raw callback path and query exactly, including `code`, `state`, and any `iss`. Treat this as an unverified recovery until the client accepts it. Do not save or echo the resulting URL. If the flow expired, restart login instead of replaying it.

Do not reset all MCP credentials, change the Linear endpoint, broaden access scopes, or expose the port publicly to solve a callback-routing problem. Stop retries when the same failure repeats without new evidence. Report the failing stage and the specific user or administrator action needed.

## Verify and report

Require both a successful login in the workspace client and a read-only Linear MCP call from that client, such as reading the current user or listing accessible teams. Discover available tool names. Do not create an issue as a connectivity test. A CLI listing or successful login on another machine is insufficient.

Reload the affected connection or start a fresh session if its tool catalog is stale. Stop temporary forwarding after verification. Report the cause, the changed callback mapping with secrets omitted, whether the repair persists, and the actual Linear read result. If the box is unavailable, provide concrete commands with clearly identified missing values and label the repair unverified.

For failures beyond callback routing, consult [Linear's MCP documentation](https://linear.app/docs/mcp) and diagnose the observed error before attempting another repair.
