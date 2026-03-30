# Shipworthy for Founders

## Why You Need This

You're building fast. AI coding tools let you ship features in hours instead of weeks. But AI-generated code has problems you won't see until real users find them:

- **No tests** — every change can break something else
- **Security gaps** — hardcoded secrets, missing auth checks, SQL injection
- **Fragile architecture** — works today, breaks tomorrow when you add the next feature
- **In-memory data** — all your user accounts disappear when the server restarts

These aren't theoretical. We [benchmarked it](../reference/benchmarks.md):
- AI code without guardrails scored 12/25 (C grade)
- AI code with Shipworthy scored 22/25 (A grade)

## What Shipworthy Does for You

You describe what you want in plain language. Shipworthy ensures it's built correctly.

| You say | Shipworthy ensures |
|---------|-------------------|
| "I need users to sign up and log in" | Passwords hashed with bcrypt, sessions expire, safe error messages |
| "I want to accept payments" | Stripe Checkout (not raw card handling), webhook verification, idempotency |
| "Build me a dashboard" | Auth check on the route, loading/error states, accessible markup |
| "Put it on the internet" | Environment variables for secrets, HTTPS, error tracking, health checks |

You never have to ask for any of this. You probably don't even know what bcrypt or webhook verification means — and you don't need to.

## The InvoiceFlow Case Study

We tested Shipworthy with a realistic founder prompt — building a full invoicing SaaS:

> "I'm building InvoiceFlow — an invoicing tool for freelancers. I need user accounts, client management, invoices with line items, a dashboard showing revenue..."

**Result**: Shipworthy produced a production-ready backend with SQLite database, Zod validation, 30 passing tests, structured error handling, and user data isolation — all from a business description with zero technical jargon.

The version without Shipworthy also worked, but used manual validation (brittle), had fewer tests (23 vs 30), and missed IDOR prevention tests (meaning a future refactor could accidentally expose one user's data to another).

## Getting Started

```bash
npx shipworthy init
```

Then just start coding with your AI agent. Shipworthy handles the engineering.
