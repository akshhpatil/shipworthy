# Shipworthy

> Vibe coding is how you start; engineering is what keeps it alive.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue)]()
[![Benchmark: +83%](https://img.shields.io/badge/Benchmark-+83%25%20Quality-brightgreen)](BENCHMARKS.md)

---

## The Problem

AI-assisted coding is transforming how software gets built. But the data tells a sobering story:

- **1.7x more bugs** in AI-generated code compared to human-written code (CodeRabbit, 2025)
- **40% of AI-generated code** contains security vulnerabilities
- **2026 is "the year of technical debt from vibe coding"** (Forrester)

The root cause is not the AI. It is the **absence of engineering discipline between sessions.** The AI forgets your architecture the moment the session ends. It skips tests because you did not ask for them. It introduces security holes because nobody told it your auth strategy. Every new session starts from zero.

You end up building the same feature three times: once to get it working, once to fix what it broke, and once more when you realize the fix broke something else.

## The Solution

**Shipworthy** is a Claude Code plugin that auto-activates every session and silently enforces production engineering practices. It detects your project type, generates an architecture spec, and maintains it across sessions. You vibe code at full speed -- the plugin handles TDD, security, quality gates, and 29 engineering skills invisibly. No configuration, no ceremony, no workflow changes.

## Install

```bash
# Claude Code (full experience — hooks + skills + quality gates)
/plugin install shipworthy

# Any AI agent (CLI setup)
npx shipworthy init

# Specific agent
npx shipworthy init --agent cursor
npx shipworthy init --agent copilot
```

## Supported AI Agents

| Agent | Setup | Hooks | Skills | Quality Gates |
|-------|-------|-------|--------|--------------|
| **Claude Code** | `/plugin install` | Full | Full (42) | Automated |
| **Cursor** | `npx shipworthy init --agent cursor` | Rules | Full | Manual |
| **GitHub Copilot** | `npx shipworthy init --agent copilot` | Rules | Full | Manual |
| **OpenAI Codex** | `npx shipworthy init --agent codex` | Rules | Full | Manual |
| **Windsurf** | `npx shipworthy init --agent windsurf` | Rules | Full | Manual |
| **Gemini CLI** | `npx shipworthy init --agent gemini` | Rules | Full | Manual |

## What Happens In Your First Session

That is the only setup. Here is what happens next:

1. **You open Claude Code on your project.** The plugin fires its session-start hook automatically.
2. **It detects your tech stack.** Next.js? Express? FastAPI? Go? React? Python? It knows.
3. **It generates an architecture spec.** A file at `.shipworthy/architecture.md` captures your project's conventions, mandatory rules, and structure.
4. **From now on, every session enforces those rules.** Claude remembers your architecture, your naming conventions, your patterns -- permanently.
5. **You build features normally.** Say "add a payment endpoint" and Claude automatically applies API design standards, security-first development, TDD, and quality gates. You never asked it to. It just does.
6. **Before completing, it verifies.** Tests pass, no secrets leaked, no regressions, build is clean. Evidence, not claims.

## Three Pillars

### 1. Invisible Discipline
Engineering guardrails activate automatically based on what you are doing. Writing a new feature triggers brainstorming, then planning, then TDD. Creating an API endpoint activates API design standards and security. You never invoke these manually -- they fire when relevant and stay silent when they are not.

### 2. Architecture as Memory
The architecture spec is Claude's long-term memory for your project. Mandatory rules, directory conventions, naming patterns, tech choices -- all persisted and enforced. Session 5 knows everything session 1 decided. No more "Claude forgot we use Prisma" or "it put the route in the wrong directory again."

### 3. Graduated Rigor
A weekend prototype should not face the same ceremony as an enterprise platform. The plugin scales its enforcement: lightweight checks for small projects, full quality gates as your codebase grows. You start fast and the guardrails tighten as complexity demands it.

## User Experience Tiers

| Tier | Who | Experience |
|------|-----|-----------|
| **Builder** | Non-technical, prototyping | Guardrails are silent. Tests happen invisibly. Plain language feedback when something needs attention. |
| **Maker** | Some experience, growing project | Moderate ceremony. Explains why tests matter. Offers choices on architecture decisions. |
| **Engineer** | Production codebase, CI/CD | Full TDD, quality gates, architecture enforcement. Every PR is verified before completion. |

## Skills (29)

### Core
| Skill | What It Does |
|-------|-------------|
| **using-shipworthy** | Master router -- loaded every session, dispatches to relevant skills |
| **architecture-awareness** | Auto-detects project type, generates and enforces architecture spec |

### Planning
| Skill | What It Does |
|-------|-------------|
| **brainstorming** | 9-step design discovery before any code is written |
| **writing-plans** | Breaks work into bite-sized TDD implementation plans |
| **executing-plans** | Systematic task execution with verification at each step |

### Quality
| Skill | What It Does |
|-------|-------------|
| **test-driven-development** | RED-GREEN-REFACTOR discipline for every feature |
| **quality-gates** | Graduated pre-commit checks that scale with project size |
| **verification-before-completion** | Requires evidence (passing tests, clean build) before marking work done |
| **error-handling-patterns** | Structured errors, recovery strategies, and user-facing messages |

### Security
| Skill | What It Does |
|-------|-------------|
| **security-first-development** | OWASP-aware coding -- input validation, auth, secrets management |
| **dependency-management** | Vet, audit, and pin packages before adding them |

### Architecture
| Skill | What It Does |
|-------|-------------|
| **api-design-standards** | REST conventions, type-safe contracts, consistent error responses |
| **database-design** | Schemas, migrations, indexing, N+1 prevention |
| **performance-budgets** | Bundle size limits, response time targets, query count caps |
| **observability-by-default** | Structured logging, tracing, health checks from day one |
| **resilience-patterns** | Circuit breakers, bulkheads, retries, timeouts, graceful degradation |

### Collaboration
| Skill | What It Does |
|-------|-------------|
| **subagent-driven-development** | Dispatch specialized agents with 2-stage review |
| **dispatching-parallel-agents** | Run independent tasks concurrently for speed |
| **requesting-code-review** | Structured review via the code-reviewer agent |
| **receiving-code-review** | Technical verification over performative agreement |

### Operations
| Skill | What It Does |
|-------|-------------|
| **using-git-worktrees** | Isolated workspaces for parallel development branches |
| **finishing-a-development-branch** | 5-step completion workflow: tests, cleanup, docs, PR, verify |
| **ci-cd-awareness** | Pipeline design, rollback strategies, feature flags |
| **tech-debt-tracking** | Document shortcuts so they get fixed, not forgotten |

### Frontend
| Skill | What It Does |
|-------|-------------|
| **accessibility** | WCAG 2.1 AA baseline for every UI component |
| **frontend-standards** | Component patterns, state management, rendering best practices |

### Documentation
| Skill | What It Does |
|-------|-------------|
| **documentation-as-code** | JSDoc, README sync, ADRs, changelog -- documentation that stays current |

### Debugging
| Skill | What It Does |
|-------|-------------|
| **systematic-debugging** | 4-phase root cause investigation: reproduce, isolate, fix, verify |

### Meta
| Skill | What It Does |
|-------|-------------|
| **writing-skills** | TDD for documentation -- create new skills using the RED-GREEN-REFACTOR process |

## Graduated Quality Gates

| Level | Threshold | What Gets Checked |
|-------|-----------|-------------------|
| **0** | Any project | Build runs, no obvious errors (Builder-friendly) |
| **1** | Always | Tests pass, build clean, no hardcoded secrets |
| **2** | 10+ files | Coverage > 70%, no untracked TODOs, lint clean |
| **3** | 50+ files | Bundle budgets enforced, no circular imports, API contracts validated |
| **4** | 100+ files | Performance benchmarks, accessibility audit, security scan, dependency audit |

## Architecture Templates (8)

Pre-built architecture specs for common stacks. The plugin selects the right one automatically, or you can run `/scaffold` to choose.

| Template | Stack |
|----------|-------|
| `nextjs.md` | Next.js (App Router, Server Components, API Routes) |
| `express.md` | Express.js (REST API, middleware patterns) |
| `fastapi.md` | FastAPI (Python async API, Pydantic models) |
| `go-service.md` | Go (standard library HTTP, clean architecture) |
| `react-spa.md` | React SPA (client-side routing, state management) |
| `generic-typescript.md` | TypeScript (general-purpose, library or CLI) |
| `generic-python.md` | Python (general-purpose, scripts or packages) |
| `monorepo.md` | Monorepo (multi-package, shared dependencies) |

## Agents (4)

Specialized AI personas dispatched by skills for focused review:

| Agent | Role |
|-------|------|
| **code-reviewer** | Line-by-line review for correctness, style, and maintainability |
| **architecture-analyzer** | Validates structural decisions against the architecture spec |
| **security-auditor** | Scans for vulnerabilities, secrets, auth gaps, injection risks |
| **test-strategist** | Evaluates test coverage, suggests missing test cases, reviews test quality |

## Commands

| Command | What It Does |
|---------|-------------|
| `/scaffold` | Generate or regenerate the architecture specification for your project |
| `/audit` | Run a full quality audit across all dimensions (tests, security, architecture, performance) |
| `/health` | Quick project health dashboard -- see where you stand at a glance |

## Before and After

**Without Shipworthy:**
- Session 1: Build auth. Works great.
- Session 2: Build payments. Breaks auth. Claude forgot the auth middleware pattern.
- Session 3: Fix auth. Break payments. No tests to catch the regression.
- Ship: Security vulnerabilities, no tests, hardcoded secrets, inconsistent API responses.

**With Shipworthy:**
- Session 1: Build auth. Architecture spec generated. Tests written automatically. Auth patterns documented.
- Session 2: Build payments. Architecture rules prevent breaking auth. Security skill catches missing input validation.
- Session 3: Add features. Quality gates catch issues before you see them. Tech debt is tracked, not hidden.
- Ship: Tested, secure, documented, production-ready.

## Benchmark Results

We tested the plugin with an unbiased benchmark: same prompt, same starter project, scored by 15 automated checks. The only variable is whether the plugin is loaded.

**Task 01 — Build a REST API with CRUD (Express + TypeScript):**

| | With Plugin | Without Plugin |
|---|---|---|
| **Score** | **22/25 (A)** | **12/25 (C)** |
| Tests | 22 tests, all passing | 0 tests |
| Input validation | Zod schemas | Manual if/else |
| Error handling | 3 structured error types | 1 basic class |
| Architecture | 8 files, separated concerns | 5 files, simpler |

**+83% score improvement.** The plugin's TDD skill drove test creation, the security skill enforced Zod validation, and the API design skill produced proper status codes and error formatting.

Full methodology, all 10 task definitions, and reproducible benchmark scripts: [BENCHMARKS.md](BENCHMARKS.md)

```bash
# Run benchmarks yourself
cd benchmarks && ./run-benchmark.sh --task 1 --both
```

## Contributing

We welcome contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on writing new skills, adding templates, proposing agents, and submitting pull requests.

**Good first contributions:** add a new architecture template, improve a skill's edge case coverage, or add code examples to existing skills.

---

If this plugin helps you ship production-quality code, consider giving it a star.

## License

[MIT](LICENSE)
