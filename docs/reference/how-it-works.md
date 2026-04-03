# How Shipworthy Works

## Install

```bash
npx shipworthy init
```

One command. This configures Claude Code hooks in `.claude/settings.json` and creates the `.shipworthy/` directory. No further configuration required.

## What Happens Automatically

### On Every Session Start

The session-start hook fires invisibly (<2 seconds):

1. Detects project type (Node.js, Python, Go, etc.)
2. Detects maturity tier (Builder / Maker / Engineer)
3. Diagnoses project gaps (missing tests, CI, linting, .gitignore)
4. Loads architecture spec if present
5. Loads project learnings from previous retrospectives
6. Surfaces in-progress plans and recent session context
7. Injects the master routing skill with all non-negotiable defaults

With transparency enabled (on by default), the user sees a color-coded banner and activity log:

```
┌─ ⚓ shipworthy ─────────────────────────────┐
│  Tier: ENGINEER  │  Health: all passed       │
│  Skills: 55      │  Hooks: 6 active          │
└──────────────────────────────────────────────┘
⚓ shipworthy  14:32:05  session-start  ›  Architecture spec: loaded
⚓ shipworthy  14:32:05  session-start  ›  In-progress plans: user-auth
```

### On Every File Write

Pre-tool-use hook checks BEFORE the file is written:
- No hardcoded secrets (AWS keys, API tokens, passwords)
- No eval() or Function() constructor
- No console.log in production code (skips test files, CLI tools)
- .env files have .gitignore protection

Post-tool-use hook checks AFTER the file is written:
- TypeScript `: any` usage flagged
- Route handlers without input validation flagged
- Test files in wrong directories flagged

### On Every Bash Command

Pre-tool-use hook catches destructive commands BEFORE execution:
- `rm -rf` (recursive force delete)
- `git push --force` (rewrites remote history)
- `git reset --hard` (discards uncommitted changes)
- `DROP TABLE` / `TRUNCATE` (destructive database operations)
- Docker prune commands

Post-tool-use hook monitors AFTER execution:
- Git commits (reminds to verify tests)
- New dependency installs (flags for review)
- Database migrations (reminds about rollback plans)

All hooks are advisory — they warn but never block (except the pre-push validator, which blocks pushes that fail validation).

Every hook action is logged to the terminal with color-coded transparency:

```
⚓ shipworthy  14:33:12  pre-tool-use  ›  Scanning: service.ts
⚓ shipworthy  14:33:12  pre-tool-use  ›  All checks passed ✓
```

Warnings appear in yellow, blocks in red:

```
⚓ shipworthy  14:34:01  pre-tool-use  ›  ! Secrets scan: WARN
⚓ shipworthy  14:40:08  pre-push-validate  ›  ✗ Validation FAILED — push blocked
```

## The Invisible Workflow

When a user requests a new feature:

```
User: "Build me an invoice system"
         │
         ▼
   intent-to-spec     →  Generates lightweight spec silently
         │                (Builder tier: invisible)
         ▼
   brainstorming       →  Lite mode: Understand → Recommend → Build
         │
         ▼
   architecture-       →  Detects stack, generates architecture.md
   awareness               (first request only)
         │
         ▼
   test-driven-        →  Writes failing test → implements → verifies
   development
         │
         ▼
   verification        →  Runs proof commands, confirms with evidence
```

The user just said what they wanted. Everything else happened automatically — and transparently:

```
> ⚓ **shipworthy** › routing: task classified as Feature — using spec → brainstorm → plan → execute flow
> ⚓ **shipworthy** › skill: `architecture-awareness` — detecting stack, generating architecture.md
> ⚓ **shipworthy** › skill: `test-driven-development` — writing failing test first
> ⚓ **shipworthy** › skill: `verification-before-completion` — running proof commands
```

## Quality Gates (Scale With Project)

| Project Size | Gate Level | What's Checked |
|:---:|:---:|---|
| <5 files | Level 0 | Build runs, no hardcoded secrets |
| 5+ files | Level 1 | Tests pass, lint clean, no console.log |
| 10+ files | Level 2 | Coverage >70%, no TODOs without tickets |
| 50+ files | Level 3 | Bundle budgets, no circular imports |
| 100+ files | Level 4 | Performance, accessibility, security scan |

No configuration needed. Gates tighten as the project matures.

## The Self-Improving Loop

After completing work, run `/retro`:

```
Session 1:  Build feature  →  Corrections  →  /retro  →  Save learnings
Session 2:  Start work     →  Learnings loaded  →  Fewer corrections
Session 3:  Near-zero corrections  →  Refined learnings
Session N:  One-shot execution
```

The retrospective skill analyzes the full conversation:
- What corrections were made
- What was improvised
- What worked on first try
- Which skills helped vs missed

Findings are presented as a table. User approves/rejects. Approved learnings persist in `.shipworthy/learnings/`.

## Integration With Claude Code Memory

Shipworthy works alongside Claude Code's native memory systems:

| Layer | What It Captures | Managed By |
|-------|-----------------|------------|
| CLAUDE.md | Foundation rules | User (manual) |
| Shipworthy Skills | Engineering practices | Plugin (55 skills) |
| Auto-memory | Individual corrections | Claude Code (automatic) |
| /retro Learnings | Session-level patterns | Shipworthy (user-reviewed) |
| Auto-dream | Overnight consolidation | Claude Code (automatic) |

Auto-memory catches "don't use SQLite." /retro catches "this team always needs CORS + rate limiting + explicit error messages."

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/scaffold` | Generate architecture spec for the project |
| `/audit` | Full code quality review across all dimensions |
| `/health` | Project + plugin health dashboard |
| `/diagnose` | Infrastructure gap analysis with auto-fix |
| `/retro` | Session retrospective — extract learnings |

## Per-Project Configuration

Optional `.shipworthy/config.json` for customization:

```json
{
  "preset": "enterprise",
  "overrides": {
    "allow_console_log": true,
    "allow_any_types": false,
    "project_type": "cli"
  },
  "transparency": true,
  "ignore_paths": ["legacy/", "vendor/"]
}
```
