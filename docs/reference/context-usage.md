# Context Window Usage

Shipworthy is designed to be lightweight. The master skill lives in context, everything else loads on demand.

## What Gets Injected Per Session

The session-start hook injects a single `additionalContext` blob:

| Component | Size | When |
|-----------|------|------|
| Master routing skill (using-shipworthy) | ~5,000 chars | Always |
| Tier detection info | ~400 chars | Always |
| Project health diagnosis | ~150 chars | Always |
| Architecture spec (summarized if large) | ~1,500 chars | If `.shipworthy/architecture.md` exists |
| Preset info | ~200 chars | If `.shipworthy/config.json` has preset |
| In-progress plans | ~200 chars/plan | If `.shipworthy/plans/` has files |
| Previous session summary | ~500 chars | If recent session in `.shipworthy/sessions/` |
| Project learnings (index only) | ~200 chars | If `.shipworthy/learnings/` has files |
| Tech debt notice | ~100 chars | If `.shipworthy/tech-debt.md` exists |
| **Total** | **~8,000 chars / ~2,000 tokens** | |

## What Does NOT Load At Session Start

- The 55 SKILL.md files (loaded on demand when relevant)
- Hook scripts (run as shell processes, not text in context)
- Agent personas (loaded only when dispatched)
- Extension skills (loaded only when activated)
- Templates (loaded only during /scaffold)

## On-Demand Skill Loading

When Claude determines a skill is relevant (via the routing table), it reads that specific skill file:

| Scenario | Skills Loaded | Extra Tokens |
|----------|:---:|:---:|
| Quick fix (typo, config change) | 1-2 | ~750 |
| Feature build (new endpoint) | 3-4 | ~1,500 |
| Complex feature (auth, payments) | 5-8 | ~3,000 |
| /audit (comprehensive review) | All 55 | ~20,000 |

Skills load in, guide the work, and naturally scroll out of the active context window as the conversation continues.

## Context Budget Impact

| Scenario | Tokens Used | % of 200K | % of 1M |
|----------|:-:|:-:|:-:|
| Session start (always) | ~2,000 | 1.0% | 0.2% |
| Active work (3-4 skills) | ~3,500 | 1.7% | 0.35% |
| Heavy work (8+ skills) | ~6,000 | 3.0% | 0.6% |
| /audit (all skills, one-time) | ~20,000 | 10.0% | 2.0% |

## User's Project Footprint

The `.shipworthy/` directory in the user's project is small:

```
.shipworthy/
├── architecture.md        ~2KB
├── config.json            ~200B
├── tech-debt.md           ~1KB
├── specs/                 ~1-5KB
├── plans/                 ~1-3KB
├── learnings/             ~1-3KB
├── decisions/             ~500B
└── sessions/              ~500B per session
                           ────────
Total:                     ~10-15KB typical
```

The plugin itself lives in Claude Code's plugin directory (`~/.claude/plugins/shipworthy/`), not in the user's project.

## Context Budget Enforcement

The session-start hook enforces an 8,000 character budget with priority-based truncation:

1. **Mandatory Rules** from architecture spec (highest priority — never truncated)
2. **Tier detection** (always included)
3. **Project health** (always included)
4. **Tech debt count** (always included)
5. **In-progress plans** (included if budget allows)
6. **Previous session** (included if budget allows)
7. **Full architecture spec** (summarized to Mandatory Rules only if over budget)

If the total exceeds 8,000 chars, lower-priority sections are truncated with pointers to the full files.

## Design Principles

- **Master skill in context, everything else on demand** — only the routing table is always present
- **Skills are ephemeral** — they load for a task and scroll out naturally
- **No skill duplication** — skills reference each other by name, don't copy content
- **Budget enforced at hook level** — shell script truncates before injection, not after
- **Lightweight .shipworthy/** — project-scoped data is tiny (~15KB), not a second codebase
