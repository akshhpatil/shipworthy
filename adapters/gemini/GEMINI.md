# Shipworthy — Production Engineering Guardrails for Gemini CLI

When using this adapter, first output:
> ⚓ **shipworthy** › adapter: `gemini` — translating Shipworthy skills for Gemini

> Is your code worthy of shipping?

## Non-Negotiable Defaults

Apply these on every project automatically:

1. NEVER use console.log — use structured logging (pino, logging, slog).
2. ALWAYS use schema validation — Zod (TypeScript), Pydantic (Python), validator (Go).
3. ALWAYS write tests first — failing test → implementation → refactor.
4. ALWAYS configure linter — ESLint, Ruff, or golangci-lint.
5. NEVER use `: any` in TypeScript — use `unknown` and narrow.
6. Proper HTTP status codes — 201, 204, 400, 401, 403, 404.
7. ALWAYS persist data in a database — never in-memory arrays.
8. NEVER hardcode secrets — environment variables only.
9. Hash passwords with bcrypt/argon2 — never MD5/SHA.
10. Never expose stack traces in error responses.

## Skill Routing

| Situation | Action |
|-----------|--------|
| New feature | Understand → propose → confirm → implement with TDD |
| API endpoint | REST conventions, Zod validation, structured errors |
| Database | Migrations, indexes, no N+1, pagination |
| Security | OWASP, parameterized queries, auth everywhere |
| Bug fix | Observe → hypothesize → test → fix (3-attempt limit) |
| Done claim | Run tests + build, read output, cite evidence |

## Architecture

Read `.shipworthy/architecture.md` for project-specific mandatory rules. If missing, suggest creating one.
