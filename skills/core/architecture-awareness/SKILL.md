---
name: architecture-awareness
description: Detects project type, analyzes existing patterns, generates architecture specifications, and maintains architectural consistency across sessions. The key innovation that turns CLAUDE.md-style contracts into automatic, evolving project specifications.
invoke_when: Project has no .engineering-with-vibes/architecture.md, user runs /scaffold command, new technology is added to the project, or a significant architectural decision is made during brainstorming.
---

# Architecture Awareness

## Purpose

This skill solves the critical problem of **architectural amnesia** — when AI coding assistants forget project constraints between sessions. It generates and maintains an architecture specification that acts as a persistent, enforceable contract.

## When This Skill Activates

1. **No architecture spec exists** — first interaction with a new project
2. **User runs `/scaffold`** — explicit regeneration request
3. **New technology detected** — package.json/requirements.txt changes
4. **Architectural decision made** — during brainstorming, a decision warrants documentation

## Phase 1: Project Detection

Analyze the project to understand its technology stack. Check for:

### Language & Framework Indicators
- `package.json` → Node.js (check for Next.js, Express, React, Vue, etc.)
- `tsconfig.json` → TypeScript (check strict mode, target, module system)
- `requirements.txt` / `pyproject.toml` / `setup.py` → Python (check for FastAPI, Django, Flask)
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pom.xml` / `build.gradle` → Java/Kotlin

### Structure Indicators
- `src/app/` or `app/` → Next.js App Router / framework convention
- `src/pages/` → Next.js Pages Router or similar
- `src/components/` → Component-based frontend
- `src/routes/` or `routes/` → Express/backend routing
- `prisma/` or `drizzle.config.*` → ORM usage
- `.github/workflows/` → CI/CD with GitHub Actions
- `Dockerfile` / `docker-compose.yml` → Containerized deployment
- `tests/` or `__tests__/` or `*.test.*` → Testing patterns

### Existing Convention Indicators
- Read existing source files to detect naming patterns (camelCase, snake_case, PascalCase)
- Check import patterns (relative, absolute, aliases)
- Check error handling patterns
- Check existing test patterns (framework, location, naming)

## Phase 2: Template Selection

Select the most appropriate template from `templates/`:
- `nextjs.md` — Next.js applications (App Router or Pages Router)
- `express.md` — Express/Node.js API services
- `fastapi.md` — Python FastAPI services
- `go-service.md` — Go microservices
- `react-spa.md` — React single-page applications
- `generic-typescript.md` — TypeScript projects without specific framework
- `generic-python.md` — Python projects without specific framework
- `monorepo.md` — Multi-package repositories

If the project doesn't match any template, use the closest one and adapt.

## Phase 3: Specification Generation

### For Greenfield Projects (no existing code)
Fill the template with sensible defaults and best practices for the detected stack. **Prescribe what SHOULD BE.**

### For Brownfield Projects (existing code)
Analyze existing patterns and document them as-is. **Describe what IS.**

Critical rule: Do NOT impose alien patterns on existing codebases. If the project uses `snake_case` for files, the spec should say `snake_case`, not `kebab-case`. The spec should codify existing conventions, making them explicit and enforceable.

### Specification Structure

Generate `.engineering-with-vibes/architecture.md` with these sections:

```markdown
# Architecture Specification: [Project Name]

## Project Identity
- **Type**: [e.g., Next.js 14 App Router application]
- **Language**: [e.g., TypeScript 5.x strict mode]
- **Runtime**: [e.g., Node.js 20+]
- **Primary Framework**: [e.g., Next.js 14]
- **Package Manager**: [e.g., npm/pnpm/yarn/bun]

## Mandatory Rules
[Numbered list of 5-15 inviolable constraints specific to this project]
[These become the CLAUDE.md-style rules enforced at every session]

## Directory Structure
[Expected layout with purpose annotations]

## Naming Conventions
[File naming, variable naming, component naming, test naming]

## Type System
[Where types live, how shared between modules, strict mode rules]

## Testing Strategy
[Framework, file locations, naming patterns, coverage expectations]
[What MUST be tested vs what's optional]

## Error Handling
[Stack-specific error handling pattern]

## Security Baseline
[Stack-specific security requirements]

## Performance Budgets
[Default thresholds — bundle size, API response time, query limits]

## Quality Gate Levels
[Graduated thresholds configuration]
Level 1 (always): [checks]
Level 2 (10+ files): [checks]
Level 3 (50+ files): [checks]
Level 4 (100+ files): [checks]

## Common Mistakes
[5-10 documented pitfalls specific to this stack/project]
```

## Phase 4: User Approval

Present the generated specification to the user with:
1. Summary of what was detected
2. The full specification
3. Invitation to modify before saving

**Do NOT save architecture.md without user approval.** This is their project; the spec is a suggestion until they accept it.

## Phase 5: Evolution

When the architecture needs to change:
1. Identify what changed (new dependency, new pattern, architectural decision)
2. Propose specific updates to the relevant sections
3. Show the diff (old → new)
4. Get user approval before updating

Track significant decisions as Architecture Decision Records in `.engineering-with-vibes/decisions/`:
```markdown
# ADR-NNN: [Decision Title]

## Status: [Accepted/Superseded/Deprecated]
## Date: [YYYY-MM-DD]

## Context
[What prompted this decision]

## Decision
[What was decided]

## Consequences
[What this means going forward]
```
