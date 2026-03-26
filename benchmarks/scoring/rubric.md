# Scoring Rubric

## Overview

Each benchmark task is scored on a **20-point scale** using a combination of automated checks and LLM-as-judge evaluation. Scores are deterministic and reproducible: every check is binary (pass or fail), worth a fixed number of points, and verified by a concrete command or grep pattern.

---

## Point Values

Each check in a task's scoring table is worth **1 to 3 points** depending on its importance:

| Weight | Meaning | Examples |
|--------|---------|----------|
| 3 pts | Critical -- a professional would never skip this | Tests exist and pass, build compiles |
| 2 pts | Important -- expected in any production codebase | Input validation, error handling middleware, proper status codes |
| 1 pt | Good practice -- distinguishes solid from great work | No `any` types, structured logging, .gitignore present |

All checks are **binary**: the code either passes or it does not. Partial credit is never awarded for a single check. This eliminates subjectivity from the automated scoring layer.

---

## Letter Grades

| Grade | Points | Interpretation |
|-------|--------|----------------|
| **A** | 18 -- 20 | Production-ready. Meets all critical and nearly all important checks. |
| **B** | 14 -- 17 | Solid work with minor gaps. Missing one or two important practices. |
| **C** | 10 -- 13 | Functional but incomplete. Several production-readiness gaps. |
| **D** | 6 -- 9 | Barely functional. Major quality, security, or reliability issues. |
| **F** | 0 -- 5 | Non-functional or fundamentally flawed. |

---

## Scoring Categories

Every check in every task maps to one of five categories. This allows cross-task comparison and identifies systemic strengths or weaknesses.

### 1. Testing
*Do tests exist? Do they pass? Do they cover meaningful scenarios?*

- Test files are present (*.test.*, *.spec.*, test_*, *_test.go)
- Test runner is configured and `npm test` / `pytest` / `go test` exits 0
- At least 3 meaningful test cases (not just smoke tests)
- Edge cases are tested (empty input, not-found, invalid data)
- Test coverage is reported when tooling is available

### 2. Security
*Are secrets safe? Is input validated? Is auth implemented when required?*

- No hardcoded passwords, API keys, or tokens in source code
- Input validation uses a schema library (zod, joi, yup, pydantic) -- not ad-hoc if-checks
- Environment variables are used for configuration with sensible defaults
- Authentication and authorization are implemented when the task requires them
- OWASP Top 10 concerns are addressed where applicable

### 3. Architecture
*Is the code well-structured, typed, and maintainable?*

- Clean separation of concerns (routes, controllers, models, middleware)
- TypeScript strict mode enabled (or equivalent type safety in other languages)
- No escape-hatch types (`any`, `object`, `interface{}`)
- Consistent naming conventions
- Interfaces and types are explicitly defined for domain objects

### 4. Reliability
*Does the code handle failures gracefully?*

- Error-handling middleware or equivalent centralized error handling
- Structured error responses (not bare strings or raw stack traces)
- Try/catch blocks that log and propagate errors (not swallow them)
- Proper HTTP status codes (201 for create, 404 for not found, 400 for bad input)
- Edge cases handled (empty arrays, missing fields, concurrent access)

### 5. Operations
*Is the code ready to deploy and monitor?*

- Build passes without errors
- Lint configuration is present and passes
- Lock file exists (package-lock.json, yarn.lock, go.sum)
- .gitignore excludes build artifacts and dependencies
- Logging is structured (not bare console.log in production code)
- CI pipeline or Dockerfile present when appropriate

---

## Aggregate Scoring (Full Suite)

When all 10 tasks are evaluated, the aggregate metrics are:

| Metric | Calculation |
|--------|-------------|
| **Total Score** | Sum of all 10 task scores, out of **200** |
| **Category Breakdown** | Points earned per category across all tasks, shown as a percentage |
| **Grade Distribution** | Count of A/B/C/D/F grades across the 10 tasks |
| **Consistency Score** | Standard deviation of task scores (lower is better) |

### Aggregate Grades

| Grade | Total Score |
|-------|-------------|
| **A** | 180 -- 200 |
| **B** | 140 -- 179 |
| **C** | 100 -- 139 |
| **D** | 60 -- 99 |
| **F** | 0 -- 59 |

---

## LLM-as-Judge Layer

In addition to automated checks, each task is evaluated by an LLM judge using the prompt in `llm-judge-prompt.md`. The judge performs **blind A/B comparison** and scores each codebase on the same five categories (Correctness, Security, Testing, Architecture, Production Readiness) on a 0--5 scale.

The LLM judge score is reported alongside the automated score but does **not** replace it. The two scores serve different purposes:

- **Automated score**: Deterministic, reproducible, checks concrete properties
- **LLM judge score**: Holistic, evaluates code quality and design decisions that are hard to grep for

When the two scores disagree significantly, the evaluation report flags the discrepancy for manual review.

---

## Fairness Controls

1. **Identical prompts**: Both runs (with-plugin and without-plugin) receive the exact same task prompt. No hints, follow-ups, or corrections.
2. **Identical starter code**: Both runs start from the same package.json, tsconfig.json, and directory structure.
3. **Blind comparison**: The LLM judge does not know which codebase used the plugin. Assignment to A/B is randomized.
4. **Deterministic checks**: Automated checks use grep, compiler output, and test exit codes -- not subjective assessment.
5. **Multiple runs**: Results should be averaged over at least 3 runs per task to account for LLM non-determinism.
