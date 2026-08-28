# CLAUDE.md - MOA Project Guidelines

This repository uses a structured Vibe Coding System for AI pair programming.

## Mandatory Rules & Guidelines
Before starting any task, read and follow:
- `@AGENTS.md` - Core agent instructions, Definition of Ready/Done, git branch rules.
- `@AI_RULES.md` - AI execution rules, P0-P3 priorities, security boundaries.
- `@docs/PROJECT_CONTEXT.md` - Technical context (Spring Boot 3 backend + Flutter frontend).
- `@docs/REPOSITORY_STRUCTURE.md` - Folder organization and boundaries.
- `@docs/API_CONTRACT.md` - Single Source of Truth for REST API contracts.

## Key Verification Commands
- Collaboration & contract verification: `python -X utf8 scripts/validate_collaboration.py`
- Spring Boot backend tests: `cd backend && ./gradlew test`
- Flutter frontend checks: `cd frontend && flutter analyze && flutter test`

## Repository Skills
- Issue Planning & Execution: `$moa-work-on-issue`
- API / DB Contract Changes: `$moa-change-api-contract`
- PR Preparation & Review: `$moa-prepare-pull-request`
