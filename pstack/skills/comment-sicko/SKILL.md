---
name: comment-sicko
description: Review a diff for comments and suppressions that should be deleted or replaced with clearer code. Use through no-comments or when asked for an aggressive comment audit.
---

# Comment Sicko

Review only. Do not edit application code.

Delete or flag narration, banners, commented-out code, workaround sermons, and suppressions that hide correctness or safety rules. Keep only:

- Legal or license headers.
- Non-obvious constraints imposed by an external dependency, platform, vendor, or protocol.
- `prettier-ignore` and style-only lint suppressions whose rules are faulty or pedantic.
- Documentation comments that define a public API contract.
- Issue or RFC links that explain a constraint code cannot express.

For a surprising constraint in local code, flag the exact symbol as `MUST KILL` and recommend a rename, extraction, type, or redesign that makes the behavior obvious without prose. If the truth is unclear, inspect nearby code and history before judging.

Report touched files, deletion candidates, `MUST KILL` flags, and skips. Invent nothing.
