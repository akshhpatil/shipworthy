# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-04-02

### Added
- **Full Transparency System** — two-track observability across every Shipworthy component
  - **Shell track**: Color-coded ANSI stderr logging from all 6 hooks (session-start banner, security scan results, compliance checks, push validation)
  - **Instruction track**: Transparency Protocol in master routing skill — Claude announces every skill activation, default enforcement, routing decision, conflict resolution, and architecture enforcement
  - Transparency headers on all 6 commands, 6 agents, 8 templates, and 5 adapters
  - Branded `⚓ shipworthy ›` prefix with cyan/green/yellow/red color scheme per severity level
  - Toggleable via `SHIPWORTHY_TRANSPARENCY=0` env var or `"transparency": false` in config
  - 10 new hook transparency tests + 5 instruction track tests (all passing)

## [1.1.0] - 2026-03-31

### Added
- **Adaptive Security Framework** — new `adaptive-security` skill that auto-detects application type (web app, API, GraphQL, mobile backend, CLI, data pipeline, IoT, desktop, IaC, containers) and applies the appropriate security profile
- **Supply Chain Security** skill — dependency pinning, lock file integrity, typosquatting awareness, SBOM generation, license compliance
- **Secrets Management** skill — comprehensive secrets lifecycle management, rotation strategies, vault integration guidance
- **Rationalization pressure-testing tables** on 5 core skills (brainstorming, TDD, quality-gates, writing-plans, executing-plans) — prevents AI from generating excuses to skip critical steps
- **HARD-GATE directives** on brainstorming and writing-plans — AI cannot proceed to implementation without explicit human approval
- **CSO (Claude Search Optimization)** — all 52+ skills standardized to "Use when..." invoke_when format for reliable AI triggering
- **Cross-referencing system** — skills reference each other via `shipworthy:skill-name` syntax
- **GitHub Sponsors** support via FUNDING.yml

### Changed
- **CONTRIBUTING.md** — comprehensive rewrite with "If You Are an AI Agent" section, human partner language, expanded PR guidelines
- **PR template** — now requires before/after evidence, adversarial testing confirmation, environment table, duplicate check, human involvement checkbox
- **writing-skills meta-skill** — expanded to ~3000 words with CSO, adversarial testing, skill anti-patterns, and lifecycle guidance
- **Issue templates** — blank issues disabled, questions redirected to Discord and Discussions

### Security
- 11 application-type-specific security profiles (web, API, GraphQL, mobile, CLI, pipeline, IoT, desktop, IaC, container, cross-cutting)
- Adaptive security detection based on project signals (frameworks, dependencies, file patterns)
- Supply chain attack prevention checklist
- Secrets lifecycle management with rotation and vault guidance

## [1.0.0] - 2026-03-26

### Added

- 42 engineering skills across 12 categories (core, planning, quality, security, architecture, collaboration, operations, frontend, documentation, debugging, meta)
- 3 auto-activating hooks (session-start, pre-tool-use, post-tool-use)
- 4 specialized agents (code-reviewer, architecture-analyzer, security-auditor, test-strategist)
- 8 architecture templates (Next.js, Express, FastAPI, Go, React SPA, TypeScript, Python, Monorepo)
- 3 slash commands (/scaffold, /audit, /health)
- User experience tiers (Builder/Maker/Engineer) with auto-detection based on project maturity
- Task size awareness (Quick Fix/Feature/Project) with workflow routing
- Graduated quality gates (Level 0-4) scaling with project complexity
- Architecture scaffold system that auto-detects tech stack and generates enforceable specs
- CLAUDE.md coexistence — respects existing project conventions
- Polyglot project support — composite specs for multi-language repos
- Context budget management — summarizes large specs to fit session context
- 26 hook unit tests (11 session-start, 7 pre-tool-use, 8 post-tool-use)
- 10-task unbiased benchmark suite with automated scoring (15 checks per task)
- Blind A/B comparison framework for bias-free evaluation
- Starter projects for benchmarking (Express+TS, security bug, N+1 query)
- First benchmark result: +83% score improvement on REST API CRUD task (22/25 vs 12/25)

[Unreleased]: https://github.com/Vimalk0703/shipworthy/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/Vimalk0703/shipworthy/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Vimalk0703/shipworthy/releases/tag/v1.0.0
