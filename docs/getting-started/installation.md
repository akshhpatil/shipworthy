# Installation

## Prerequisites

- An AI coding agent (Claude Code, Cursor, Copilot, Codex, Windsurf, or Gemini)
- Node.js 18+ (for the CLI tool and scoring)

## Method 1: Claude Code Plugin (Recommended)

```bash
/plugin install shipworthy
```

This gives you the full experience: auto-activating hooks, skill injection, and quality gates on every session.

## Method 2: CLI (Any Agent)

```bash
npx shipworthy init
```

Or specify your agent:

```bash
npx shipworthy init --agent cursor
npx shipworthy init --agent copilot
npx shipworthy init --agent codex
npx shipworthy init --agent windsurf
npx shipworthy init --agent gemini
```

This copies the appropriate rules file into your project and creates `.shipworthy/`.

## Method 3: Manual

Copy the rules file for your agent directly:

| Agent | File | Destination |
|-------|------|-------------|
| Cursor | `adapters/cursor/.cursorrules` | `.cursorrules` |
| Copilot | `adapters/copilot/.github/copilot-instructions.md` | `.github/copilot-instructions.md` |
| Codex | `adapters/codex/AGENTS.md` | `AGENTS.md` |
| Windsurf | `adapters/windsurf/.windsurfrules` | `.windsurfrules` |
| Gemini | `adapters/gemini/GEMINI.md` | `GEMINI.md` |

## Verify Installation

```bash
npx shipworthy doctor
```

This checks that everything is set up correctly.

## Scoring Your Project

```bash
npx shipworthy score
```

Runs 15 automated quality checks and shows your grade (A through F).
