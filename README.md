# Engineering With Vibes

**Vibe coding is how you start; engineering is what keeps it alive.**

A Claude Code plugin that auto-activates on session start and silently installs production engineering guardrails. Vibe coders build real systems — not just prototypes — without thinking about process.

## What It Does

When you install this plugin, every Claude Code session automatically gets:

- **Architecture awareness** — auto-detects your project type, generates an architecture spec, and enforces it across sessions
- **25 engineering skills** — TDD, quality gates, security, API design, database design, debugging, code review, and more
- **4 specialized agents** — code reviewer, architecture analyzer, security auditor, test strategist
- **Graduated quality gates** — lightweight checks for small projects, enterprise-grade checks as complexity grows
- **Tech debt tracking** — shortcuts are documented, not forgotten

## Install

```
/plugin install engineering-with-vibes
```

## How It Works

### Auto-Activation
The plugin fires a session-start hook on every Claude Code session. This injects the master routing skill and your project's architecture constraints into the conversation. No manual setup needed.

### Architecture Scaffold System
On first use, the plugin detects your project type (Next.js, Express, FastAPI, Go, React, Python, etc.) and generates an architecture specification at `.engineering-with-vibes/architecture.md`. This spec contains Mandatory Rules that are enforced on every future session — so Claude never forgets your project's conventions.

### Invisible Discipline
Skills activate automatically based on what you're doing:
- Writing a new feature? → brainstorming → planning → TDD
- Creating an API endpoint? → api-design-standards + security-first-development
- Adding a dependency? → dependency-management
- Debugging? → systematic 4-phase debugging
- Finishing up? → verification-before-completion + quality-gates

### Graduated Quality Gates

| Level | Threshold | What's Checked |
|-------|-----------|---------------|
| 1 | Always | Tests pass, build clean, no secrets |
| 2 | 10+ files | Coverage >70%, no untracked TODOs |
| 3 | 50+ files | Bundle budgets, no circular imports |
| 4 | 100+ files | Performance, accessibility, security scan |

## Skills (25)

### Core
- **using-engineering-with-vibes** — master router, loaded every session
- **architecture-awareness** — project detection + architecture spec generation

### Planning
- **brainstorming** — 9-step design discovery before implementation
- **writing-plans** — bite-sized TDD implementation plans
- **executing-plans** — systematic task execution with verification

### Quality
- **test-driven-development** — RED-GREEN-REFACTOR discipline
- **quality-gates** — graduated pre-commit checks
- **verification-before-completion** — evidence before claims
- **error-handling-patterns** — structured errors and recovery

### Security
- **security-first-development** — OWASP-aware coding practices
- **dependency-management** — vet, audit, and pin packages

### Architecture
- **api-design-standards** — REST conventions and type-safe contracts
- **database-design** — schemas, migrations, indexing, N+1 prevention
- **performance-budgets** — bundle size, response time, query limits
- **observability-by-default** — structured logging, tracing, health checks

### Collaboration
- **subagent-driven-development** — dispatch agents with 2-stage review
- **dispatching-parallel-agents** — concurrent independent tasks
- **requesting-code-review** — structured review via code-reviewer agent
- **receiving-code-review** — technical verification over performative agreement

### Operations
- **using-git-worktrees** — isolated workspaces for parallel development
- **finishing-a-development-branch** — 5-step completion workflow
- **ci-cd-awareness** — pipeline design, rollback, feature flags
- **tech-debt-tracking** — document and track shortcuts

### Frontend
- **accessibility** — WCAG 2.1 AA baseline
- **frontend-standards** — component patterns, state management

### Documentation
- **documentation-as-code** — JSDoc, README sync, ADRs, changelog

### Debugging
- **systematic-debugging** — 4-phase root cause investigation

### Meta
- **writing-skills** — TDD for documentation, create new skills

## Commands

- `/scaffold` — generate or regenerate the architecture specification
- `/audit` — run a full quality audit across all dimensions
- `/health` — quick project health dashboard

## Templates

Architecture templates for: Next.js, Express, FastAPI, Go, React SPA, TypeScript, Python, Monorepo.

## Inspired By

- [Superpowers](https://github.com/obra/superpowers) — battle-tested Claude Code skills for TDD, planning, verification, and debugging
- [FleetShield AI](https://github.com/Vimalk0703/geotab-hackathon) — architecture-aware development using CLAUDE.md as an architectural contract

## Philosophy

Most "vibe coders" can build impressive prototypes but hit walls at session boundaries, codebase growth, and production deployment. This plugin closes the gap with three pillars:

1. **Invisible discipline** — engineering principles enforced automatically, not taught didactically
2. **Architecture as memory** — maintains architectural knowledge across sessions
3. **Graduated rigor** — lightweight for new projects, enterprise-grade as complexity grows

## License

MIT
