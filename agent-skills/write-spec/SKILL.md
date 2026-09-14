---
name: write-spec
description: Interview the user using jimmy-mode and draft a technical spec from the bundled template. Use for "interview me into a spec", "help me spec this", or an interactive spec-writing session. A request to review an existing spec alone does not start an interview.
---

# Write Spec

Turn an idea into a local, reviewable spec through investigation and an interview. Keep the draft aligned with decisions as they settle.

## Ground the session

Read and apply [jimmy-mode](../jimmy-mode/SKILL.md) and [grilling](../grilling/SKILL.md). Use jimmy-mode's Investigation playbook for research. This workflow owns the interview and document output. Writing the spec does not include implementing the feature or publishing it.

Read the bundled [spec template](assets/template.md), or a different template explicitly chosen by the user. Resolve asset paths from this skill's directory. Use the selected template throughout the interview and draft. Do not duplicate its sections in these instructions.

Read the existing conversation, supplied brief, and any spec being revised. Inspect relevant project guidance and enough source material to distinguish current behavior from the proposal. Reuse settled answers. If the idea itself is missing, ask what the user wants to spec before exploring a codebase.

## Interview

Use the template's required core and applicable optional sections to track coverage. For each gap, distinguish a fact to investigate, a user decision, and a nonblocking assumption. Start with decisions that change the goal, scope, or downstream choices.

Follow grilling's one-question-at-a-time loop. Give a recommended answer with its main tradeoff. Use the runtime's question tool when available. Wait for the answer before asking the next question. Independent research can continue while a question is pending.

Investigate observable facts through source, documentation, or proportionate read-only checks. Do not ask the user to guess existing behavior. If evidence is unavailable, record the limitation. Ask the user when the unresolved choice concerns desired behavior, priorities, or an accepted tradeoff.

Test answers against concrete scenarios and earlier decisions. When answers conflict, explain the consequence and resolve that conflict before dependent choices. Cover materially different user states and recovery outcomes where they affect the proposal. Skip branches that do not apply.

Record recommendations as proposals until the user chooses them. Label delegated judgment and assumptions so they cannot be mistaken for user decisions or verified facts.

## Keep the draft current

Once the problem and initial scope are clear, create `specs/<short-project-name>.md` in the active project unless the user names another destination. Update a named existing spec in place. Otherwise choose an unused filename and leave existing work intact.

Keep status Draft during the interview. Record settled decisions, source evidence, and open questions in the document as they emerge. When an answer changes, reconcile affected requirements, design choices, and checks instead of appending contradictory notes. Keep the question queue in the open-questions section so a later session can resume.

Use the template's reading order and applicability rules. Remove unused optional sections and authoring prompts. Keep unanswered material questions explicit, with owners and deadlines only when known. Do not invent reviewers, approvals, measurements, estimates, or source revisions to fill cells.

Apply [technical-writing](../technical-writing/SKILL.md) and [unslop](../unslop/SKILL.md). Keep requirements distinct from implementation choices, and product hypotheses distinct from correctness checks. Link source claims to their revision and observations to dated evidence.

## Finish

Stop interviewing when the core is coherent, each required behavior has an observable acceptance check, and remaining questions can be deferred explicitly. Do not require every implementation detail or optional section to be settled. If the user asks to draft now or stop, save the current draft and expose the unresolved decisions.

Read the saved file against the actual template and the user's answers. Check for contradictions, unsupported claims, missing behavior variants, and checks that would pass despite violating a requirement. Distinguish planned verification from checks already run. Keep status Draft unless the requested lifecycle transition is supported by an actual review or delivery evidence.

Return the spec link, the consequential decisions, and any blockers to review or implementation. State that acceptance checks are planned unless they were run. Do not ask for another confirmation merely to save or hand back the draft.
