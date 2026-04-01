# Shipworthy Release Notes

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

All 52+ skills now use standardized "Use when..." trigger descriptions, making it significantly more reliable for AI agents to find and invoke the right skill at the right time.

### Upgrading

```bash
# Pull the latest version
npx shipworthy init

# Or update manually
cd your-project
git -C .shipworthy/plugin pull
```

---

*Full changelog: [CHANGELOG.md](CHANGELOG.md)*
