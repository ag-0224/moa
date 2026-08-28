"""Validate the repository collaboration contract and agent skill metadata for MOA project."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = (
    "README.md",
    "AGENTS.md",
    "AI_RULES.md",
    "CLAUDE.md",
    ".env.example",
    ".gitignore",
    "openapi.yaml",
    "mock-data.json",
    "schema.sql",
    "scripts/validate_collaboration.py",
    "scripts/prompts/spring-boot-controller.prompt.txt",
    "scripts/prompts/flutter-screen-generator.prompt.txt",
    "scripts/prompts/api-contract-refactor.prompt.txt",
    "docs/README.md",
    "docs/PROJECT_CONTEXT.md",
    "docs/COLLABORATION.md",
    "docs/REPOSITORY_STRUCTURE.md",
    "docs/PRD.md",
    "docs/USER_FLOW.md",
    "docs/API_CONTRACT.md",
    "docs/DECISIONS.md",
    ".github/copilot-instructions.md",
    ".github/instructions/api-contract.instructions.md",
    ".github/PULL_REQUEST_TEMPLATE.md",
    ".github/ISSUE_TEMPLATE/feature.md",
    ".github/ISSUE_TEMPLATE/bug.md",
    ".github/ISSUE_TEMPLATE/config.yml",
)

SKILLS = (
    "moa-work-on-issue",
    "moa-change-api-contract",
    "moa-prepare-pull-request",
)

MARKDOWN_LINK = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
FRONTMATTER = re.compile(r"\A---\n(.*?)\n---\n", re.DOTALL)


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def simple_yaml_parse(text: str) -> dict[str, object]:
    """Basic fallback YAML parser for skill frontmatter and metadata when PyYAML is unavailable."""
    result: dict[str, object] = {}
    current_section: str | None = None
    section_dict: dict[str, str] = {}

    for line in text.splitlines():
        line_str = line.strip()
        if not line_str or line_str.startswith("#"):
            continue
        if ":" in line:
            key, val = line.split(":", 1)
            key = key.strip()
            val = val.strip()

            if not val and not line.startswith(" ") and not line.startswith("\t"):
                current_section = key
                section_dict = {}
                result[current_section] = section_dict
                continue

            if (line.startswith(" ") or line.startswith("\t")) and current_section:
                section_dict[key] = val
            else:
                current_section = None
                result[key] = val

    return result


def parse_yaml(text: str, source: str, errors: list[str]) -> object | None:
    if yaml is not None:
        try:
            return yaml.safe_load(text)
        except yaml.YAMLError as error:
            errors.append(f"{source}: invalid YAML: {error}")
            return None
    
    # Fallback when PyYAML is missing
    try:
        return simple_yaml_parse(text)
    except Exception as error:
        errors.append(f"{source}: fallback YAML parse error: {error}")
        return None


def parse_frontmatter(text: str, source: str, errors: list[str]) -> dict[str, object]:
    match = FRONTMATTER.match(text)
    if not match:
        errors.append(f"{source}: missing or invalid YAML frontmatter")
        return {}
    parsed = parse_yaml(match.group(1), source, errors)
    if not isinstance(parsed, dict):
        errors.append(f"{source}: frontmatter must be a mapping")
        return {}
    return parsed


def validate_skill(skill_name: str, errors: list[str]) -> None:
    base = ROOT / ".agents" / "skills" / skill_name
    skill_file = base / "SKILL.md"
    metadata_file = base / "agents" / "openai.yaml"

    for path in (skill_file, metadata_file):
        if not path.is_file():
            errors.append(f"missing skill file: {path.relative_to(ROOT).as_posix()}")
            return

    skill_text = skill_file.read_text(encoding="utf-8")
    metadata_text = metadata_file.read_text(encoding="utf-8")

    skill_source = skill_file.relative_to(ROOT).as_posix()
    frontmatter = parse_frontmatter(skill_text, skill_source, errors)
    if set(frontmatter) != {"name", "description"}:
        errors.append(f"{skill_name}: frontmatter keys must be name and description only")
    if frontmatter.get("name") != skill_name:
        errors.append(f"{skill_name}: frontmatter name does not match directory")
    if not isinstance(frontmatter.get("description"), str):
        errors.append(f"{skill_name}: description must be a non-empty string")
    if "[TODO" in skill_text or "TODO:" in skill_text:
        errors.append(f"{skill_name}: unresolved TODO in SKILL.md")

    metadata_source = metadata_file.relative_to(ROOT).as_posix()
    metadata = parse_yaml(metadata_text, metadata_source, errors)
    interface = metadata.get("interface") if isinstance(metadata, dict) else None
    required_interface_keys = {"display_name", "short_description", "default_prompt"}
    if not isinstance(interface, dict) or set(interface) != required_interface_keys:
        errors.append(f"{skill_name}: openai.yaml must define the three interface fields")
        return
    if not all(isinstance(interface.get(key), str) and interface[key].strip() for key in required_interface_keys):
        errors.append(f"{skill_name}: openai.yaml interface fields must be non-empty strings")
    if f"${skill_name}" not in str(interface.get("default_prompt", "")):
        errors.append(f"{skill_name}: default prompt must explicitly invoke the skill")


def validate_local_links(relative_path: str, errors: list[str]) -> None:
    source = ROOT / relative_path
    if source.suffix.lower() != ".md" or not source.is_file():
        return

    for raw_target in MARKDOWN_LINK.findall(source.read_text(encoding="utf-8")):
        target = raw_target.strip().strip("<>").split("#", 1)[0]
        if not target or re.match(r"^[a-z][a-z0-9+.-]*:", target, re.IGNORECASE):
            continue
        resolved = (source.parent / target).resolve()
        try:
            resolved.relative_to(ROOT.resolve())
        except ValueError:
            errors.append(f"{relative_path}: link escapes repository: {raw_target}")
            continue
        if not resolved.exists():
            errors.append(f"{relative_path}: broken local link: {raw_target}")


def validate_agents_references(errors: list[str]) -> None:
    if (ROOT / "AGENTS.md").is_file():
        agents_text = read("AGENTS.md")
        for required_ref in (
            "AI_RULES.md",
            "docs/PROJECT_CONTEXT.md",
            "docs/COLLABORATION.md",
            "docs/REPOSITORY_STRUCTURE.md",
        ):
            if required_ref not in agents_text:
                errors.append(f"AGENTS.md does not reference {required_ref}")
        for skill_name in SKILLS:
            if f"${skill_name}" not in agents_text:
                errors.append(f"AGENTS.md does not reference ${skill_name}")


def main() -> int:
    errors: list[str] = []

    for relative_path in REQUIRED_FILES:
        path = ROOT / relative_path
        if not path.is_file():
            errors.append(f"missing required file: {relative_path}")
        elif len(path.read_text(encoding="utf-8").strip()) < 20:
            errors.append(f"required file is unexpectedly short: {relative_path}")
        else:
            validate_local_links(relative_path, errors)

    for skill_name in SKILLS:
        validate_skill(skill_name, errors)

    validate_agents_references(errors)

    if errors:
        print("MOA Collaboration contract validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(
        f"MOA Collaboration contract OK: {len(REQUIRED_FILES)} files, "
        f"{len(SKILLS)} skills"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
