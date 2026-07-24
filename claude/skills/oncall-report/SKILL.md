---
name: oncall-report
description: Generate an adoption-oncall evidence log and contextual handoff for a one-week shift. Pulls completed and open work from GitHub, Asana, and Slack, then groups related issues into larger topics with progress, current state, and next steps.
---

# Oncall Report

Generate a one-week adoption-oncall handoff in two stages:

1. Capture exhaustive, source-linked items in an **evidence file**.
2. Read that file and synthesize a **contextual report** organized by topic rather than platform.

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

- Write evidence to `/Users/jabbariao/db/oncall/evidence/{start}.md`.
- Write to `/Users/jabbariao/db/oncall/report-YYYY-MM-DD.md`, where the date is the **shift start**.
- **If either file already exists, warn the user and ask before overwriting that file** — handoffs and evidence get hand-curated, so do not clobber edits silently.
- Write the evidence file before drafting the report. Build the report by reading the saved evidence file, not from transient tool results.
- After writing, report both paths. Do not preview either document in chat first.

## Evidence layout

```markdown
# Oncall Evidence — {start} to {end}

## Worked on this shift

### GitHub
- **YYYY-MM-DD** — [#123](url) Title
  Context or outcome when it helps connect this item to a larger initiative.

### Asana
- **YYYY-MM-DD** — [Task name](url)
  Project and enough context to identify the initiative.

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

- Keep the evidence source-oriented and complete. Preserve dates, titles, current state, project/channel names, and direct links.
- Add brief context to completed entries when the title alone is insufficient for thematic grouping.
- Give every handoff entry a 1-line current-state summary.
- Omit source subsections with no items.

## Report layout

```markdown
# Oncall Handoff — {start} to {end}

## Executive summary

2–4 sentences covering the shift's main themes, outcomes, and most important remaining risks.

## Topics

### {Initiative, incident, or product area}

1–3 sentences connecting the related work and explaining why it mattered.

- **Progress:** What changed or was completed during the shift.
- **Current state:** Where the work stands now, including blockers or unresolved questions.
- **Next step:** The concrete follow-up, owner, or decision needed.
- **Evidence:** [GitHub #123](url), [Asana task](url), [Slack thread](permalink)

## Other work completed

- **YYYY-MM-DD** — [Item](url): concise outcome

## Other items to hand off

- **YYYY-MM-DD** — [Item](url): current state and next step
```

- Organize the report around **3–6 larger topics** when the evidence supports them.
- Group across platforms. A PR, its Asana task, and related Slack coordination should normally become one topic.
- Name topics for the initiative or problem, not the source tool. Prefer “FigJam Links in Make rollout” over “GitHub and Slack.”
- Connect evidence through shared product area, experiment, incident/root cause, customer problem, dependency, or owner. Do not group items merely because their dates match.
- Explain the throughline: what prompted the work, what changed, why it matters, and what remains.
- Keep claims grounded in the evidence file. Mark unknown status as unknown instead of inferring resolution.
- Include direct links in each topic's **Evidence** line.
- Put meaningful but ungrouped completed work under **Other work completed**.
- Put every ungrouped open item or oncall ping under **Other items to hand off**. Never drop an open item just because it does not fit a larger theme.
- Omit empty fallback sections.

## Workflow

1. Resolve the shift window and both output paths.
2. Check both paths for existing files and obtain overwrite approval where required.
3. Gather and classify GitHub, Asana, and Slack evidence using the source rules below.
4. Write the complete evidence file.
5. Read the saved evidence file from disk.
6. Identify repeated entities and themes across sources, then draft the contextual report.
7. Audit coverage before writing:
   - Every handoff item from evidence appears in a topic or **Other items to hand off**.
   - Every topic cites at least one evidence link.
   - No report claim depends on context absent from the evidence file.
8. Write the report and return both paths.

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

For open PRs, inspect the PR details and checks to capture the actual blocker, requested review, or remaining work. For merged PRs, add a short outcome only when the title does not make the larger topic clear.

## Source: Asana

No dedicated oncall board — query tasks assigned to the user. Read the Asana token from `~/.config/api-tokens.json` (key: `asana`).

```
curl -s -H "Authorization: Bearer $ASANA_TOKEN" \
  "https://app.asana.com/api/1.0/tasks?workspace=10497086658021&assignee=1207856102142357&completed_since={start}&opt_fields=name,completed,completed_at,modified_at,projects.name,permalink_url&limit=100"
```

`completed_since={start}` returns incomplete tasks plus tasks completed after the shift start. From the results:
- `completed == true` AND `completed_at` within the window → **Worked on**
- `completed == false` AND `modified_at` within the window → **To hand off**

Preserve `projects.name` in the evidence context because project membership is often the best signal for thematic grouping.

Escape any `$` in task names (Obsidian/markdown renders `$...$` as LaTeX).

## Source: Slack

Two streams, searched across all public + private channels via `mcp__plugin_slack_slack__slack_search_public_and_private`.

Parameters: `channel_types: public_channel,private_channel`, `sort: timestamp`, `sort_dir: asc`, `response_format: concise`, `limit: 20`. Paginate through all results.

### Stream 1 — my messages → Worked on

```
query: "from:<@U06MUPSF2BX> after:{start-1d} before:{end+1d}"
```

Filter to **moderate+ signal** — keep answers, guidance, coordination; drop one-word replies, "thanks", "lol", emoji-only. Each entry: `- **YYYY-MM-DD** — [#channel](permalink): what I said/did`.

Consolidate adjacent messages from the same thread into one evidence entry when they represent a single action or update. Preserve the permalink to the most informative message.

### Stream 2 — `@adoption-oncall` pings → To hand off

Search for mentions of the group (subteam `S09NETP4P6Z`, handle `adoption-oncall`):

```
query: "adoption-oncall after:{start-1d} before:{end+1d}"
```

**Do not auto-classify resolution.** List every ping from the shift under **To hand off → Slack**, each with a permalink and a 1-line summary of the request. This biases toward over-surfacing — the user deletes the ones they actually closed when curating the file.

Every Slack entry MUST include a permalink.

## Principles

- **Evidence first:** Keep source collection separate from synthesis so the handoff can be regenerated or reworked without querying every service again.
- **Topics over tools:** Use GitHub, Asana, and Slack as corroborating evidence for a shared initiative, not as the report's organizing structure.
- **Context over inventory:** Explain relationships, outcomes, blockers, and next steps instead of copying a task list into the handoff.
- **Complete evidence:** Preserve both retrospective work and forward-looking handoff items in the evidence file.
- **Bias toward surfacing** open items — better to over-hand-off than drop a request.
- **Editable output:** both files are meant to be hand-curated; never overwrite either without asking.
