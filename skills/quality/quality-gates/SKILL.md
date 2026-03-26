---
name: quality-gates
description: Graduated pre-commit quality checks that scale with project complexity. Level 1 for small projects, Level 4 for enterprise codebases. Thresholds configurable in architecture.md.
invoke_when: Before committing code, before creating a PR, or when the user asks for a quality audit. Also triggered by the post-tool-use hook when git commit is detected.
---

# Quality Gates

## Graduated Levels

Quality checks scale with project maturity. The plugin detects the project's current level based on file count and adjusts expectations accordingly.

### Level 1: Foundation (Always Active)
Every project, from day one:
- [ ] All existing tests pass
- [ ] No TypeScript/lint errors (if applicable)
- [ ] No `console.log` in production code (use structured logging)
- [ ] No hardcoded secrets, API keys, or credentials
- [ ] New code has corresponding tests
- [ ] Build completes successfully

### Level 2: Growing (10+ source files)
Building discipline:
- [ ] All Level 1 checks
- [ ] Test coverage for new code above threshold (default: 70%)
- [ ] No `TODO` without a ticket number or date
- [ ] No `any` type in TypeScript strict mode projects
- [ ] No unused imports or variables
- [ ] Error handling on all async operations

### Level 3: Maturing (50+ source files)
Architectural integrity:
- [ ] All Level 2 checks
- [ ] No circular imports (verify with dependency analysis)
- [ ] Bundle size within budget (if frontend)
- [ ] API contracts validated against types
- [ ] Database migrations are reversible
- [ ] No direct database queries outside the data layer
- [ ] All public functions have JSDoc/docstrings

### Level 4: Production (100+ source files)
Enterprise readiness:
- [ ] All Level 3 checks
- [ ] Performance benchmarks pass
- [ ] Accessibility audit passes (if frontend)
- [ ] Security scan clean (no known vulnerabilities in dependencies)
- [ ] API documentation synchronized with implementation
- [ ] Error tracking integration verified
- [ ] Health check endpoints respond correctly

## How to Run

When this skill activates:
1. Determine the project's level based on source file count
2. Run through the applicable checklist
3. Report results as: PASS / FAIL / ADVISORY
4. FAIL = must fix before committing
5. ADVISORY = should fix, but non-blocking

## Configuration

Quality gate thresholds can be customized in `.engineering-with-vibes/architecture.md`:
```markdown
## Quality Gate Levels
Level 1 (always): [custom checks]
Level 2 (15+ files): [custom threshold]
Level 3 (75+ files): [custom checks]
Level 4 (150+ files): [custom checks]
Coverage threshold: 80%
Bundle size limit: 250KB
```
