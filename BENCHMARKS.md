# Benchmark Results: Engineering With Vibes

## How We Tested

### The Question

Does this plugin actually improve the code that AI produces? Or is it just documentation that sounds good but changes nothing?

We designed an unbiased benchmark to find out.

### Methodology

We run the **exact same coding task** through Claude Code twice:
1. **Without the plugin** — bare Claude Code, no CLAUDE.md, no skills, no hooks
2. **With the plugin** — Claude Code with the full Engineering With Vibes skill set injected via CLAUDE.md

Both runs start from an identical starter project (same `package.json`, same `tsconfig.json`, same empty `src/` directory). Both receive the **identical prompt** with zero follow-up. The only variable is whether the plugin's skills are loaded.

### How Bias Is Eliminated

| Bias Risk | Prevention |
|-----------|-----------|
| **Prompt bias** | Identical prompt for both runs — word for word |
| **Environment bias** | Clean temp directory, fresh git repo, fresh `npm install` for each run |
| **Selection bias** | Tasks are pre-defined, not cherry-picked after seeing results |
| **Measurement bias** | 15 automated binary checks (PASS/FAIL) — no subjective scoring |
| **Position bias** (for LLM judge) | Random coin flip assigns with/without to A or B |
| **Knowledge bias** (for LLM judge) | Judge prompt never mentions "plugin" — only sees "Codebase A" and "Codebase B" |

### What Gets Measured

15 automated checks, each binary PASS/FAIL:

| # | Check | Points | What It Detects |
|---|-------|--------|----------------|
| 1 | Tests exist | 3 | Are there any test files (*.test.*, *.spec.*)? |
| 2 | Tests pass | 3 | Does `npm test` / `pytest` exit with code 0? |
| 3 | Build passes | 2 | Does `tsc --noEmit` / build command succeed? |
| 4 | No hardcoded secrets | 2 | Grep for passwords, API keys, AKIA patterns |
| 5 | No console.log | 1 | console.log in non-test files |
| 6 | Input validation library | 2 | Zod, Joi, Yup, Pydantic detected |
| 7 | Error handling | 2 | try/catch, error middleware, AppError patterns |
| 8 | TypeScript strict | 2 | `strict: true` in tsconfig.json |
| 9 | No `any` types | 1 | `: any` in .ts files |
| 10 | HTTP status codes | 2 | Proper 4xx/5xx usage in route handlers |
| 11 | Environment variables | 1 | `process.env` or `os.environ` usage |
| 12 | Test coverage tooling | 1 | Coverage tool configured |
| 13 | Lint configured | 1 | ESLint, Prettier, or equivalent present |
| 14 | No circular imports | 1 | Mutual import detection |
| 15 | Lock file present | 1 | package-lock.json or equivalent committed |

**Total: 25 points per task. Grade: A (20-25), B (14-19), C (10-13), D (6-9), F (0-5)**

---

## Benchmark Tasks

We designed 10 tasks that cover the full spectrum of what developers build:

| # | Task | What It Tests |
|---|------|--------------|
| 01 | Build a REST API with CRUD | API design, types, validation, error handling |
| 02 | Add JWT authentication | Security, password hashing, auth middleware, session handling |
| 03 | Add Stripe payment integration | Third-party APIs, webhook verification, secrets management |
| 04 | Fix an IDOR security bug | Debugging, authorization, regression testing |
| 05 | Build a dashboard page | Frontend, accessibility, data fetching, state management |
| 06 | Refactor raw SQL to Prisma ORM | Database migration, backward compatibility |
| 07 | Add rate limiting + structured logging | Observability, middleware, replace console.log |
| 08 | Set up GitHub Actions CI/CD | Operations, pipeline design, caching |
| 09 | Fix N+1 query performance bug | Performance debugging, query optimization, pagination |
| 10 | Cross-session consistency | Does session 2 break session 1's code? (architecture memory) |

---

## Results

### Task 01: REST API CRUD

**Prompt (identical for both runs):**
> Build a REST API for a todo app with CRUD operations. Use Express and TypeScript. Include proper error handling and input validation.

**Starter project:** Empty Express + TypeScript project with `package.json`, `tsconfig.json`, and `src/index.ts` (health endpoint only).

#### Scores

| | With Plugin | Without Plugin |
|---|---|---|
| **Total Score** | **22/25 (A)** | **12/25 (C)** |
| **Improvement** | | **+83%** |

#### Detailed Check Results

| Check | With Plugin | Without Plugin |
|-------|------------|----------------|
| Tests exist | PASS (22 tests) | FAIL (0 tests) |
| Tests pass | PASS (all green) | FAIL (no tests) |
| Build passes | PASS | PASS |
| No hardcoded secrets | PASS | PASS |
| No console.log | PASS | FAIL (1 found) |
| Input validation library | PASS (Zod) | FAIL (manual only) |
| Error handling | PASS (structured types) | PASS (basic) |
| TypeScript strict | PASS | PASS |
| No `any` types | PASS | PASS |
| HTTP status codes | PASS (201, 204, 400, 404) | PASS (201, 400, 404) |
| Environment variables | PASS | PASS |
| Test coverage tooling | FAIL | FAIL |
| Lint configured | FAIL | FAIL |
| No circular imports | PASS | PASS |
| Lock file present | PASS | PASS |

#### Files Produced

**With Plugin (8 source files, well-separated concerns):**
```
src/
├── __tests__/todos.test.ts   — 22 tests covering all CRUD + edge cases
├── app.ts                    — Express app with global error handler
├── errors.ts                 — Structured error types (AppError, NotFoundError, ValidationError)
├── index.ts                  — Server entry point (separated from app for testability)
├── routes/todos.ts           — CRUD route handlers with error forwarding
├── store.ts                  — In-memory todo storage (isolated data layer)
├── types.ts                  — Todo interface
└── validation.ts             — Zod schemas for create/update
```

**Without Plugin (5 source files, simpler structure):**
```
src/
├── index.ts                  — Express server setup + route mounting
├── middleware/errorHandler.ts — Centralized error handling
├── routes/todos.ts           — CRUD route handlers
├── types.ts                  — Todo interface + AppError class
└── validation.ts             — Manual input validation functions
```

#### Key Differences

| Aspect | With Plugin | Without Plugin |
|--------|------------|----------------|
| **Testing** | 22 tests covering happy path, validation errors, 404s, edge cases | Zero tests |
| **Validation** | Zod schemas with type inference | Manual if/else checks |
| **Error types** | 3 dedicated classes: AppError, NotFoundError, ValidationError | 1 class: AppError with manual status codes |
| **Architecture** | App separated from server (testable), dedicated store module | App and server in same file |
| **Status codes** | Includes 204 No Content for DELETE | Missing 204 for DELETE |
| **Console.log** | None in production code | 1 instance in server startup |

---

---

## Founder Test Results

These tests use **non-technical language** — the prompts describe business outcomes, not technical implementations. The founder doesn't know what REST, JWT, bcrypt, or middleware means. They just describe what they want.

The question: **does Shipworthy produce production-grade code even when the user can't ask for it?**

### Founder Test 01: "I need users to sign up and log in"

**Prompt (identical for both runs):**
> I need users to be able to create an account and log in to my app. They should sign up with their email and password, and once they're logged in they should stay logged in. If someone tries to access the app without logging in, they should be sent to the login page.

Note: This prompt does NOT mention bcrypt, JWT, hashing, middleware, rate limiting, or any security concept. A non-technical founder wouldn't know to ask for these.

#### Scores

| | With Plugin | Without Plugin |
|---|---|---|
| **Automated Score** | **18/25 (A)** | **17/25 (B)** |

#### Security Deep-Dive (The Stuff Founders Can't Ask For)

| Security Check | With Plugin | Without Plugin |
|----------------|------------|----------------|
| Passwords hashed (bcrypt) | PASS | PASS |
| Session/token expiry | PASS (30-day JWT) | PASS (7-day session) |
| Safe error messages | PASS ("Invalid email or password") | PASS ("Invalid email or password") |
| Secrets from env vars | PASS (JWT_SECRET) | PASS (SESSION_SECRET) |
| No `any` types | PASS (0 any) | FAIL (2 any types) |
| Tests | PASS (14 tests) | PASS (14 tests) |
| **Data persistence** | **SQLite (survives restart)** | **In-memory (lost on restart)** |

#### Key Finding

Both runs produced secure auth — bcrypt hashing, safe error messages, env-based secrets, 14 tests. The founder would get a working, secure login system either way.

However, the **with-plugin** output was more production-ready:
- **SQLite database** instead of in-memory storage (data survives server restarts)
- **Zero `any` types** (stricter TypeScript)
- **Structured error codes** (`INVALID_CREDENTIALS`, `VALIDATION_ERROR`) vs raw error strings
- **JWT with HTTP-only cookies** vs express-session (more scalable for APIs)

The **without-plugin** output had a critical production bug: **in-memory storage means all user accounts are lost when the server restarts.** A founder would discover this the hard way in production. The plugin's architecture skills guided Claude to use a proper database.

---

## How to Run Benchmarks Yourself

### Prerequisites
- Claude Code CLI installed and authenticated
- Node.js and npm
- jq (for JSON processing)

### Run a single task
```bash
cd benchmarks
./run-benchmark.sh --task 1 --both
```

### Run all 10 tasks
```bash
cd benchmarks
./run-benchmark.sh --all --both
```

### Score an existing project
```bash
./benchmarks/scoring/automated-checks.sh /path/to/your/project
```

### Run blind A/B comparison
```bash
./benchmarks/compare-ab.sh results/task-01-with/ results/task-01-without/
```

### Interpret results

Each task produces:
- `results/[task]-with-score.json` — detailed score for the with-plugin run
- `results/[task]-without-score.json` — detailed score for the without-plugin run
- `results/[task]-scores.json` — combined comparison

---

## How the Plugin Gets Injected

For the "with plugin" run, the benchmark runner creates a `CLAUDE.md` file in the project root containing the full content of these skills:

1. **using-shipworthy** (master routing skill — tells Claude which skills to apply)
2. **test-driven-development** (TDD discipline — write failing tests first)
3. **security-first-development** (OWASP checks, secrets, validation)
4. **api-design-standards** (REST conventions, status codes, error format)
5. **error-handling-patterns** (structured errors, recovery strategies)
6. **verification-before-completion** (evidence before claiming "done")
7. **quality-gates** (graduated checks based on project size)

This simulates what the session-start hook does in real usage: loading the skill context into every Claude Code session.

For the "without plugin" run, there is no `CLAUDE.md`. Claude Code operates with its default behavior only.

---

## Reproducing Results

Results may vary between runs because LLM outputs are non-deterministic. To get statistically meaningful results:

1. Run each task **3-5 times** per configuration
2. Average the automated scores
3. Report the mean, min, and max for each check
4. Use the blind A/B comparison for qualitative assessment

The automated scoring is deterministic given the same code — the variance comes from what Claude generates, not from how we score it.

---

## Hook Tests (26/26 passing)

In addition to the benchmark suite, the plugin's hooks are tested with unit tests:

### session-start hook (11 tests)
- Output is valid JSON
- Architecture.md present → rules injected
- No architecture.md → "NOT FOUND" message
- Tech debt → count surfaced
- JSON escaping handles special characters
- Subdirectory execution finds architecture.md
- Missing SKILL.md → graceful fallback
- Tier detection: no package.json = builder
- Tier detection: package.json, no tests = builder
- Tier detection: package.json + tests = maker
- Tier detection: package.json + tests + CI = engineer

### pre-tool-use hook (7 tests)
- Normal file write → approve
- Hardcoded password → advisory warning
- AWS key pattern (AKIA...) → advisory warning
- console.log in production file → advisory warning
- console.log in test file → no warning (correctly excluded)
- Empty input → approve (no crash)
- Missing architecture.md → approve (no crash)

### post-tool-use hook (8 tests)
- git commit → quality reminder
- git commit --amend → amend-specific warning
- npm install package-name → new dep advisory
- npm ci → no "new dep" warning (installing existing)
- pip install -r requirements.txt → no "new dep" warning
- pip install newpackage → new dep advisory
- Random bash command → valid empty JSON
- Empty command → valid empty JSON

Run all hook tests:
```bash
bash tests/hooks/test-session-start.sh
bash tests/hooks/test-pre-tool-use.sh
bash tests/hooks/test-post-tool-use.sh
```
