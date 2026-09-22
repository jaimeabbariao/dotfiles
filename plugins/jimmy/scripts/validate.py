#!/usr/bin/env python3

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


EXPECTED_SKILLS = (
    "architect",
    "arena",
    "automate-me",
    "blast-radius",
    "bro",
    "comment-sicko",
    "create-verification-skill",
    "figure-it-out",
    "how",
    "interrogate",
    "jimmy",
    "jimmy-agent",
    "maintain-verification-skill",
    "no-comments",
    "ponytail",
    "ponytail-debt",
    "principle-boundary-discipline",
    "principle-build-the-lever",
    "principle-encode-lessons-in-structure",
    "principle-exhaust-the-design-space",
    "principle-experience-first",
    "principle-fix-root-causes",
    "principle-foundational-thinking",
    "principle-guard-the-context-window",
    "principle-laziness-protocol",
    "principle-make-operations-idempotent",
    "principle-migrate-callers-then-delete-legacy-apis",
    "principle-minimize-reader-load",
    "principle-model-the-domain",
    "principle-never-block-on-the-human",
    "principle-outcome-oriented-execution",
    "principle-prove-it-works",
    "principle-redesign-from-first-principles",
    "principle-separate-before-serializing-shared-state",
    "principle-sequence-verifiable-units",
    "principle-subtract-before-you-add",
    "principle-type-system-discipline",
    "recall",
    "reflect",
    "setup-jimmy",
    "show-me-your-work",
    "swarm",
    "tdd",
    "teach",
    "technical-writing",
    "typescript-best-practices",
    "unslop",
    "why",
)

PONYTAIL_SKILLS = {"ponytail", "ponytail-debt"}
PSTACK_SKILLS = set(EXPECTED_SKILLS) - PONYTAIL_SKILLS
PSTACK_EXCLUDED_SKILLS = {
    "make-bot-ui": "Cursor-only automation workflow; excluded from the ChatGPT/Codex plugin."
}

TEXT_SUFFIXES = {".json", ".md", ".mjs", ".sh", ".ts", ".txt", ".yaml", ".yml"}
MARKDOWN_LINK = re.compile(r"\[[^]]*\]\(([^)]+)\)")


def frontmatter_name(path: Path) -> str | None:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        return None
    for line in lines[1:]:
        if line == "---":
            break
        if line.startswith("name:"):
            return line.removeprefix("name:").strip().strip("\"'")
    return None


def load_manifest(path: Path, errors: list[str]) -> dict[str, object] | None:
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        errors.append(f"{path}: {error}")
        return None
    if not isinstance(manifest, dict):
        errors.append(f"{path}: manifest must contain an object")
        return None
    if manifest.get("name") != "jimmy":
        errors.append(f"{path}: name must be jimmy")
    version = manifest.get("version")
    if not isinstance(version, str) or not re.fullmatch(
        r"\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?", version
    ):
        errors.append(f"{path}: version must be strict semver")
    return manifest


def validate_markdown_links(path: Path, errors: list[str]) -> None:
    text = path.read_text(encoding="utf-8")
    for target in MARKDOWN_LINK.findall(text):
        target = target.split("#", 1)[0]
        if not target or target == "url" or "://" in target or target.startswith("mailto:"):
            continue
        resolved = (path.parent / target).resolve()
        if not resolved.exists():
            errors.append(f"{path}: broken relative link {target}")


def validate_package(plugin_root: Path) -> list[str]:
    errors: list[str] = []
    skills_root = plugin_root / "skills"
    actual_skills = tuple(sorted(path.name for path in skills_root.iterdir() if path.is_dir()))
    expected_skills = tuple(sorted(EXPECTED_SKILLS))
    if actual_skills != expected_skills:
        missing = sorted(set(expected_skills) - set(actual_skills))
        extra = sorted(set(actual_skills) - set(expected_skills))
        errors.append(f"skill closure mismatch; missing={missing}, extra={extra}")

    portable = load_manifest(plugin_root / "plugin.json", errors)
    compatibility = load_manifest(plugin_root / ".codex-plugin" / "plugin.json", errors)
    if portable is not None and compatibility is not None:
        if portable.get("version") != compatibility.get("version"):
            errors.append("portable and compatibility manifest versions differ")

    sources_path = plugin_root / "SOURCES.json"
    try:
        sources = json.loads(sources_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        errors.append(f"{sources_path}: {error}")
        sources = {}
    for source_name, expected in (("pstack", PSTACK_SKILLS), ("ponytail", PONYTAIL_SKILLS)):
        declared = set(sources.get(source_name, {}).get("skills", []))
        if declared != expected:
            errors.append(
                f"{sources_path}: {source_name} skill provenance mismatch; "
                f"missing={sorted(expected - declared)}, extra={sorted(declared - expected)}"
            )
    excluded = sources.get("pstack", {}).get("excludedSkills", {})
    if excluded != PSTACK_EXCLUDED_SKILLS:
        errors.append(
            f"{sources_path}: pstack excluded skill provenance mismatch; "
            f"expected={PSTACK_EXCLUDED_SKILLS}, actual={excluded}"
        )

    for skill_name in EXPECTED_SKILLS:
        skill_file = skills_root / skill_name / "SKILL.md"
        if not skill_file.is_file():
            errors.append(f"missing {skill_file}")
            continue
        if frontmatter_name(skill_file) != skill_name:
            errors.append(f"{skill_file}: frontmatter name must be {skill_name}")

    if (plugin_root / "node_modules").exists() or any(
        path.name == "node_modules" for path in plugin_root.rglob("node_modules")
    ):
        errors.append("plugin contains node_modules")

    for path in plugin_root.rglob("*"):
        if path.is_symlink():
            errors.append(f"plugin contains symlink: {path}")
            continue
        if not path.is_file() or path.suffix not in TEXT_SUFFIXES:
            continue
        text = path.read_text(encoding="utf-8")
        legacy_name = "jimmy" + "-mode"
        if legacy_name in text:
            errors.append(f"{path}: contains legacy skill name")
        if path.suffix == ".md":
            validate_markdown_links(path, errors)

    for required in (
        plugin_root / "LICENSE.txt",
        plugin_root / "THIRD_PARTY_NOTICES.md",
        plugin_root / "SOURCES.json",
        plugin_root / "licenses" / "ponytail-MIT.txt",
        skills_root / "jimmy" / "agents" / "openai.yaml",
    ):
        if not required.is_file():
            errors.append(f"missing {required}")

    repo_root = plugin_root.parent.parent
    agent_skills = repo_root / "agent-skills"
    if agent_skills.is_dir():
        if (agent_skills / ("jimmy" + "-mode")).exists():
            errors.append("legacy agent-skills entry still exists")
        for skill_name in EXPECTED_SKILLS:
            link = agent_skills / skill_name
            if not link.is_symlink():
                errors.append(f"{link}: expected development symlink")
                continue
            if link.resolve() != (skills_root / skill_name).resolve():
                errors.append(f"{link}: points outside the Jimmy package")

    marketplace = repo_root / ".agents" / "plugins" / "marketplace.json"
    if marketplace.is_file():
        payload = json.loads(marketplace.read_text(encoding="utf-8"))
        entries = [entry for entry in payload.get("plugins", []) if entry.get("name") == "jimmy"]
        if len(entries) != 1:
            errors.append(f"{marketplace}: expected one jimmy entry")
        elif entries[0].get("source", {}).get("path") != "./plugins/jimmy":
            errors.append(f"{marketplace}: jimmy source path is incorrect")

    return errors


def main() -> int:
    plugin_root = Path(__file__).resolve().parent.parent
    errors = validate_package(plugin_root)
    if errors:
        print("Jimmy plugin validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print(f"Jimmy plugin validation passed with {len(EXPECTED_SKILLS)} skills.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
