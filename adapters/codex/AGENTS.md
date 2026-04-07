# Shipworthy — Production Engineering Guardrails for Codex

When using this adapter, first output:
> ⚓ **shipworthy** › adapter: `codex` — translating Shipworthy skills for Codex

> Is your code worthy of shipping?

## Instructions

You are enhanced with Shipworthy engineering guardrails. Apply these principles automatically on every task.

### Non-Negotiable Defaults

1. NEVER use console.log — use structured logging (pino for Node.js).
2. ALWAYS validate inputs with Zod (TypeScript) or Pydantic (Python).
3. ALWAYS write tests first (RED-GREEN-REFACTOR). Configure coverage tooling.
4. ALWAYS set up a linter (ESLint, Ruff, golangci-lint).
5. NEVER use `: any` in TypeScript — use `unknown` and narrow.
6. Use proper HTTP status codes (201, 204, 400, 401, 403, 404).
7. ALWAYS use a real database (SQLite minimum) — never in-memory arrays.
8. NEVER hardcode secrets — use environment variables.
9. Hash passwords with bcrypt/argon2 — never MD5/SHA/plaintext.
10. Never expose stack traces or internal details in error responses.

### Intent-to-Spec (Before Coding)

For non-trivial features, generate a lightweight spec before writing code:
- What the user wants, deliverables, 3-7 acceptance criteria
- Save to `.shipworthy/specs/[feature-name].md`
- Skip for quick fixes. Do it silently for non-technical users.

### Project Diagnosis

At session start, check for critical gaps: .gitignore with .env, tests exist, linter configured, CI present, architecture spec exists. Flag critical issues before proceeding.

### Workflow

1. Generate spec (for features) — capture intent, deliverables, acceptance criteria
2. Understand the task — read existing code, understand patterns
3. Write a failing test for the expected behavior
4. Write minimal code to pass the test
5. Refactor while keeping tests green
6. Verify: run tests, build, lint. Provide evidence.

### Architecture

Read `.shipworthy/architecture.md` if it exists — its rules are mandatory constraints. If it doesn't exist, suggest creating one.

### Verification

Before claiming completion: run the proof command, read its output, confirm your claim matches reality. Never say "should work" — prove it works.

## Codex Plugin for Claude Code — Optional Cross-Validation (codex-plugin-cc)

> **This section is optional.** It applies only when Codex is used alongside Claude Code via the `codex-plugin-cc` plugin for dual-model review. If you are using Codex standalone (with this `AGENTS.md` copied to your project root), everything above works independently — skip this section.

When both tools are available, Codex serves as an independent reviewer and cross-validator. This section defines how the two models collaborate.

### Setup

Install the plugin in Claude Code:

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

### Available Commands

| Command | Purpose |
|---------|---------|
| `/codex:review` | Structured code review with severity-rated findings |
| `/codex:adversarial-review` | Challenge-mode review — questions design choices |
| `/codex:rescue` | Delegate investigation or debugging to Codex |
| `/codex:status` | Poll background job progress |
| `/codex:result` | Fetch completed job output |
| `/codex:cancel` | Terminate a background job |
| `/codex:setup` | Validate install, configure review gate |

### Cross-Validation Workflow

The primary use case is **Claude builds, Codex reviews**:

1. **Claude implements** the feature following Shipworthy guardrails (TDD, specs, architecture compliance)
2. **Codex reviews** via `/codex:review --base main` — returns structured findings with file:line references
3. **Adversarial review** via `/codex:adversarial-review` — challenges design decisions and assumptions
4. **Address findings** by severity (Critical → High → Medium → Low)
5. **Re-review** after fixes: `/codex:review --base main --wait`

### High-Volume PR Review

For teams receiving many PRs:

1. Run `/codex:review --base main --background` per branch
2. Poll all with `/codex:status --all`
3. Fetch results with `/codex:result <job-id>`
4. Triage by severity across all PRs

### Review Gate

Enable automatic review before session end:

```
/codex:setup --enable-review-gate
```

This triggers a targeted Codex review on every Stop event. Critical findings block the session until resolved. Disable with `--disable-review-gate` during exploratory work.

### Delegation

When stuck, hand off to Codex:

```
/codex:rescue investigate the flaky test in test_upload.py
/codex:status
/codex:result
/codex:rescue --resume apply the fix
```

### Review Output

Codex reviews return structured JSON with `verdict` (approve/needs-attention), `findings` array (severity, file, line, recommendation), and `next_steps`. Use this structure to systematically address issues.
