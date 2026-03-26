---
name: writing-plans
description: Creates bite-sized (2-5 min) implementation plans with TDD flow, quality gate checkpoints, security considerations, and performance impact notes. Plans reference architecture.md constraints.
invoke_when: After brainstorming is approved and before implementation begins. Also when breaking down a large task into manageable steps.
---

# Writing Plans

## Purpose

Transform an approved design into a sequence of small, verifiable tasks that follow TDD discipline.

## Plan Structure

Save plans to `.engineering-with-vibes/plans/[feature-name].md`.

### Header
```markdown
# Implementation Plan: [Feature Name]
**Design Spec**: [link to spec]
**Architecture Constraints**: [relevant Mandatory Rules from architecture.md]
**Date**: [YYYY-MM-DD]
```

### File Map
Before defining tasks, list every file that will be created or modified:
```markdown
## File Map
- `src/services/user-service.ts` — NEW: user service logic
- `src/routes/users.ts` — MODIFY: add new endpoints
- `src/types/user.ts` — MODIFY: add new types
- `tests/services/user-service.test.ts` — NEW: service tests
```

### Tasks
Each task follows TDD flow and takes 2-5 minutes:

```markdown
## Task 1: [Descriptive Name]
**Files**: [exact paths]
**Test first**: [the test to write, with actual code — not pseudocode]
**Implementation**: [the code to write — actual code, not descriptions]
**Verification**: [command to run: `npm test`, `npm run build`, etc.]
**Quality gate**: [what proves this task is done]
```

### Rules for Tasks
1. **Zero placeholders** — every task has actual code, not "implement the logic here"
2. **2-5 minutes each** — if a task takes longer, break it down further
3. **TDD flow** — test first, then implementation, then verification
4. **One responsibility** — each file should have one clear purpose (SOLID)
5. **Atomic commits** — each task should be committable independently
6. **Consistent naming** — type/method names must be consistent across ALL tasks
7. **Architecture compliance** — every task must reference which architecture rules it satisfies

### Security & Performance Sections
```markdown
## Security Considerations
- [What input validation is needed?]
- [What authentication/authorization applies?]
- [Any sensitive data handling?]

## Performance Impact
- [New database queries introduced?]
- [Bundle size impact?]
- [API response time expectations?]
```

## Presenting the Plan

After writing the plan:
1. Show the user the task list with file map
2. Highlight any architecture constraints that influenced the plan
3. Ask: "Ready to start executing? I'll follow TDD for each task."
4. On approval, invoke `executing-plans` skill
