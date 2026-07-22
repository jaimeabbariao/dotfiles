---
name: product-brief
description: Draft a product brief by grilling the user section-by-section, then writing a Google-Docs-ready markdown draft. Use when the user wants to write a product brief or invokes /product-brief.
---

# Product Brief

Draft a product brief through a section-by-section interview. The brief has four sections:

1. **What problem are you solving and why?**
2. **What are you thinking of building?**
3. **Why might you not build this?**
4. **What does success look like?** — a table of goals, each backed by a metric and a rationale.

The output is a markdown draft the user ports into a Google Doc.

## Flow

Work **one section at a time, in order**. For each section:

1. **Grill it.** Invoke the `grilling` skill to interview the user relentlessly about that section — one question at a time, providing a recommended answer for each, until you reach shared understanding on that section only. If a question can be answered by exploring the codebase or docs, do that instead of asking.
2. **Draft it.** Write that section's prose and show it in chat for a quick thumbs-up.
3. **Move on** to the next section once the user is happy.

Do not jump ahead — later sections build on earlier answers. Keep a running draft so the final assembly is just concatenation.

### Section-specific notes

- **Section 3 (why might you not build this?)** — keep open-ended. Don't force a fixed frame (risks, cost, opportunity cost, alternatives); follow wherever the grilling leads.
- **Section 4 (success)** — the grilling should surface a handful of goals. Each goal needs a **metric** that backs it and a **rationale** for why it's a goal. Render as a markdown table with columns `Goal | Metric | Rationale`.

## Output

After all four sections are drafted and confirmed:

- Assemble the full draft and write it to `~/db/product-briefs/<slug>.md`, where `<slug>` is a kebab-case slug derived from the brief's title.
- **If the file already exists, warn the user and ask before overwriting.**
- Also show the full draft in chat.
- After writing, report the path.

Use Google-Docs-friendly markdown so it pastes cleanly: plain `#`/`##` headings, a real markdown table, no nested/fancy constructs.

### Draft layout

```markdown
# <Product Brief Title>

## 1. What problem are you solving and why?

<prose>

## 2. What are you thinking of building?

<prose>

## 3. Why might you not build this?

<prose>

## 4. What does success look like?

| Goal | Metric | Rationale |
|---|---|---|
| <goal> | <metric> | <rationale> |
```

## Principles

- **One section at a time.** Grill, draft, confirm, then advance.
- **One question at a time** during grilling — batching questions is bewildering.
- **Explore before asking** — if the answer is in the codebase or docs, go find it.
- **Editable output** — the file is a hand-curated draft; never overwrite without asking.
