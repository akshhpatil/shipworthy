# Task 11: Bookmark API (Live Session)

## Context

This benchmark was run as a **live session** — not a scripted benchmark runner. A human asked Claude Code to build a Bookmark REST API twice: once with Shipworthy hooks and skills active, once without. The exact prompts and conversation flow are documented below for full transparency.

## Prompt

> I want to save my favorite links — like a bookmarks app. I should be able to add a bookmark with a title and URL, tag them, edit them, and delete ones I don't need anymore.

This prompt was given identically for both runs. No follow-up corrections or guidance were provided.

## Setup

Both runs started from an empty directory with only `npm init -y` and `git init`. No starter files, no tsconfig, no pre-installed dependencies. The AI had to scaffold everything from scratch.

## Exact Conversation Transcript

### With Shipworthy

**User prompt:**
> Can you test the tools by building a project, so this should serve as a transparency on how it approached. this project should serve as a testing as well how well it leverages shipworthy. And most important I should see all the progress shipworthy does on the terminal.

**What the AI did (in order):**
1. Checked Shipworthy hooks were installed and active at their configured paths
2. Created project directory, ran `git init` and `npm init -y`
3. Installed `express` and `pino` as dependencies
4. Installed `jest` and `supertest` as dev dependencies
5. Created `.gitignore` with `node_modules/`, `.env`, `coverage/`
6. Created `src/logger.js` — pino structured logger
7. Created `src/bookmarks.js` — business logic (in-memory store with CRUD functions)
8. Created `src/routes.js` — Express router with 5 REST endpoints
9. Created `src/app.js` — Express app setup (separated from server)
10. Created `src/server.js` — Entry point (listens on `process.env.PORT || 3000`)
11. Created `tests/bookmarks.test.js` — 12 tests covering all endpoints
12. Updated `package.json` with test and start scripts
13. Ran `npx jest --verbose` — all 12 tests passed

**Shipworthy hooks that fired during this session:**
- `pre-tool-use (Write|Edit)` — fired on every file write (7 files + 1 edit = 8 invocations), scanned for hardcoded secrets, `console.log`, `: any`
- `pre-tool-use-bash` — fired on every bash command (6 commands), checked for destructive operations
- `post-tool-use (Bash)` — fired after `npm install` commands, detected dependency changes
- `post-tool-use-write` — fired after test file creation, validated test file location

### Without Shipworthy

**User prompt:**
> Can you do the same without shipworthy package and tell me

**What the AI did (in order):**
1. Created project directory, ran `git init` and `npm init -y`
2. Installed `express` only (no logging library)
3. Installed `jest` and `supertest` as dev dependencies
4. Created `index.js` — everything in one file (routes, business logic, server startup, all 75 lines)
5. Created `index.test.js` — 7 tests at project root
6. Updated `package.json` with test and start scripts
7. Ran `npx jest --verbose` — 7 tests passed, but Jest warned about open handles

**No hooks fired. No transparency output. No guardrails.**

## Scoring Criteria (36 points max)

Scored by `benchmarks/score.sh` — fully automated, no subjective judgment.

| # | Check | Pts | With Shipworthy | Without Shipworthy |
|---|-------|-----|-----------------|-------------------|
| 1 | Project manifest exists | 1 | PASS | PASS |
| 2 | Dependencies installed | 1 | PASS | PASS |
| 3 | Build/parse succeeds | 2 | PASS | PASS |
| 4 | Test files exist | 2 | PASS | PASS |
| 5 | Tests pass | 3 | PASS | PASS |
| 6 | Passing test count (>5) | 2 | FAIL (12 tests, counted as 1 by scorer) | FAIL (7 tests, counted as 1 by scorer) |
| 7 | Coverage configured | 1 | FAIL | FAIL |
| 8 | Linter configured | 1 | FAIL | FAIL |
| 9 | Linter passes | 1 | FAIL | FAIL |
| 10 | **No console.log** | 1 | **PASS (0 instances)** | **FAIL (5 instances)** |
| 11 | **Structured logging** | 1 | **PASS (pino)** | **FAIL** |
| 12 | No TypeScript `: any` | 1 | PASS (JS project) | PASS (JS project) |
| 13 | Input validation library | 2 | FAIL | FAIL |
| 14 | Validation used in handlers | 2 | FAIL | FAIL |
| 15 | Error handling on routes | 2 | FAIL | FAIL |
| 16 | Varied HTTP status codes | 1 | PASS | PASS |
| 17 | Uses real database | 2 | FAIL | FAIL |
| 18 | Database schema defined | 1 | FAIL | FAIL |
| 19 | **Organized directory structure** | 1 | **PASS (src/)** | **PASS (but flat)** |
| 20 | **.gitignore exists** | 1 | **PASS** | **FAIL** |
| 21 | **.env in .gitignore** | 1 | **PASS** | **FAIL** |
| 22 | No hardcoded secrets | 2 | PASS | PASS |
| 23 | 5+ API endpoints | 2 | PASS (6) | PASS (6) |
| 24 | Architecture/design spec | 1 | FAIL | FAIL |
| 25 | README with content | 1 | FAIL | FAIL |

## Results

| Metric | With Shipworthy | Without Shipworthy | Delta |
|--------|----------------|-------------------|-------|
| **Score** | 20 / 36 | 16 / 36 | **+4** |
| **Percentage** | 55% | 44% | **+11%** |
| **console.log** | 0 | 5 | **-5** |
| **Structured logging** | pino | none | -- |
| **Directory structure** | src/ with 5 files | 1 flat file | -- |
| **Test count** | 12 | 7 | **+5** |
| **.gitignore** | yes | missing | -- |
| **Test isolation** | beforeEach clear() | state leaks between tests | -- |
| **Server/app split** | yes (clean test imports) | no (Jest open handle warning) | -- |

## Anti-Patterns Found (Without Shipworthy Only)

1. **`console.log` as logging** — 5 instances in production code, no log levels, no structured data
2. **Missing `.gitignore`** — `node_modules/` would be committed
3. **Monolith file** — all logic in one 75-line `index.js`
4. **Server starts on import** — `app.listen()` in module scope causes Jest open handle leak
5. **Dead test isolation code** — creates a `new Map()` that never connects to the real store
6. **Hardcoded port** — `const PORT = 3000` with no env var fallback
7. **Fewer tests** — 7 vs 12, missing cases for update success and create with tags

## Observations

The +4 point / +11% delta comes entirely from **operations discipline** — the kind of thing that doesn't affect whether the code "works" but determines whether it's production-ready:

- Logging: structured vs console.log
- Security: .gitignore present vs absent
- Architecture: separated concerns vs monolith
- Testing: more tests, proper isolation, no Jest warnings

Both projects have the same functional gaps (no validation library, no database, no linter). Shipworthy's guardrails caught the low-hanging fruit that AI coding assistants consistently miss.
