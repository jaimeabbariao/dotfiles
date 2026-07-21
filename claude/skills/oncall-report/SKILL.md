---
name: oncall-report
description: Generate an adoption-oncall handoff for a one-week shift. Pulls what I worked on and what's still open from GitHub, Asana, and Slack into a local markdown report.
---

# Oncall Report

Generate a one-week adoption-oncall handoff. The report has two halves: **what I worked on** during the shift, and **what still needs to be handed off** to the next oncall.

## Invocation

- `/oncall-report [YYYY-MM-DD]` — the date is the **shift start**.
- `/oncall-report` (no arg) — default the shift start to the **most recent Monday**.

The shift window is `[start, start + 7 days]`.

## Handles

| Platform | ID |
|---|---|
| GitHub | jaimeabbariao |
| Slack user | U06MUPSF2BX |
| Slack `@adoption-oncall` group | S09NETP4P6Z |
| Asana user | 1207856102142357 |
| Asana workspace | 10497086658021 |

## Output

- Write to `/Users/jabbariao/db/oncall/report-YYYY-MM-DD.md`, where the date is the **shift start**.
- **If the file already exists, warn the user and ask before overwriting** — handoffs get hand-curated, don't clobber edits silently.
- After writing, report the path. Do not preview in chat first.

## Report layout

```markdown
# Oncall Handoff — {start} to {end}

## Worked on this shift

### GitHub
- **YYYY-MM-DD** — [#123](url) Title

### Asana
- **YYYY-MM-DD** — [Task name](url)

### Slack
- **YYYY-MM-DD** — [#channel](permalink): what I said/did

## To hand off

### GitHub
- **YYYY-MM-DD** — [#123](url) Title
  1-line summary of current state (e.g. waiting on X's review, blocked on repro)

### Asana
- **YYYY-MM-DD** — [Task name](url)
  1-line summary of current state

### Slack
- **YYYY-MM-DD** — [#channel](permalink): the request
  1-line summary of what's still needed
```

- **"Worked on" entries are minimal** — date, link, title. No summary.
- **"To hand off" entries include a 1-line summary** of current state, since the next oncall needs context.
- Omit any subsection that has no items.

## Source: GitHub

PRs **authored during the shift** in `figma/figma`.

```
gh pr list --repo figma/figma --author jaimeabbariao \
  --search "created:{start}..{end}" --state all \
  --json number,title,url,state,createdAt,mergedAt --limit 100
```

Classify:
- `state == MERGED` → **Worked on**
- `state == OPEN` → **To hand off** (summary: what's left / who it's waiting on)
- `state == CLOSED` (unmerged) → drop

## Source: Asana

No dedicated oncall board — query tasks assigned to the user. Read the Asana token from `~/.config/api-tokens.json` (key: `asana`).

```
curl -s -H "Authorization: Bearer $ASANA_TOKEN" \
  "https://app.asana.com/api/1.0/tasks?workspace=10497086658021&assignee=1207856102142357&completed_since={start}&opt_fields=name,completed,completed_at,modified_at,projects.name,permalink_url&limit=100"
```

`completed_since={start}` returns incomplete tasks plus tasks completed after the shift start. From the results:
- `completed == true` AND `completed_at` within the window → **Worked on**
- `completed == false` AND `modified_at` within the window → **To hand off**

Escape any `$` in task names (Obsidian/markdown renders `$...$` as LaTeX).

## Source: Slack

Two streams, searched across all public + private channels via `mcp__plugin_slack_slack__slack_search_public_and_private`.

Parameters: `channel_types: public_channel,private_channel`, `sort: timestamp`, `sort_dir: asc`, `response_format: concise`, `limit: 20`. Paginate through all results.

### Stream 1 — my messages → Worked on

```
query: "from:<@U06MUPSF2BX> after:{start-1d} before:{end+1d}"
```

Filter to **moderate+ signal** — keep answers, guidance, coordination; drop one-word replies, "thanks", "lol", emoji-only. Each entry: `- **YYYY-MM-DD** — [#channel](permalink): what I said/did`.

### Stream 2 — `@adoption-oncall` pings → To hand off

Search for mentions of the group (subteam `S09NETP4P6Z`, handle `adoption-oncall`):

```
query: "adoption-oncall after:{start-1d} before:{end+1d}"
```

**Do not auto-classify resolution.** List every ping from the shift under **To hand off → Slack**, each with a permalink and a 1-line summary of the request. This biases toward over-surfacing — the user deletes the ones they actually closed when curating the file.

Every Slack entry MUST include a permalink.

## Principles

- **Two halves:** "Worked on" (retrospective) and "To hand off" (forward-looking).
- **Bias toward surfacing** open items — better to over-hand-off than drop a request.
- **Editable output:** the file is meant to be hand-curated; never overwrite without asking.
