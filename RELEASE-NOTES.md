# Shipworthy Release Notes

## v1.4.0 — LLM Guardrails

**Released:** April 5, 2026

Most teams building with AI focus on features. Few think about guardrails — and that's where things break. This release adds 7 new skills that implement a complete, layered guardrail system based on the 5-layer LLM guardrails framework: Input/Output, Contextual, Security, Adaptive, and Ethical/Compliance. When you install Shipworthy, all 5 layers activate automatically.

### The Problem

Shipworthy already had strong security guardrails (11 skills, 3 hooks). But guardrails are not a single layer — they need to be distributed across the system. We had gaps in response validation, bias detection, adaptive enforcement, vendor risk, scope control, and centralized audit logging.

### 7 New Guardrail Skills

#### Input & Output Layer
- **response-schema-validation** — Enforces that every API response passes through a declared schema before reaching the client. Prevents accidental data leakage (password hashes, internal notes, admin flags). Includes a sensitive field blocklist and test patterns for Zod, Pydantic, and Go.

#### Contextual Layer
- **scope-creep-detection** — Detects when a task expands beyond its original boundaries: file count expansion, time-based growth, new requirements mid-task, "while I'm here" syndrome, and dependency chain yak-shaving. Stops, surfaces the expansion, and gets explicit user approval before proceeding.

#### Adaptive Layer
- **feedback-driven-adaptation** — Moves guardrails from static rules to dynamic control systems. Adapts enforcement based on three signal types: user signals (explicit feedback), project trajectory (file count, test coverage trends, deployment status), and violation patterns (recurring issues, spike detection). Includes tier graduation/downgrade protocols with explicit user communication.

- **confidence-based-strictness** — Scales verification depth based on how uncertain the system is about generated code. Four levels: High Confidence (routine CRUD), Moderate (multiple valid approaches), Low (crypto, financial, concurrency), Minimal (rolling your own security primitives — hard block). Auto-detects trigger patterns like `crypto`, `price`, `mutex`, `migration`.

#### Ethical & Compliance Layer
- **bias-detection** — Flags discriminatory logic in code that makes decisions about people: pricing, scoring, ranking, filtering, access control. Detects protected attribute usage, proxy variables (zip code = redlining), threshold bias, and training data assumptions. Includes disparate impact testing patterns and EU AI Act / ECOA / GDPR Art. 22 regulatory context.

- **vendor-risk-assessment** — Evaluates third-party services before adoption using a 3-tier framework: Critical (data processors — SOC 2, DPA required), Operational (infrastructure — SLA, fallback required), Development (tooling — access controls). Includes circuit breaker patterns, data minimization rules, webhook signature verification, and vendor failure planning.

#### Cross-Cutting (All Layers)
- **guardrail-audit-log** — Centralized, immutable audit trail for every guardrail event across all 5 layers. Standardized event schema with layer classification, severity levels, and resolution tracking. Enables compliance evidence export, violation trend analysis, and governance reporting. Integrates with all existing Shipworthy hooks.

### Coverage After This Release

| Guardrail Layer | v1.3.0 | v1.4.0 |
|----------------|--------|--------|
| Input & Output | Strong | **Complete** |
| Contextual | Strong | **Complete** |
| Security | Comprehensive | Comprehensive |
| Adaptive | Moderate | **Strong** |
| Ethical & Compliance | Strong | **Complete** |
| Cross-Cutting Audit | Missing | **Complete** |

### What's New

- 7 new skills (57 → 64 total)
- All 5 LLM guardrail layers now covered automatically
- Router updated with 7 new routing entries
- 14 security skills (was 11)
- 15 operations skills (was 13)
- 8 quality skills (was 5)
- 12 test suites, all passing
- 7/7 pre-push validation checks passing

### Upgrading

```bash
npx shipworthy init
```

---

## v1.3.0 — Context Intelligence

**Released:** April 4, 2026

The biggest pain point in AI-assisted development: Claude forgets everything between sessions. You repeat the same corrections, explain the same patterns, and watch the same mistakes happen again. This release fixes that with an automated context intelligence system that captures, organizes, and loads project knowledge across sessions — with 95% automation.

### The Problem

Every session felt like explaining the project from scratch. Claude would write code that contradicted what it had written 2 weeks ago. Same mistakes, repeated. The constraint isn't model capability — it's context quality.

### The Solution: Automatic Context Flywheel

```
DURING SESSION (automatic, zero intervention):
  hooks detect patterns → capture to .shipworthy/.session-signals

NEXT SESSION START (automatic):
  1. loads regression fence (hard constraints)
  2. loads learnings (patterns)
  3. auto-processes signals → proposes fence + learnings
  4. user approves with one "yes" → work begins
```

### Regression Fence

A new first-class concept: `.shipworthy/regression-fence.md` is loaded every session as hard constraints. Rules use prohibitive format that survives context decay:

```markdown
## NEVER use SQLite in this project — PostgreSQL only
Concurrent write failures in the API layer. (2026-03-15)

## NEVER add route handlers outside src/routes/
Route in src/utils/helper.ts broke middleware chain. (2026-03-20)
```

Auto-populated from session signals and `/retro`. Max 20 entries. Anchored to file paths. Fence violations are detected in real-time during writes.

### Signal Capture

Every hook now automatically captures events to `.shipworthy/.session-signals`:

```
⚓ shipworthy  14:32:05  signal  ›  captured: security — secret-detected: AWS key in config.ts
⚓ shipworthy  14:32:06  signal  ›  captured: pattern — console.log in routes.ts
⚓ shipworthy  14:33:01  signal  ›  captured: git — commit: fix auth bug
⚓ shipworthy  14:33:15  signal  ›  captured: dependency — added: lodash
```

12 capture points across security, pattern, git, dependency, and migration categories. Sub-millisecond overhead.

### The 7 Principles

The new `context-manager` skill teaches the principles that make context engineering work:

1. **Prohibitions beat descriptions** — "No Prisma, no Drizzle — Supabase only" survives context decay
2. **Anchor rules to file paths** — "All validation in src/schemas/" is verifiable
3. **Negative examples anchor harder** — document past mistakes, not just aspirations
4. **Constitution vs working memory** — CLAUDE.md (stable) + session-state (dynamic)
5. **Only write what Claude can't infer** — ruthlessly prune inferrable rules
6. **Ordering is load-bearing** — hardest constraints at top, conventions at bottom
7. **Zero global bleed** — no tone/philosophy in project scope

### `/context` Command

New health dashboard showing context completeness:

```
Context Health Dashboard
========================
CLAUDE.md              82 lines ✓
.shipworthy/           6/8 standard files ✓
Regression fence       5 rules ✓
Session signals        0 unprocessed ✓
Context budget         ~5,200/8,000 chars (65%) ✓
```

### What's New

- `sw_signal()` function in shared hook library — session event capture
- 12 signal capture points across 3 hooks (pre-tool-use, post-tool-use, post-tool-use-write)
- Regression fence loading in session-start hook (budget-aware)
- Fence violation detection in post-tool-use-write hook
- Auto-retro at session start (processes signals without manual `/retro`)
- `context-manager` skill with 7 principles and context triage
- `/context` command for context health dashboard
- Enhanced retrospective skill (signal reading, fence proposals, signal cleanup)
- 23 new tests (12 test suites, all passing)

### Upgrading

```bash
npx shipworthy init
```

---

## v1.2.0 — Full Transparency

**Released:** April 2, 2026

The #1 user request: "What is Shipworthy actually doing?" This release answers that with a complete transparency system across every component. Every hook, skill, command, agent, template, and adapter now announces its activity — so you always know what's contributing to your code.

### See Everything Shipworthy Does

Every session now opens with a branded status banner:

```
┌─ ⚓ shipworthy ─────────────────────────────┐
│  Tier: ENGINEER  │  Health: all passed       │
│  Skills: 55      │  Hooks: 6 active          │
└──────────────────────────────────────────────┘
```

As hooks fire, you see real-time color-coded logs in your terminal:

```
⚓ shipworthy  14:33:12  pre-tool-use  ›  Scanning: service.ts
⚓ shipworthy  14:33:12  pre-tool-use  ›  All checks passed ✓
```

Warnings appear in yellow, blocks in red:

```
⚓ shipworthy  14:34:01  pre-tool-use  ›  ! Secrets scan: WARN
⚓ shipworthy  14:40:08  pre-push-validate  ›  ✗ Validation FAILED — push blocked
```

### Skills Announce Themselves

When Claude activates a Shipworthy skill, it announces it before applying:

> ⚓ **shipworthy** › skill: `api-design-standards` + `security-first-development` — designing secure endpoint

> ⚓ **shipworthy** › routing: task classified as **Feature** — using spec → brainstorm → plan → execute flow

> ⚓ **shipworthy** › defaults: installing `pino` (structured logging replaces console.log)

This covers all 55 skills, routing decisions, conflict resolution, default enforcement, architecture enforcement, and tier-adapted behavior.

### Every Component Is Transparent

It's not just hooks and skills. Commands announce before executing (`> ⚓ shipworthy › command: /audit`), agents announce on dispatch (`> ⚓ shipworthy › agent: security-auditor dispatched`), templates announce when scaffolding, and adapters announce when translating for other platforms.

### Two-Track Architecture

The transparency system uses two complementary mechanisms:

| Track | Components | How |
|-------|-----------|-----|
| **Shell track** | 6 hooks | Color-coded ANSI output on stderr (doesn't interfere with JSON protocol) |
| **Instruction track** | 55 skills, 6 commands, 6 agents, 8 templates, 5 adapters | Transparency Protocol directives in markdown |

### Toggle It Off

If you prefer silent operation:

```bash
export SHIPWORTHY_TRANSPARENCY=0
```

Or in `.shipworthy/config.json`:

```json
{
  "transparency": false
}
```

### What's New

- 4 new transparency functions in the shared hook library (`sw_log`, `sw_check`, `sw_banner`, `sw_transparency_enabled`)
- All 6 hooks instrumented with transparency calls
- Transparency Protocol section in the master routing skill (covers all 55 skills)
- Transparency headers on all 6 commands, 6 agents, 8 templates, and 5 adapters
- 15 new tests (10 shell track + 5 instruction track)
- All 11 test suites passing

### Upgrading

```bash
npx shipworthy init
```

---

## v1.1.0 — Community Edition

**Released:** March 31, 2026

This release transforms Shipworthy from a solo project into a community-ready open source tool. It adds adaptive security that works with any type of software, hardens the contribution process, and makes every skill more resistant to AI shortcuts.

### Adaptive Security for Any Software

Shipworthy now automatically detects what kind of application you're building and applies the right security profile. Whether you're building a Next.js web app, a FastAPI backend, a CLI tool, a data pipeline, or an IoT edge service — Shipworthy knows what security measures matter for your stack.

**11 security profiles:** Web App, REST API, GraphQL, Mobile Backend, CLI Tool, Data Pipeline, IoT/Edge, Desktop App, Infrastructure as Code, Container, and Cross-Cutting (applied to everything).

Two new specialized skills round out the security story:
- **Supply Chain Security** — protects your dependency tree from typosquatting, unpinned versions, and build pipeline attacks
- **Secrets Management** — comprehensive lifecycle for API keys, tokens, certificates, and credentials

### Skills That Can't Be Skipped

Every core skill now includes a **rationalization pressure-testing table** — a list of excuses an AI might generate to skip the skill, with specific counters for each. This is based on research into how AI agents rationalize cutting corners.

The brainstorming and planning skills now include **HARD-GATE directives** — the AI literally cannot proceed to implementation until you approve the design. No more "I went ahead and built it" surprises.

### Community-Ready Infrastructure

- **CONTRIBUTING.md** rewritten with an "If You Are an AI Agent" section that sets clear expectations for AI-generated contributions
- **PR template** now requires before/after evidence and adversarial testing
- **GitHub Sponsors** enabled — support Shipworthy's development
- **Discord** community for questions and support

### Claude Search Optimization (CSO)

All 55 skills now use standardized "Use when..." trigger descriptions, making it significantly more reliable for AI agents to find and invoke the right skill at the right time.

### Upgrading

```bash
npx shipworthy init
```

---

*Full changelog: [CHANGELOG.md](CHANGELOG.md)*
