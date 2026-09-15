# <Project name>

> Use this as a compact reading order, not a checklist of sections to fill. Merge or omit sections that add no distinct information. Remove authoring prompts and unknown metadata.
> Keep the technical solution as the main explanation. State requirements once, put rationale beside decisions, and include only diagrams that answer distinct questions.

Status: Draft

Updated: <YYYY-MM-DD>

Related work: <Brief, issue, or design, if available>

## Summary

<One short paragraph: the problem, recommended technical approach, and effect on users. If a central mechanism remains unresolved, state that the design is incomplete and name the blocker.>

## Behavior and scope

<Summarize the entry point, intended outcomes, meaningful variants, and exclusions in a short paragraph or table. Link an existing brief for settled detail. Keep product hypotheses distinct from required behavior.>

## Proposed design

<Make this the majority of the spec. Start with the solution outline: existing components being changed, proposed additions, responsibilities, and connections. Include current behavior only where it explains a decision.>

<For changes spanning components or introducing a workflow, include editable Mermaid diagrams with concrete component names and labels for existing versus proposed behavior. Choose the fewest useful views. A small local change may need only a short explanation or code sketch.>

<Organize subsections around this solution's mechanisms. Trace execution and data ownership through named components. Define changed contracts, state lifetime, and consequential recovery or concurrency behavior. Use a compact table or code sketch where it clarifies the contract; link unchanged APIs instead of copying them.>

<Recommend consequential choices and explain the tradeoff beside each one. Link source claims to a revision. If feasibility is unverified, give the bounded investigation that would decide it. Keep remaining decisions with the affected design rather than repeating them in a separate risk register.>

## Validation

<Usually one or two paragraphs: how to test the risky technical claims, and what observable evidence would establish that they work. Distinguish planned checks from completed observations, with dates and environments for actual results. Avoid a requirement-by-requirement acceptance matrix.>

## Experiment and rollout (when relevant)

<For experiments, state assignment, exposure, metrics, and the success rule. Define denominators and observation windows, including failed or abandoned attempts. Mark unset thresholds explicitly. Keep a detailed analysis plan separate only if needed.>

<For rollout, explain important sequencing, production signals, stop conditions, and what disabling entry means for existing data or work in progress. Mention remaining launch decisions once. Omit experiment content for non-experiments; use a separate implementation plan only when dependencies or sequencing need review.>
