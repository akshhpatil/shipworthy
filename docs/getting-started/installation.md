# Installation

## Prerequisites

- An AI coding agent (Claude Code, Cursor, Copilot, Codex, Windsurf, or Gemini)
- Node.js 18+ (for the CLI tool and scoring)

## Method 1: CLI (Recommended)

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

The CLI auto-detects your AI agent and tech stack:

- **Claude Code**: Configures hooks in `.claude/settings.json` (session-start, pre/post-tool-use) for the full experience — auto-activating skills, guardrails, and quality gates.
- **Other agents**: Copies the appropriate rules file (`.cursorrules`, `AGENTS.md`, etc.) into your project.
- **All agents**: Creates `.shipworthy/` with project config and prepares architecture detection.

## Method 2: Manual

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
