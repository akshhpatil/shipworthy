---
name: retrospective
description: Self-improving loop — after completing work, sub-agents analyze the conversation to extract signals (corrections, improvised steps, what worked first try, what failed). Proposes updates to project learnings and skill effectiveness. Every session makes the next one better.
invoke_when: Use when running /retro, ending a session naturally, or after completing a significant piece of work. Never runs mid-task — only after work is done.
---

# Retrospective

## Core Principle

**You can't design a skill from nothing. You can only improve after doing work.** Every conversation produces signal — corrections the user made, steps that were improvised, things that worked on first try. The retrospective extracts that signal and turns it into permanent improvements.

## When to Run

- User explicitly runs `/retro`
- After completing a multi-turn feature build
- When the user says something like "that went well" or "that was rough"
- At natural session end (before writing session summary)

**Never interrupt work to run a retrospective.** Wait until the work is done.

## The Retrospective Process

### Phase 1: Extract Signals

Review the entire conversation and categorize every notable moment:

| Signal Type | What to Look For | Example |
|-------------|-----------------|---------|
| **Corrections** | User said "no", "not that", "wrong", "I meant..." | "No, use PostgreSQL not SQLite" |
| **Redone Work** | Something built, then rebuilt differently | Built REST first, user wanted GraphQL |
| **Improvised Steps** | Steps not in any plan that were needed | Had to add CORS middleware — no skill covered it |
| **First-Try Success** | Things that worked immediately, no corrections | TDD flow produced passing tests on first run |
| **Skill Hits** | Which Shipworthy skills were invoked and helped | intent-to-spec caught missing requirements |
| **Skill Misses** | Situations where a skill should have helped but didn't | No skill warned about CORS for frontend+API |
| **User Preferences** | Patterns in how the user wants to work | Prefers explicit confirmation before database changes |

### Phase 2: Map to Skills

For each signal, determine which Shipworthy skill is relevant:

```
Correction: "Don't use console.log" → using-shipworthy (non-negotiable #1)
  - Was the skill invoked? Yes/No
  - Did it prevent the issue? Yes/No
  - If No: Why did it fail? (ignored, not triggered, wrong advice)

Improvised: "Added rate limiting" → No skill covers this adequately
  - Gap identified: rate limiting not in api-design-standards
  - Proposed fix: Add rate limiting section to api-design-standards skill
```

### Phase 3: Propose Changes

Present findings as a reviewable table:

```
## Retrospective Findings

| # | Type | Finding | Proposed Action | Affects |
|---|------|---------|----------------|---------|
| 1 | Correction | User prefers PostgreSQL over SQLite for production | Save to project learnings | .shipworthy/learnings/ |
| 2 | Skill Miss | No CORS guidance when building frontend+API | Add CORS section to api-design-standards | skills/ |
| 3 | First-Try | TDD flow for API endpoints was smooth | No change needed (skill working well) | — |
| 4 | Improvised | Had to set up Docker manually | Consider container-security skill earlier in routing | using-shipworthy |
| 5 | Preference | User wants explicit approval before DB migrations | Save to project learnings | .shipworthy/learnings/ |

Approve all? Or select specific items (e.g., "approve 1, 2, 5"):
```

### Phase 4: Apply Approved Changes

For each approved finding:

**Project Learnings** → Save to `.shipworthy/learnings/[topic].md`:
```markdown
# [Topic] Learnings

## Preferences
- [What the user/team prefers]

## Patterns That Work
- [What succeeded and should be repeated]

## Patterns That Failed
- [What was tried and didn't work — avoid repeating]

## Last Updated
- [Date] — from retrospective after [what work was done]
```

**Skill Updates** → Propose a specific diff to the skill file. Show the exact change. Do NOT auto-apply to skill files — only to learnings files. Skill file changes require explicit confirmation because they affect all future sessions.

**Memory Updates** → If using Claude Code's auto-memory, propose a memory for significant preferences discovered. The retrospective skill works WITH auto-memory, not instead of it:
- Auto-memory captures small corrections in real-time
- Retrospective captures patterns across an entire work session
- Auto-dream consolidates both overnight

### Phase 5: Update Session Summary

After the retrospective, enhance the session summary (`.shipworthy/sessions/[date].md`) with:
```markdown
## Retrospective
- Signals extracted: [count]
- Corrections: [count]
- Skill hits: [list]
- Skill gaps: [list]
- Learnings saved: [count]
```

## Learnings Directory Structure

```
.shipworthy/
├── learnings/                    # What this project has taught us
│   ├── database-preferences.md   # "Use PostgreSQL, not SQLite for this project"
│   ├── api-patterns.md           # "Always add CORS, always add rate limiting"
│   ├── deployment-notes.md       # "Docker compose for local, K8s for prod"
│   └── team-conventions.md       # "PR reviews required, squash merge only"
```

## The Flywheel

```
Session 1: Build feature → Corrections happen → Run /retro → Save learnings
Session 2: Start work → Learnings loaded → Fewer corrections → Run /retro → Refine
Session 3: Start work → Learnings + refined skills → Near-zero corrections
...
Session N: One-shot execution. System knows your patterns.
```

## Rules

1. **Never auto-apply skill changes** — only learnings. Skill changes are proposed, reviewed, and explicitly approved.
2. **Never run mid-work** — retrospectives only happen after work is complete.
3. **Keep learnings concise** — each file under 50 lines. These are patterns, not documentation.
4. **Don't duplicate auto-memory** — if something is already captured by Claude's auto-memory system, reference it instead of duplicating.
5. **Learnings are project-scoped** — they live in `.shipworthy/learnings/` and apply to this project. User-level preferences go to Claude's auto-memory.
6. **Always show the table** — never silently save learnings. The user must see what was learned and approve it.
