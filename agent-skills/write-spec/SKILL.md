---
name: write-spec
description: Investigate the codebase, interview the user using jimmy, and develop a technical proposal with concrete mechanisms and tradeoffs. Use for "interview me into a spec", "help me spec this", or an interactive spec-writing session. A request to review an existing spec alone does not start an interview.
---

# Write Spec

Turn an idea into a concise local technical proposal an engineer can review and implement without rediscovering the architecture. Explain what changes in the system, how it works, and why the approach fits the constraints. Keep routine coding choices open.

For an ordinary feature, aim for roughly 1,000 to 2,000 words in the main spec; small changes need much less. This is a drafting target, not a quota or hard limit. Expand for decisions the reviewer needs or depth the user requests, not to reproduce the investigation. Keep the technical solution as the majority of the document.

## Ground the session

Read and apply the installed `jimmy:jimmy` skill and [grilling](../grilling/SKILL.md). Use jimmy's Investigation playbook for research. This workflow owns the interview, document structure, and stopping condition. Writing the spec does not include implementing the feature or publishing it.

Read the bundled [spec template](assets/template.md), or a different template explicitly chosen by the user. Resolve asset paths from this skill's directory. Use the selected template throughout the interview and draft. Do not duplicate its sections in these instructions.

Read the existing conversation, supplied brief, and any spec being revised. Inspect relevant project guidance and enough source material to distinguish current behavior from the proposal. Reuse settled answers. If the idea itself is missing, ask what the user wants to spec before exploring a codebase.

## Investigate and interview

Start with the problem and scope, then identify the engineering uncertainties that could change feasibility or architecture. Investigate those early. Use the template to check coverage without turning every heading or possible edge case into an interview question.

For each gap, distinguish an observable fact, a technical choice to develop, and a user decision about desired behavior or an accepted tradeoff. Investigate facts through source, documentation, or proportionate read-only checks. Develop technical recommendations from that evidence. Ask the user about desired behavior, priorities, and consequential tradeoffs; do not ask them to supply facts or routine engineering choices you can work out.

Before proposing a new asset, configuration, endpoint, or workflow, search for an existing one that can serve the same purpose. State verified reuse directly. If suitability still needs a product decision, put that decision in Open questions instead of presenting a new implementation as settled.

Follow grilling's one-question-at-a-time loop. Give a recommended answer with its main tradeoff. Use the runtime's question tool when available. Wait for the answer before asking the next question. Independent research can continue while a question is pending.

Test answers against concrete scenarios and earlier decisions. When answers conflict, explain the consequence and resolve that conflict before dependent choices. Cover materially different user states and recovery outcomes where they affect the proposal. Skip branches that do not apply.

Record recommendations as proposals until the user chooses them. Label delegated judgment and assumptions so they cannot be mistaken for user decisions or verified facts.

## Develop the technical proposal

Outline the technical solution before expanding the document. Name the existing components being changed and clearly identify proposed additions, their responsibilities, and the connections between them. Establish that structure before expanding supporting detail.

For changes spanning components or introducing a workflow, consider whether a diagram would make a relationship, ordering constraint, or lifecycle easier to understand. Use a component diagram for boundaries, a sequence diagram for non-obvious ordering, or a state diagram for lifecycle. Each diagram must answer a distinct question. Omit a linear flow that one sentence explains just as well. Do not repeat a diagram step by step in prose. Prefer editable Mermaid unless the user chooses another format.

Use concrete component names and label what is existing, changed, or proposed. Explain the design choices shown in each diagram, then connect them to the relevant contracts and failure behavior. Check that the diagrams agree with the prose. Generic boxes such as "frontend → backend → database" do not explain the proposed change.

Trace execution through the proposed responsibilities, including where data moves and who owns state. Define changed contracts with concrete fields, states, signatures, or examples where needed to explain the design. Link unchanged contracts instead of copying them.

For changes that need tracking, inspect existing analytics and operational instrumentation in the affected flow. Show the outcome to measure, what already records it, and what this change must add. A short table with Existing signal and Required change columns usually makes the gap clear. Prefer extending an existing event or operation-level flow over adding feature-specific instrumentation. Name a new top-level signal only when existing events cannot establish the outcome. Distinguish proposed tracking from verified coverage and keep the account short.

For consequential choices, recommend an approach and explain why it fits better than credible alternatives. A recommendation can be ready for review before the user accepts it. Do not leave a central mechanism as "choose storage", "extend this path or add another", or "ensure recovery". Explain the mechanism that produces the required outcome. For example, a proposal to transfer a draft between screens must identify where it lives, how the destination finds it, and when it is consumed or removed.

Trace failures through that same design. Where relevant, explain state after partial completion, retry behavior, and how concurrent actors or old and new versions interact. Start with the smallest control that fits the real entry point. For example, a synchronous in-flight guard and a disabled button may be enough for a one-time UI action. Add durable recovery or idempotency only when work can outlive that control or partial completion creates state the user must recover. A local behavior change does not need invented APIs, storage, or migrations.

Check feasibility assumptions against the available evidence. If a central choice cannot yet be supported, identify the missing evidence and a bounded investigation that would decide it. Continue independent work, but mark the technical design incomplete. Moving an architectural question into Open questions does not make the design complete. Do not invent existing capabilities or claim verification to satisfy the template.

## Keep the draft current

Once the problem and initial scope are clear, create `specs/<short-project-name>.md` in the active project unless the user names another destination. Update a named existing spec in place. Otherwise choose an unused filename and leave existing work intact.

Keep status Draft during the interview. Record decisions, reasons, supporting evidence, and material open questions as they emerge. When an answer changes, reconcile the draft instead of appending contradictory notes. Collect unresolved review decisions in one short Open questions section so a reviewer can find them without scanning the document. Keep context beside the affected design, but do not repeat or scatter the question. A central architectural mechanism remains part of the proposed design and cannot be deferred by listing it as an open question.

Use the template's reading order, merging or omitting sections that add no distinct information. Write the proposal for people deciding whether the design is sound. Include the components, contracts, and failure behavior needed for that decision. Cut exact hook ordering, internal method steps, standard interaction behavior, and defensive checks unless correctness or a consequential tradeoff depends on them. Add an implementation plan only when sequencing itself needs review. Remove authoring prompts and empty metadata; do not invent owners, dates, approvals, measurements, or estimates.

Write for an engineering reviewer who has not seen the conversation. State each requirement once. Use a concrete noun whenever terms such as "variant", "state", "copy", or "landing" could refer to more than one thing. Label proposals without narrating interview progress or repeating confirmation disclaimers.

Apply the installed `jimmy:technical-writing` and `jimmy:unslop` skills. A spec combines a design argument with the contracts needed to review it; do not split those apart merely to satisfy a documentation-mode rule. Keep requirements distinct from implementation choices, and product hypotheses distinct from correctness checks. Link source claims to their revision and observations to dated evidence.

## Finish

Stop interviewing when the material user decisions are settled. Continue the engineering investigation and synthesis needed to make the proposal reviewable. Read the saved file against the template, evidence, and user's answers. Check that:

- The solution outline and any useful diagrams show the proposed structure and behavior. A reviewer can trace the main flow through named components and understand what changes in each. A direct explanation is enough when a diagram would repeat it.
- State ownership, changed contracts, and relevant recovery mechanisms are concrete and consistent with the required behavior.
- Consequential choices have recommendations, reasons, and credible alternatives where applicable.
- Remaining review decisions appear once in Open questions. Architectural blockers stay explicit in the proposed design.
- Tracking shows verified existing signals and the smallest additions needed to measure delivery and use.

Do not require every implementation detail or optional section to be settled. If the user asks to draft now or stop, save what is available. If architectural blockers remain, say the technical design is incomplete in the Summary and handoff, and name the investigation or decision needed. Interview completion alone does not establish a reviewable design.

If the spec contains diagrams, render them with available tooling and inspect the output for syntax errors, unreadable labels, and inconsistencies with the prose. Fix defects before handing back the spec. If rendering is unavailable, say the diagrams are unverified in the handoff.

Before handoff, make a compression pass: remove repeated requirements, diagrams that restate one sentence, routine implementation instructions, obvious default interaction behavior, and checklists that do not change a design decision. Keep the mechanisms, consequential recovery behavior, tradeoffs, and architectural blockers. Check for contradictions, ambiguous nouns, and unsupported claims. Distinguish planned verification from checks already run. Keep status Draft unless actual review or delivery evidence supports a transition.

Return the spec link, the consequential decisions, and any blockers to review or implementation. Do not ask for another confirmation merely to save or hand back the draft.
