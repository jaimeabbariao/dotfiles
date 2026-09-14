# <Project name>

> Copy this file into a new spec. Replace the prompts with decisions and evidence, then remove this note.
> The required core is Summary, Problem and current behavior, Goals and non-goals, Required behavior, Proposed design, and Acceptance checks.
> For small changes, combine adjacent sections or use a paragraph where a table adds no value. Keep each core question answered.
> Include sections marked optional when their stated condition applies. Remove unused headings and prompts.
> Mark unresolved decisions explicitly. A proposed design is not a verified fact.

| Field | Value |
| --- | --- |
| Status | Draft / In review / Accepted / Implemented / Superseded |
| Author | <Name> |
| Reviewers | <People responsible for affected systems and decisions> |
| Updated | <YYYY-MM-DD> |
| Source revision | <Repository and commit permalink for source claims, when applicable> |
| Related work | <Links to product brief, issue, designs, or prior decisions> |
| Accepted review | <Link to the approval and later material amendments, when available> |
| Implementation | <Links to delivered changes and verification evidence, when available> |
| Superseded by | <Replacement spec, if any> |

Keep this spec current through delivery. Accepted means reviewers approved the intended behavior and design. Before marking it Implemented, reconcile the spec with delivered behavior and link the verification evidence. Record reasons for material changes alongside the linked reviews. When replaced, mark it Superseded and link the new spec. Retain this document as history.

## Summary

<In one short paragraph, explain the problem, the proposed change, and the effect on users. Include one concrete before-and-after example.>

<State what feedback or decision you need from reviewers. Name the largest uncertainty if it affects the approach or estimate.>

## Problem and current behavior

<Who encounters the problem? What happens today, and why is that insufficient? Include evidence or a reproducible example.>

<Describe the existing flow and the constraints the design must respect. Use commit permalinks for source claims. Date measurements and runtime observations, and record their environment and reproduction method. The document's Updated date does not date its evidence. Separate verified facts from assumptions.>

## Goals and non-goals

List the outcomes this change must achieve.

- <Observable user or system outcome. Distinguish required functionality from a hypothesis about product improvement.>

List explicit exclusions that a reviewer might otherwise expect.

- <Excluded behavior or adjacent work, with a brief reason.>

## Required behavior

State the behavior an implementation must preserve regardless of its internal design. Distinguish binding requirements from illustrative examples.

### Main flow

Describe the main request or user action from start to finish. State who is eligible and the relevant starting conditions.

1. <Trigger, input, and entry point.>
2. <Actions the user or caller can take and the system's observable responses.>
3. <Visible result and persisted state.>

### Variants and invariants

<Cover materially different starting states and ordinary actions, such as existing data, editing, clearing, cancellation, re-entry, or reload. State the rules that hold across these cases. Use the table when behavior branches; otherwise use prose.>

| Starting condition | Action or event | Required result and remaining state |
| --- | --- | --- |
| <Relevant user or system state> | <Action or event> | <Observable response and what persists> |

### Failure behavior

<Describe the failures that could change the outcome, such as invalid input, denied access, unavailable dependencies, or partial completion.>

<For each relevant failure, state what the user sees, what state remains, and what recovery must achieve. Address retries, duplicate requests, and concurrent changes where applicable.>

## Proposed design

<Explain how the chosen approach satisfies Required behavior and why it fits the problem. Trace the work through the responsible components, including recovery. Identify implementation choices that remain open without changing the required outcomes.>

<Add a diagram only if it makes ownership, sequencing, or data movement clearer.>

### Data and contracts

<Define the relevant entities and states. Identify the source of truth, who can change it, and how the design enforces the required invariants.>

<Describe changed APIs, events, schemas, or configuration. Include concrete inputs, outputs, and errors where needed. Link to existing contracts instead of repeating them.>

<If applicable, explain compatibility with existing callers and stored data. Describe migrations, backfills, and behavior while old and new versions coexist.>

### Operational constraints (optional)

<Include only applicable constraints. Cover authorization, sensitive data, retention, accessibility, latency, capacity, or cost where the change affects them. State concrete limits and how the design meets them.>

### Decisions and alternatives (optional)

Use this section for consequential choices that need more explanation than the design summary. Include keeping the current behavior when that is a viable option.

| Decision | Chosen approach and reason | Alternative and reason for rejecting it |
| --- | --- | --- |
| <Question> | <Choice, evidence, and accepted tradeoff> | <Credible alternative and specific drawback> |

## Acceptance checks

Connect each required behavior and invariant to an observable check. Include meaningful variants, relevant failures, risky assumptions, and existing behavior that could regress. Reference the requirement instead of restating it. Add stable labels if the spec is large.

| Requirement or risk | Check and environment | Expected evidence |
| --- | --- | --- |
| <Behavior, variant, failure case, or invariant> | <Test, manual scenario, or measurement> | <Specific result that constitutes a pass> |

<Identify anything that cannot be verified before rollout and explain how you will detect a problem in production. Link completed checks to their actual results. Planned checks are not evidence that the implementation passes.>

### Product success and experiments (optional)

Include this section when the change makes a measurable product claim or runs an experiment. Passing acceptance checks establishes correct behavior. Evaluate the product hypothesis separately.

<State the hypothesis, comparison, and eligible population. For experiments, define the assignment unit, exposure event, and treatment differences so the readout answers the intended question.>

<Define each decision metric's numerator, denominator, and observation window. Include failures in the population where required by the analysis. Name guardrails, baseline evidence, success criteria, and stopping rules. Mark unknown thresholds with an owner and a deadline before launch.>

## Implementation plan (optional)

Include this section when sequencing, dependencies, or estimates need review. Break the work into deliverable steps. Resolve uncertainties that could invalidate the design before committing to dependent work.

| Step | Deliverable | Dependencies and owner | Completion check |
| --- | --- | --- | --- |
| 1 | <Bounded change or investigation> | <Prerequisite and responsible person or team> | <Observable evidence that this step is complete> |

<If estimates are needed, give ranges and assumptions about staffing and familiarity. Distinguish engineering effort from calendar time. Name the uncertainty most likely to change the estimate.>

## Rollout and rollback (optional)

Include this section when delivery changes an existing experience, service, or stored data. A small change may need only a release and recovery sentence.

<State who owns the rollout, who receives the change first, and what must pass before exposure increases. Include flags or configuration only if needed.>

<Name the metrics, logs, or alerts used to judge the rollout. Define success thresholds, stop conditions, and the observation period.>

<Explain how to disable or revert the change. Describe what happens to data already written and any effects that rollback cannot undo.>

<If applicable, assign an owner and removal condition for temporary flags, compatibility code, or the old implementation.>

## Risks and open questions (optional)

Include this section when unresolved questions or risks need action. Separate them from accepted tradeoffs. Surface blockers in the Summary. Resolve questions that block implementation before marking the design accepted.

| Risk or question | Impact | Next action or decision needed | Owner | Needed by |
| --- | --- | --- | --- | --- |
| <Unknown or possible failure> | <What it could change or block> | <Evidence to gather, mitigation, or choice to make> | <Name> | <Date or milestone> |

## Review checklist (optional)

Use this checklist for a formal review. Remove items whose conditions do not apply.

- [ ] The problem and intended behavior are concrete.
- [ ] Goals distinguish required functionality from product hypotheses, and non-goals bound the work.
- [ ] Required behavior covers meaningful variants, invariants, and failure outcomes.
- [ ] The design explains ownership, contracts, and how it meets the required behavior.
- [ ] Important decisions include reasons and credible alternatives.
- [ ] Dependencies have owners, and blocking questions are resolved.
- [ ] Acceptance checks cover the requirements and the main risks. Product measures have defined populations and windows where applicable.
- [ ] Source claims identify their revision. Measurements and observations have dates and reproducible conditions.
- [ ] Rollout has success criteria, stop conditions, and a recovery plan.

## Supporting detail (optional)

<Link deep technical analysis, large diagrams, research, or measurement protocols that would interrupt the main argument. Keep decisions and required behavior in the core sections.>
