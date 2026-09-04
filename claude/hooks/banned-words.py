#!/usr/bin/env python3
"""Deny a Write/Edit whose new text contains a word from ~/.claude/banned-words.txt.

Documents only. The skill tree is exempt so skills can name a word to ban it.
"""
import json
import os
import re
import sys

DOC_SUFFIXES = (".md", ".mdx", ".txt", ".rst", ".adoc")
EXEMPT = ("/agent-skills/", "/.claude/skills/", "/.codex/skills/", "/.cursor/skills/", "/hooks/")
WORDLIST = os.path.expanduser("~/.claude/banned-words.txt")


def load_words():
    try:
        with open(WORDLIST) as f:
            lines = f.read().splitlines()
    except OSError:
        return []
    return [ln.strip() for ln in lines if ln.strip() and not ln.startswith("#")]


def main():
    payload = json.load(sys.stdin)
    tool_input = payload.get("tool_input", {})
    path = tool_input.get("file_path", "")

    if not path.endswith(DOC_SUFFIXES) or any(part in path for part in EXEMPT):
        return
    text = tool_input.get("content") or tool_input.get("new_string") or ""
    if not text:
        return

    hits = []
    for word in load_words():
        pattern = r"\b" + r"[\s\-]+".join(re.escape(t) for t in word.split()) + r"\b"
        if re.search(pattern, text, re.IGNORECASE):
            hits.append(word)
    if not hits:
        return

    reason = (
        f"Banned word(s) in {os.path.basename(path)}: {', '.join(hits)}. "
        f"These are listed in {WORDLIST} and must not appear in documents. "
        "Rewrite with the concrete word (see unslop rule 26), then retry."
    )
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))


main()
