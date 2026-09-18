# <Project name>

> Use this as a compact reading order, not a checklist of sections to fill. Merge or omit sections that add no distinct information. Remove authoring prompts and unknown metadata.
> Keep the technical solution as the main explanation. State requirements once, put rationale beside decisions, and include a diagram only when it explains something prose cannot explain as clearly.

Status: Draft

Updated: <YYYY-MM-DD>

Related work: <Brief, issue, or design, if available>

## Summary

<Two or three sentences with the problem, recommended technical approach, and effect on users. Move status detail and ordinary open questions to their sections. If a central mechanism remains unresolved, state that the design is incomplete and name the blocker.>

## Behavior and scope

<Summarize the entry point, intended outcomes, meaningful variants, and exclusions in a short paragraph or table. Link an existing brief for settled detail. Keep product hypotheses distinct from required behavior.>

## Open questions

<Collect unresolved decisions that need reviewer input in one short list or table. Omit this section when there are none. Keep central architectural blockers in Proposed design.>

## Proposed design

<Make this the majority of the spec. Start with the solution outline: existing components being changed, proposed additions, responsibilities, and connections. Include current behavior only where it explains a decision.>

<Use editable Mermaid only when a diagram clarifies boundaries, non-obvious ordering, or lifecycle. Omit linear flows that one sentence explains just as well.>

<Organize subsections around this solution's mechanisms. Trace execution and data ownership through named components. Define changed contracts, state lifetime, and consequential recovery or concurrency behavior. Use a compact table or code sketch where it clarifies the contract; link unchanged APIs instead of copying them.>

<Recommend consequential choices and explain the tradeoff beside each one. Link source claims to a revision. If feasibility is unverified, give the bounded investigation that would decide it.>

## Tracking

<When tracking matters, use a short outcome table that shows Existing signal and Required change. Prefer extending existing events or operation-level flows. Add a top-level signal only when existing events cannot establish the outcome. Omit this section when the change needs no tracking.>

## Risks

<Use a short bullet list of material risks or unresolved dependencies. Each bullet names the risk and its mitigation or next decision. Keep detailed reasoning in the design. Omit hypothetical edge cases and risks that do not affect the proposal.>
