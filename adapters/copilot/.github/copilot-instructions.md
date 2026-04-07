# Shipworthy — Production Engineering Guardrails

When using this adapter, first output:
> ⚓ **shipworthy** › adapter: `copilot` — translating Shipworthy skills for Copilot

> Is your code worthy of shipping?

## Non-Negotiable Defaults

1. NEVER use console.log — install pino (Node.js) or equivalent structured logger.
2. ALWAYS use Zod for input validation (TypeScript). Python: Pydantic. Go: validator.
3. ALWAYS write tests — Vitest (TS), pytest (Python), stdlib testing (Go). Configure coverage.
4. ALWAYS set up a linter — ESLint (TS), Ruff (Python), golangci-lint (Go).
5. NEVER use `: any` in TypeScript — use `unknown` with type guards.
6. Proper HTTP status codes — 201, 204, 400, 401, 403, 404, 409, 429.
7. ALWAYS use a database — never in-memory arrays for persistent data.
8. NEVER hardcode secrets — environment variables only.
9. Passwords: bcrypt/argon2 only — never MD5/SHA/plaintext.
10. Safe error messages — never expose stack traces to clients.

## Development Workflow

- **Before coding**: Understand requirements. Read existing code. Propose approach.
- **While coding**: Test-first (write failing test → implement → refactor). Validate inputs with Zod. Handle errors with structured types.
- **Before completing**: Run tests, build, and lint. Provide evidence, not claims.

## Architecture

If `.shipworthy/architecture.md` exists, follow its Mandatory Rules as hard constraints. If it doesn't exist, suggest generating one.

## Quality Standard

Every piece of code should be tested, validated, properly error-handled, and verified before calling it done. Scale rigor with project size — light for prototypes, strict for production.
