# From Hackathon Win to Open Source: The Engineering Layer That Made Vibe Coding Actually Work

## The Win That Started a Different Conversation

I won first place at the Geotab Vibe Coding Competition 2026, sponsored by Google Cloud. FleetShield AI — a fleet telematics platform with safety risk prediction, autonomous driver coaching calls, and 9 real-time scoring engines. Built solo in under 5 days.

50+ API routes. Full voice AI pipeline. Production-grade backend. One person. Five days.

The judges highlighted something specific: "Went from insight to action to demonstrated ROI." They praised the data quality, the specific problem solving, and the architectural integrity.

But after the win, the conversations that followed surprised me. People weren't asking "how did you build the voice pipeline?" or "how does the scoring engine work?" They were asking for the repo. They wanted to see how a single person could build something that complex, that fast, at that quality level.

The repo exists, but it's a fleet telematics product. What people actually wanted wasn't my product. They wanted my process.

## What Actually Won the Hackathon

Let me be honest about something: the features didn't win it. Half the teams at that hackathon built impressive features. Some had more advanced ML models. Some had slicker UIs.

What separated FleetShield wasn't what it did. It was how solid it was underneath.

Every API route had input validation. Not because I manually added Pydantic schemas to each one — I had Claude Code doing that automatically through predefined guardrails. Every service had structured error handling. Not because I wrote try/catch blocks manually — I had architectural constraints that Claude followed on every function.

The database had real schemas with proper migrations. Not in-memory arrays that would vanish on restart. Structured logging from minute one. Tests that existed before the features they tested.

None of this was heroic engineering. It was systematic. I had a set of rules — a lightweight engineering playbook — that Claude Code followed automatically while I focused entirely on the product domain.

Research before code. Architecture before features. Conviction before polish.

That system is what let me build 50+ routes in 5 days without the whole thing collapsing under its own weight. And when judges looked at the codebase, they saw production software, not a prototype.

## The Gap I Kept Seeing

After the hackathon, I started paying attention to other people building with AI. Founders, indie hackers, developers at hackathons and weekend projects. The pattern was consistent:

The code works. The product doesn't hold up.

Data stored in memory. Inputs not validated. Secrets hardcoded in source files. No tests. No linting. `console.log` everywhere. `.env` files committed to public repos.

And the root cause is always the same: the builder didn't know to ask for these things. They're not engineers. They said "build me an expense tracker" and got exactly that — the features. Everything underneath was cut because nobody asked for it.

I ran a controlled test. Two Claude Code agents, same exact prompts, building the same expense tracker. Seven turns of non-technical founder prompts. One agent had my engineering guardrails injected. The other was vanilla.

Same model. Same prompts. Same product.

The scoring was automated — a bash script written before either agent ran, checking 25 objective metrics like "does a database exist?" and "do tests pass?" No subjective judgment.

### With guardrails: 35/36 checks passed (97%, Grade A)
SQLite database, Zod validation on every route, pino structured logging, ESLint passing, 39 tests, zero `console.log`, zero TypeScript `: any`.

### Without guardrails: 15/36 checks passed (41%, Grade F)
In-memory arrays (data vanishes on restart), no input validation, no linter, no `.gitignore`, 5 instances of `: any`, `console.log` in production code.

Not a single prompt mentioned tests, databases, validation, or logging. A non-technical founder wouldn't. The guardrails made the difference — invisibly.

## Building Shipworthy

That's when I decided to extract the engineering layer from my hackathon process and package it as an open source Claude Code plugin.

The name is Shipworthy. As in: is this code worthy of shipping to real users?

```bash
npx shipworthy init
```

One command. Zero configuration after that.

### What It Does (Invisibly)

**On session start** — a hook fires in under 2 seconds:
- Detects project type (Node.js, Python, Go)
- Determines project maturity (new project vs established codebase)
- Diagnoses gaps (no tests? no linter? .env not gitignored?)
- Loads architecture constraints and learnings from previous sessions
- Injects 52 engineering skills into Claude's routing

The user sees none of this.

**Before code gets written** — hooks check every file write:
- Hardcoded secrets (AWS keys, API tokens, passwords)
- `console.log` in production code
- Writing `.env` files without `.gitignore` protection

**Before bash commands run** — hooks catch destructive operations:
- `rm -rf` (recursive force delete)
- `git push --force` (rewrite remote history)
- `DROP TABLE` (destructive database operations)

**After code is written** — hooks verify quality:
- TypeScript `: any` types flagged
- Route handlers without input validation flagged
- Test files in wrong directories flagged

All advisory. Warns but never blocks.

### The 52 Skills

Organized across 12 categories:

| Category | Skills | What They Cover |
|----------|:---:|---|
| Core | 3 | Master routing, architecture awareness, intent-to-spec |
| Planning | 5 | Brainstorming, writing plans, executing plans, decisions, design docs |
| Quality | 5 | TDD, quality gates, verification, error handling, code complexity |
| Security | 5 | OWASP security, dependency management, compliance, threat modeling, PII detection |
| Architecture | 8 | API design, database design, performance, observability, resilience, API versioning, distributed systems, 12-factor |
| Collaboration | 4 | Sub-agent development, parallel agents, code review |
| Operations | 12 | Git worktrees, CI/CD, tech debt, incident response, migrations, feature flags, zero-downtime migrations, session memory, MCP integration |
| Frontend | 2 | Accessibility (WCAG 2.1 AA), frontend standards |
| Documentation | 1 | Documentation as code |
| Debugging | 1 | Systematic 4-phase debugging |
| Meta | 2 | Writing new skills, retrospective |
| Extensions | 2 | E-commerce (cart patterns, order lifecycle) |

Each skill is a Markdown file with YAML frontmatter. No code. No dependencies. Just instructions that make Claude smarter about engineering.

### Quality Gates That Scale

The plugin adjusts its strictness based on project maturity:

| Stage | Gate Level | What's Enforced |
|-------|:---:|---|
| Prototype (<5 files) | 0 | Build runs. No hardcoded secrets. That's it. |
| Early product (5+ files) | 1 | Tests pass. Lint clean. No `console.log`. Input validation present. |
| Growing product (10+ files) | 2 | Coverage >70%. No untracked TODOs. No `: any` types. |
| Scaling product (50+ files) | 3 | Bundle budgets. No circular imports. API contracts validated. |
| Enterprise (100+ files) | 4 | Performance benchmarks. Accessibility audit. Security scan. Dependency audit. |

No configuration. It tightens automatically as the project grows — the same way a real engineering team adds process as they scale.

### The Self-Improving Loop

This is the piece I'm most proud of. After completing work, you run `/retro`.

Sub-agents analyze the entire conversation:
- What corrections did you make? (Reveals unknown preferences)
- What was rebuilt mid-stream? (Reveals wrong assumptions)
- What steps were improvised? (Reveals skill gaps)
- What worked perfectly? (Confirms what's working)

Findings are presented as a table. You approve or reject each one. Approved learnings get saved to `.shipworthy/learnings/`.

```
Session 1:  Build feature → Corrections → /retro → Save learnings
Session 2:  Learnings loaded → Fewer corrections → /retro → Refine
Session 3:  Near-zero corrections → Polish learnings
Session N:  One-shot execution
```

This works alongside Claude Code's native auto-memory (captures individual corrections) and auto-dream (consolidates overnight). Three layers, each at a different scale:

- **Auto-memory**: "Use PostgreSQL not SQLite" (one correction)
- **/retro**: "This team always needs CORS, rate limiting, and explicit error messages" (session pattern)
- **Auto-dream**: Consolidates both overnight (long-term)

Static tools stay the same forever. This one compounds with every session.

### Enterprise Capabilities

For teams building at scale:

- **PII detection** — catches email, SSN, credit card, phone number patterns in code and test fixtures. GDPR/CCPA aware.
- **Container security** — Dockerfile best practices, official base images, no secrets in build layers, multi-stage builds.
- **API versioning** — breaking change detection, deprecation policies, backward compatibility rules.
- **Zero-downtime migrations** — expand-contract pattern, rollback plans, feature flags for schema changes.
- **Code complexity** — cyclomatic complexity limits, function length caps, nesting depth warnings.
- **Per-project configuration** — `.shipworthy/config.json` for overrides (allow `console.log` for CLI tools, ignore legacy directories, custom test locations).

### Context Window Efficiency

A common concern: does loading 52 skills bloat the context?

No. Only the master routing skill (~2,000 tokens) loads at session start. The other 51 load on demand — when Claude determines one is relevant. After the task, skill content scrolls out naturally.

| Scenario | Context Used | % of 200K | % of 1M |
|----------|:-:|:-:|:-:|
| Session start | ~2,000 tokens | 1.0% | 0.2% |
| Active work (3-4 skills) | ~3,500 tokens | 1.7% | 0.35% |
| Heavy work (8+ skills) | ~6,000 tokens | 3.0% | 0.6% |

The project footprint is ~15KB in `.shipworthy/`. Smaller than most README files.

### Architecture

Zero dependencies. Deliberately.

```
shipworthy/
├── skills/          52 Markdown files with engineering instructions
├── hooks/           5 bash scripts + shared library (lib.sh)
├── agents/          5 specialized agent personas
├── commands/        5 slash commands (/scaffold, /audit, /health, /diagnose, /retro)
├── templates/       8 architecture spec templates
├── extensions/      Industry-specific skill packs
├── presets/         Configuration bundles (startup, agency, enterprise)
├── adapters/        Rules for Cursor, Copilot, Codex, Windsurf, Gemini
└── tests/           190 automated tests (all passing)
```

Markdown and shell scripts. No build step. No transpilation. No runtime. Works on any machine with bash.

### Reliability Engineering

The plugin itself went through rigorous hardening:

- **Robust JSON parsing**: `jq` > `python3` > `awk` fallback chain (no more silent failures on escaped quotes)
- **Timeout protection**: All filesystem scans capped at 2 seconds (no hanging on monorepos)
- **False positive reduction**: Git SHAs, UUIDs, and test fixtures excluded from secret detection. Console.log skipped in CLI/scripts directories. `: any` detection uses word boundaries and skips comments.
- **Parallel session safety**: Marker files use parent process ID, not hook process ID
- **Per-project ignore paths**: Legacy, vendor, and generated code can be excluded from all checks
- **190 automated tests**: Skill frontmatter validation, routing table completeness (zero orphaned skills), hook behavior, false positive regression tests

## What's Not Perfect

I want to be transparent about the gaps.

**Limited language testing.** The benchmark ran on Node.js/TypeScript. Python and Go skills exist but haven't been rigorously benchmarked yet. Other languages (Rust, Java, Kotlin, Swift) have no specific skills.

**Skill routing is advisory.** The routing table tells Claude which skills to invoke, but it's LLM instruction-following, not hard enforcement. Adherence is probably 60-80%, not 100%.

**No Windows support.** The hooks are bash scripts. They work on macOS and Linux. Windows users need WSL.

**Single-project focus.** Monorepo support exists but hasn't been deeply tested. Multi-language projects get a generic tier, not per-module detection.

**The retrospective is new.** The self-improving loop is architecturally sound but hasn't been through months of real-world usage yet.

These are exactly the gaps where community contributions would make the biggest difference.

## The Ask

I'm not sharing this as a finished product. I'm sharing it as a starting point.

If you're an engineer who's seen AI-generated code break in production — you know why this matters. If you're an architect who's reviewed vibe-coded PRs — you know what's missing. If you're an AI engineer building with Claude Code daily — you know where the gaps are.

What I'm looking for:

- **Engineers** who work in languages I don't — add skills for Rust, Java, Kotlin, Go patterns you know are critical
- **Architects** who can stress-test the architecture decisions — are the quality gates at the right levels? Are the right things being checked?
- **AI engineers** who push Claude Code's capabilities — better hook patterns, smarter skill routing, creative uses of sub-agents
- **Non-technical builders** who can tell us where the plugin gets in the way or misses the point — the user experience matters as much as the engineering

If even one person contributes one skill that prevents one production bug — that's a win.

I'm working on better collaboration infrastructure — contribution guides, issue templates, community discussions, a roadmap. But I didn't want to wait for perfect infrastructure to share imperfect but useful work.

**The repo: [github.com/Vimalk0703/shipworthy](https://github.com/Vimalk0703/shipworthy)**

52 skills. 5 hooks. 5 agents. 190 tests. Zero dependencies.

Research before code. Architecture before features. Community before scale.

Let's build this together.
