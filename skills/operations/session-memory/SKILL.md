---
name: session-memory
description: Formalizes the .shipworthy/ directory as the cross-session memory system. Ensures specs, decisions, plans, and session summaries persist across Claude Code sessions for continuity. Surfaces in-progress work at session start.
invoke_when: At session start (automatically via hook context), when saving specs/plans/decisions, or when the user asks about previous session work.
---

# Session Memory

## Purpose

Claude Code sessions are stateless — each new session starts fresh. But projects are not stateless. Work in progress, architectural decisions, feature specs, and implementation plans need to survive between sessions. This skill formalizes `.shipworthy/` as the persistent memory layer.

## Memory Structure

```
.shipworthy/
├── architecture.md          # Project architecture spec (managed by architecture-awareness skill)
├── tech-debt.md             # Tech debt tracker (managed by tech-debt-tracking skill)
├── specs/                   # Feature specifications (managed by intent-to-spec skill)
│   ├── user-auth.md
│   ├── invoice-system.md
│   └── ...
├── plans/                   # Implementation plans (managed by writing-plans skill)
│   ├── user-auth.md
│   └── ...
├── decisions/               # Architecture Decision Records (ADRs)
│   ├── 001-database-choice.md
│   └── ...
└── sessions/                # Session summaries for continuity
    ├── 2026-03-29.md
    └── ...
```

## Session Summary

At the END of each session (when the user says goodbye, closes the conversation, or you detect natural completion), write a brief session summary:

### Format: `.shipworthy/sessions/[YYYY-MM-DD].md`

```markdown
# Session Summary — [YYYY-MM-DD]

## What Was Done
- [Completed task 1]
- [Completed task 2]

## What's In Progress
- [Task that was started but not finished]
- [Relevant context for picking it up]

## Decisions Made
- [Any architectural or design decisions — link to ADR if created]

## Next Steps
- [What should happen next]
- [Any blockers or open questions]
```

Keep it under 20 lines. This is a breadcrumb trail, not a novel.

## Surfacing Previous Work

The session-start hook already loads architecture.md and tech-debt.md. This skill adds awareness of:

1. **In-progress plans**: If `.shipworthy/plans/` contains plans, check if they were completed. An in-progress plan has tasks without all being marked done.
   - Surface: "You have an in-progress plan for [feature]. Resume or start fresh?"

2. **Recent session summaries**: If `.shipworthy/sessions/` has a recent file (last 7 days), surface the "What's In Progress" and "Next Steps" sections.
   - Surface: "Last session (2026-03-28): [in-progress item]. Want to continue?"

3. **Feature specs without plans**: If `.shipworthy/specs/` has specs that don't have corresponding plans in `.shipworthy/plans/`, those features were specified but not yet planned.
   - Surface: "You have a spec for [feature] but no implementation plan yet. Want to plan it?"

## Architecture Decision Records (ADRs)

When a significant architectural decision is made (database choice, authentication method, state management approach, API design pattern), save an ADR:

### Format: `.shipworthy/decisions/[NNN]-[short-title].md`

```markdown
# ADR [NNN]: [Decision Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-NNN]

## Context
[What prompted this decision]

## Decision
[What was decided]

## Consequences
[What changes as a result — both positive and negative]
```

Only create ADRs for decisions that would be non-obvious to a future developer. "We use React" is not an ADR. "We use server components for data fetching instead of client-side useEffect" IS an ADR.

## Rules

1. **Always commit `.shipworthy/`** — remind the user to commit this directory. It IS the project's engineering memory.
2. **Don't overwrite** — append to session summaries if multiple sessions happen on the same day. Don't overwrite specs or plans without user consent.
3. **Keep it lightweight** — every file in `.shipworthy/` should be under 100 lines. If it's longer, you're over-documenting.
4. **Plain Markdown only** — no special tooling required to read these files. Any developer (or AI) can understand them.
