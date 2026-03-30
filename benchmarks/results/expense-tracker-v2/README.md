# Expense Tracker Benchmark — v2 (Multi-Turn, Unbiased)

## Methodology

Two Claude Code agents ran in parallel with **identical prompts** — the only difference was whether the Shipworthy plugin context was injected. Both used the same model (Claude Opus 4.6), same worktree isolation, same 7-turn founder prompts.

### Prompts (non-technical founder style)

| Turn | Prompt |
|------|--------|
| 1 | "Build me an expense tracker - I need to add expenses with amount, description, category and date, see all my expenses, and delete ones I don't need" |
| 2 | "Can you add filtering? I want to see expenses from a specific month or just a specific category" |
| 3 | "I need a summary - total spent, breakdown by category with percentages, and average daily spending" |
| 4 | "Add the ability to export all expenses as a CSV file" |
| 5 | "I want budget limits per category - like if I set $500 for food it should warn me when I'm getting close" |
| 6 | "Add recurring expenses - things like rent or Netflix that happen every month automatically" |
| 7 | "OK make sure everything works. Run all tests, make sure it builds. Give me a summary of what was built." |

**No prompt mentions tests, linting, databases, validation, logging, or .gitignore.** A real non-tech founder wouldn't ask for those.

### Scoring

Automated via `benchmarks/score.sh` — 25 objective checks across 8 categories. The scoring script was written **before** either agent ran to prevent bias. All checks are binary (pass/fail) or quantified (counts), with no subjective LLM judgment.

## Results

| Metric | WITH Shipworthy | WITHOUT Plugin |
|--------|:-:|:-:|
| **Overall Score** | **35/36 (97%)** | **15/36 (41%)** |
| **Grade** | **A** | **F** |
| Build succeeds | PASS | PASS |
| Tests exist | 5 files | 6 files |
| Tests pass | PASS | PASS |
| Coverage configured | PASS | FAIL |
| Linter configured | PASS | FAIL |
| Linter passes | PASS | FAIL |
| console.log in prod | **0** | 1 |
| Structured logging (pino) | PASS | FAIL |
| TypeScript `: any` | **0** | **5 instances** |
| Input validation (Zod) | PASS | FAIL |
| Validation in handlers | PASS | FAIL |
| Error handling on routes | PASS | FAIL |
| Proper HTTP status codes | PASS | PASS |
| **Uses real database** | **SQLite** | **In-memory arrays** |
| Database schema defined | PASS | FAIL |
| .gitignore exists | PASS | FAIL |
| .env in .gitignore | PASS | FAIL |
| No hardcoded secrets | PASS | PASS |
| API endpoints | 24 | 34 |
| Architecture spec | PASS | FAIL |

## Key Findings

1. **Database**: Vanilla agent used in-memory arrays — data disappears on server restart. Shipworthy agent used SQLite automatically.

2. **Input Validation**: Zero validation on API inputs without the plugin. Any malformed request could crash the app or corrupt data.

3. **Error Handling**: No structured error handling without the plugin. Unhandled exceptions crash the entire server.

4. **Type Safety**: 5 instances of `: any` without the plugin — defeats TypeScript's purpose and causes runtime crashes.

5. **Logging**: `console.log` instead of structured logging — invisible to production monitoring tools.

6. **Infrastructure**: No linter, no coverage config, no .gitignore without the plugin. The code "works" but has zero production guardrails.

7. **Feature Count**: The vanilla agent built more endpoints (34 vs 24), proving Shipworthy doesn't slow you down — it redirects effort toward quality. Speed without quality is technical debt.

## Conclusion

Same prompts, same model, same product. The plugin turns a **41% F-grade** into a **97% A-grade** — automatically, without the user asking for any engineering practices.
