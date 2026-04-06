Before executing this command, output:
> ⚓ **shipworthy** › command: `/context` — analyzing context health and completeness

---

Run a context health analysis for this project. Invoke the `context-manager` skill and check these dimensions:

## Process

### 1. Context Infrastructure

Check which standard files exist in `.shipworthy/`:

| File | Purpose | Status |
|------|---------|--------|
| `architecture.md` | Architecture constraints and mandatory rules | exists / missing |
| `regression-fence.md` | Anti-pattern protection (NEVER/ALWAYS rules) | exists / missing |
| `config.json` | Project configuration and preset | exists / missing |
| `INDEX.md` | Memory index (auto-generated) | exists / missing |
| `learnings/` | At least one learning file | exists / missing |
| `sessions/` | At least one session file | exists / missing |
| `decisions/` | Architecture decision records | exists / missing |
| `plans/` | Implementation plans | exists / missing |

Also check if `CLAUDE.md` exists at the project root.

### 2. Regression Fence Health

- Count rules (H2 headings in `regression-fence.md`)
- 0 rules = no protection — recommend running `/retro` after next session
- 1-15 rules = healthy
- 16-20 rules = near cap, consider pruning stale entries
- Check if any rules reference files/functions that no longer exist in the codebase

### 3. Session Signals

- Does `.shipworthy/.session-signals` exist?
- If yes, count lines — these are unprocessed signals from hooks
- If > 0: recommend running `/retro` or starting a new session (auto-retro triggers at session start)

### 4. Context Completeness

- Estimate total characters loaded at session start (architecture spec + fence + plans + sessions + learnings)
- Show percentage of 8000-char context budget used
- Identify gaps: "You have architecture.md but no regression fence — corrections from past sessions will repeat"

### 5. Actionable Suggestions

Based on analysis, suggest specific next actions. Examples:
- "12 unprocessed signals — run `/retro` to convert them into learnings and fence entries"
- "No regression fence yet — it will be auto-created when you run `/retro` after your next work session"
- "3 learning files cover overlapping topics — `/retro` will offer to consolidate them"
- "Architecture spec missing — start building with `/scaffold` or the `architecture-awareness` skill"
- "CLAUDE.md has no pointer to `.shipworthy/` — consider adding: `Read .shipworthy/INDEX.md for full project memory`"

## Output Format

Present as a concise dashboard, then suggestions:

```
Context Health Dashboard
========================

CLAUDE.md              82 lines ✓
.shipworthy/           6/8 standard files ✓
Regression fence       5 rules ✓
Session signals        0 unprocessed ✓
Context budget         ~5,200/8,000 chars (65%) ✓

Suggestions:
1. Add decisions/ directory for architecture decision records
2. No plans/ directory — will be created when you use writing-plans skill
```

After presenting the dashboard, ask:
> "Want me to apply any of these suggestions?"
