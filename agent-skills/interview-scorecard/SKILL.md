---
name: interview-scorecard
description: Turn coding interview notes into scorecard answers covering progress and section timing, hints and the candidate's response, strengths and areas for improvement, and the CoderPad link. Use when the user provides interview notes or asks to draft an interview scorecard.
---

# Interview scorecard

Turn the user's interview notes into concise, paste-ready answers to the four questions below. Use the supplied notes and any exercise description, rubric, or artifacts the user provides. If no notes are available, ask for them and the CoderPad link in one message. Otherwise, draft all four answers immediately. Put material gaps or contradictions in a short follow-up list after the draft, without delaying supported answers.

## Evidence rules

- Preserve the interviewer's meaning and uncertainty. Ground evaluative claims in specific observed behavior. Do not invent actions, timestamps, hints, test results, or links.
- Separate what the candidate discussed, attempted, implemented, tested, and completed. Distinguish independent work from work completed after help. A working final solution does not erase the help needed to reach it.
- Calculate section durations only from clear timestamps or explicit durations. Distinguish elapsed timestamps from time spent. Preserve approximate times as approximate. If a transition is missing, say the section timing was not recorded rather than allocating time by guesswork.
- Missing evidence is "Not recorded," not evidence of failure or independence. Do not turn silence about hints into "No hints were given," or silence about weaknesses into "No weaknesses."
- Keep feedback about demonstrated work and interview behavior. Do not infer personality, demographic traits, or an overall hiring recommendation or numerical rating. If the user separately requests a rating, use their supplied rubric and state evidence limits.
- Copy any supplied CoderPad URL exactly. Do not invent a link or claim to have inspected its contents unless you actually did. If several links have unclear ownership, flag the ambiguity.

## Output

Use these four numbered headings in this order. Write in the interviewer's voice with short paragraphs or bullets that can be pasted into the scorecard. Include only dimensions supported by the notes. Avoid generic praise or criticism.

### 1. How far did they get? How long did they take on each section?

Describe the furthest stage reached and what remained incomplete. For each named section, report its outcome and recorded duration or supported time range. Distinguish implemented code from demonstrated correctness, including whether tests ran and what they established. Mark unavailable section timing as "Not recorded."

### 2. What hints/help did you give? How specific were your hints? Was the candidate able to understand or use them?

Report each recorded intervention in context. State what I supplied, how specific it was, and what the candidate did afterward. Describe specificity in concrete terms, such as an open-ended prompt, a pointer to an edge case, a suggested approach, or exact code or a solution step. Preserve the distinction between a clarification and help that supplied part of the solution.

State whether the candidate understood and applied each hint when the notes show this. Distinguish immediate use, partial use, repeated prompting, and inability to apply it. If the response is unclear, say it was not recorded. Paraphrase hints unless the notes provide exact wording. Do not place paraphrases in quotation marks.

### 3. What did the candidate do well? What could the candidate have done better?

Use two short groups, "Did well" and "Could have done better." Tie each point to an example from the notes. Relevant evidence may concern problem decomposition, implementation, correctness, testing, debugging, communication, or use of feedback. Describe how assistance affected the result when relevant. Preserve mixed evidence rather than smoothing it into a uniformly positive or negative assessment. If either group has no supporting evidence, say "Not recorded."

### 4. CoderPad link

Include the supplied link. If absent, write "Not provided."

## Final check

Check that every claim is supported, timing arithmetic is consistent, and every recorded hint retains its specificity and the candidate's response. Keep unsupported details out of the draft. Ask only focused follow-up questions that could fill meaningful gaps, such as a missing section boundary or an unclear response to a hint. Do not add extra scorecard categories unless requested.
