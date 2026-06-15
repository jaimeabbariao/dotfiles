---
name: describe-my-pr
description: A skill that takes all relevant commits in the branch to create a title for the PR and also a succinct description that explains the motivation for the changes
---

Based on the changes committed within the branch, create a PR title and a description.

The description should be concise and explains the motivation for the changes such that people with little to no context
can be easily brought up to speed

## Scope the diff to the PR's actual base branch

Always describe the changes relative to the PR's **base branch**, which is not necessarily `master`.
Branches are often stacked, so diffing against `master` pulls in commits owned by parent PRs and
produces a description that overstates the scope.

If a PR already exists, look up its base before diffing:

```sh
gh pr view --json baseRefName,headRefName
```

Then scope the diff to that base (e.g. `git diff <baseRefName>...HEAD`). Only describe what this
branch adds on top of its base; work that landed in a parent/base branch belongs to that branch's
PR, not this one.

