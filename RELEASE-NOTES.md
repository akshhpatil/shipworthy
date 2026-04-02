# Shipworthy Release Notes

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
