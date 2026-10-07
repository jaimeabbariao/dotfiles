---
name: oncall-report
description: Generate an oncall-only adoption shift evidence log and handoff from GitHub, Linear, and Slack. Include incidents and support requests; exclude routine project work.
---

# Oncall report

Save source-linked oncall evidence, then read the saved file to write a handoff organized around incidents and support requests. Preserve unresolved oncall requests even when they do not fit a topic.

## Resolve the shift and outputs

Accept `/oncall-report [YYYY-MM-DD]` or `$oncall-report [YYYY-MM-DD]`. The date is the shift start. Without a date, use the most recent Monday in the user's timezone.

Use seven calendar days, from midnight on `start` inclusive to midnight on `end = start + 7 days` exclusive. Use the user's timezone, defaulting to `America/New_York`. Filter source timestamps to this window after searching. Source queries may fetch a wider range.

- Evidence path. `/Users/jabbariao/db/oncall/evidence/{start}.md`.
- Report path. `/Users/jabbariao/db/oncall/report-{start}.md`.

Check both paths before writing. If either exists, warn the user and obtain approval for that specific file before overwriting it. Both files may contain hand-curated edits. If the user requests synthesis from existing evidence, read that file and preserve it.

## Filter to oncall work

Include an item only when source evidence ties it to an explicit adoption-oncall request, an incident alert, a support or bug-triage request, or a fix/review/ownership follow-up for one of those requests. Record that connection in the evidence context.

Authorship, assignment, project membership, an Adoption channel, and an in-window timestamp identify candidates, not oncall relevance. Exclude routine project implementation, feature rollout, research, localization, project permission requests, planned cleanup, historical backlog, and personal or tooling discussions unless a specific oncall request establishes the connection. Exclude uncertain project candidates rather than inventing an oncall origin.

Keep incident response involving a project area when its oncall origin is explicit. For example, a NUX E2E alert and its remediation belong here; the NUX template implementation stack does not. Apply this filter before classifying items as worked on or to hand off, and before saving evidence.

Every adoption-oncall group ping is an oncall intake item. Preserve the ping for curation even if it says to ignore a notification. Linked project tasks provide only the context needed to understand the oncall request; do not expand them into a project progress report.

## Collect evidence

Read the available tool schemas before calling connectors. Paginate every source to exhaustion. If access fails or results remain truncated, record the gap in the evidence and final response. Do not present an incomplete collection as exhaustive.

| Source | Identity or scope |
|---|---|
| GitHub | `figma/figma`, author `jaimeabbariao` |
| Linear | Jaime Louis Abbariao, `jabbariao@figma.com` |
| Slack author | `U06MUPSF2BX` |
| Slack group | `adoption-oncall`, subteam `S09NETP4P6Z` |

### GitHub

Collect PRs created during the shift, including all states. With authenticated `gh`, use this query as a starting point. Raise the limit or paginate if it truncates results.

```sh
gh pr list --repo figma/figma --author jaimeabbariao \
  --search "created:{start}..{end}" --state all \
  --json number,title,url,state,createdAt,mergedAt --limit 100
```

Filter `createdAt` to the shift window and apply the oncall relevance rule. Treat PRs linked from oncall requests as supporting context even when another person authored them or they were created before the shift. Classify the current state of relevant PRs as follows.

- `MERGED`. Worked on this shift.
- `OPEN`. To hand off.
- `CLOSED` without a merge. Omit.

Inspect open PR details, reviews, and checks for remaining work or blockers. Mark missing status as unknown. Add an outcome to merged PRs when the title does not explain the initiative. These rules use current state at collection time, not reconstructed state at shift end.

### Linear

Use the connected Linear tools. Resolve the user by the email above with `get_user`, then query by the returned ID. Use `me` only after verifying that the connected account matches.

Call `list_issues` with that assignee, `updatedAt` at or slightly before the shift start, and `includeArchived: true`. Request `id`, `title`, `url`, `status`, `statusType`, `completedAt`, `updatedAt`, `project`, and `team`. Follow `cursor` while `hasNextPage` is true. Do not restrict to one team or filter out completed issues at query time.

Apply the oncall relevance rule to assigned-issue candidates. Assignment and recent updates alone do not establish oncall work. Also inspect issues linked from oncall requests regardless of assignee. Classify relevant issues using returned timestamps and status types, not team-specific status names.

- `statusType == completed` and `completedAt` within the shift. Worked on this shift.
- Nonterminal status and `updatedAt` within the shift. To hand off. Terminal types are `completed` and `canceled`.
- Canceled issues or issues outside those timestamp rules. Omit.

If required fields are absent, fetch issue details. Resolve unfamiliar states through the team's issue statuses rather than guessing. For handoff items, read issue details and relevant comments or blocking relations to identify the actual current state and next step. Record unknowns explicitly.

Preserve the issue identifier, title, URL, status, team, and project context. Escape `$` in titles for Obsidian. As with PRs, classify current state at collection time. Do not infer historical completion for reopened issues.

### Slack

Search all public and private channels using `slack_search_public_and_private`. Use `channel_types: public_channel,private_channel`, `sort: timestamp`, `sort_dir: asc`, `response_format: concise`, and `limit: 20`. Leave `include_bots` off. Rotation posts otherwise bury the requests. Bot-only alerts are outside this collection.

Use the connector's current query fields. For tools with separate fields, put author and dates in `filters` and group text in `keywords`. Search a wider date range, then filter each result timestamp to the exact shift window.

- My messages. `from:<@U06MUPSF2BX> after:{start-1d} before:{end+1d}`. Keep oncall answers, incident triage, and support coordination under Worked on this shift. Exclude project discussions and unrelated activity. Drop acknowledgments, one-word replies, and emoji-only messages. Consolidate adjacent messages from the same thread when they describe one action. Link the most informative message.
- Group pings. `adoption-oncall after:{start-1d} before:{end+1d}`. Search the plain handle, not raw `<!subteam^...>` syntax. Put every ping under To hand off, with the request and a one-line current-state summary. Do not infer resolution or remove a ping because a related PR merged. The user curates closed pings later.

Every Slack entry requires a permalink. Read thread context when needed to explain a request or action.

## Save evidence before synthesis

Use this structure. Keep the two main section headings even when empty because the coverage checker reads `## To hand off`. Omit empty source subsections. Replace example dates and URLs with source values.

```markdown
# Oncall Evidence — {start} to {end}

## Worked on this shift

### GitHub
- **YYYY-MM-DD** — [#123](url) Title
  Oncall request or incident connection, and outcome.

### Linear
- **YYYY-MM-DD** — [ADOPT-123](url) Title
  Oncall request or incident connection, team, status, and outcome.

### Slack
- **YYYY-MM-DD** — [#channel](permalink): what I said or did

## To hand off

### GitHub
- **YYYY-MM-DD** — [#123](url) Title
  Current state, blocker, or remaining work.

### Linear
- **YYYY-MM-DD** — [ADOPT-123](url) Title
  Team, project, current state, and remaining work.

### Slack
- **YYYY-MM-DD** — [#channel](permalink): the request
  Current state or unknown, and what is still needed.
```

Preserve dates, titles, project or channel names, and direct links. Give every handoff item a one-line current-state summary. Keep each item's link on its `- **YYYY-MM-DD**` line for the checker.

Write the complete evidence file, then read it from disk. Draft report claims only from that saved evidence. If additional context is needed, add source-linked context to the evidence before using it in the report.

## Write the contextual handoff

Group related oncall evidence across sources by incident, support request, customer problem, or ownership follow-up. Do not include project progress topics. Shared dates alone do not establish a topic. Aim for 3–6 topics when supported by the evidence. Do not force unrelated items into themes.

For each topic, explain what prompted the work, what changed, why it matters, and what remains. Mark unknown status as unknown. Name a next-step owner only when the evidence identifies one.

```markdown
# Oncall Handoff — {start} to {end}

## Topics

### {Incident or support request}

1–3 sentences connecting the related work and explaining why it mattered.

- **Progress:** What changed or was completed during the shift.
- **Current state:** Status, blockers, and unresolved questions.
- **Next step:** Concrete follow-up, known owner, or decision needed.
- **Evidence:** [GitHub #123](url), [Linear ADOPT-123](url), [Slack thread](permalink)

## Other work completed

- **YYYY-MM-DD** — [Item](url): concise outcome

## Other items to hand off

- **YYYY-MM-DD** — [Item](url): current state and next step
```

Every topic needs direct evidence links. Put meaningful ungrouped completed oncall work in Other work completed. Put every ungrouped open item or oncall ping in Other items to hand off. Omit empty report sections.

## Verify and return paths

Write the report, then run the bundled checker. Resolve its path relative to this skill directory, not a particular agent installation.

```sh
python3 {skill_dir}/scripts/check_coverage.py {evidence_path} {report_path}
```

Fix missing items until the check passes. It verifies that at least one link from each handoff entry appears in the report. It does not detect linkless entries, validate claims, or prove collection completeness.

Read the saved report and evidence. Check that every handoff entry has a link and appears with its current state and next step. Check that every topic cites evidence and every claim is grounded in the evidence file. For every retained item, verify the source-backed oncall connection. Remove routine project work from both files even if its links pass coverage.

Return both absolute paths and any source gaps. Do not preview either document in chat before writing.
