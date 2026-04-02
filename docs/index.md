---
title: Shipworthy — Is Your Code Worthy of Shipping?
---

# Shipworthy

**Production engineering guardrails for AI coding agents.**

AI-generated code creates 1.7x more bugs, 40% contains security vulnerabilities, and 2026 is "the year of technical debt from vibe coding." Shipworthy fixes this without slowing you down.

## What It Does

Shipworthy auto-activates every AI coding session and enforces 55 engineering skills — TDD, security, architecture awareness, quality gates, and more — with full transparency. It detects your tech stack, generates an architecture spec, and maintains it across sessions. You code at full speed; the guardrails handle the rest, and you can see exactly what's contributing.

## Quick Start

```bash
npx shipworthy init
```

That's it. Your next session has engineering guardrails.

## Benchmarked

We tested with identical prompts, same starter project, 15 automated checks:

| | With Shipworthy | Without |
|---|---|---|
| REST API task | **22/25 (A)** | 12/25 (C) |
| SaaS app (founder prompt) | **19/25 (A)** | 15/25 (B) |

[Full benchmark methodology and results →](reference/benchmarks.md)

## Documentation

- [Installation](getting-started/installation.md) — all setup methods
- [Quick Start](getting-started/quickstart.md) — 5-minute walkthrough
- [How It Works](getting-started/how-it-works.md) — architecture and design
- [For Founders](guides/for-founders.md) — build production-grade products
- [For Engineers](guides/for-engineers.md) — full skill catalog and customization
- [For Teams](guides/for-teams.md) — shared architecture, code review, onboarding
- [Skills Reference](reference/skills.md) — all 55 skills
- [Supported Agents](reference/agents.md) — Claude, Cursor, Copilot, Codex, Windsurf, Gemini
- [Contributing](contributing/overview.md) — write skills, create extensions
