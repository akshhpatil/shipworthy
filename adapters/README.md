# Multi-Agent Support

Shipworthy works with any AI coding agent, not just Claude Code.

## Supported Agents

| Agent | Setup | Auto-Hooks | Skills Context | Quality Gates |
|-------|-------|------------|---------------|---------------|
| **Claude Code** | `/plugin install shipworthy` | Full (session-start, pre/post-tool-use) | Full (42 skills) | Automated |
| **Cursor** | Copy `.cursorrules` to project root | Rules only | Condensed | Manual |
| **GitHub Copilot** | Copy `copilot-instructions.md` to `.github/` | Rules only | Condensed | Manual |
| **OpenAI Codex** | Copy `AGENTS.md` to project root | Rules only | Condensed | Manual |
| **Windsurf** | Copy `.windsurfrules` to project root | Rules only | Condensed | Manual |
| **Gemini CLI** | Copy `GEMINI.md` to project root | Rules only | Condensed | Manual |

## Setup

### Cursor
```bash
cp adapters/cursor/.cursorrules /path/to/your/project/.cursorrules
```

### GitHub Copilot
```bash
mkdir -p /path/to/your/project/.github
cp adapters/copilot/.github/copilot-instructions.md /path/to/your/project/.github/
```

### OpenAI Codex
```bash
cp adapters/codex/AGENTS.md /path/to/your/project/AGENTS.md
```

### Windsurf
```bash
cp adapters/windsurf/.windsurfrules /path/to/your/project/.windsurfrules
```

### Gemini CLI
```bash
cp adapters/gemini/GEMINI.md /path/to/your/project/GEMINI.md
```

## Or use the CLI

```bash
npx shipworthy init --agent cursor
npx shipworthy init --agent copilot
npx shipworthy init --agent codex
```

## What Works Where

- **Claude Code** gets the full experience: auto-activating hooks that detect secrets, monitor commits, and inject skills into every session.
- **All other agents** get the condensed rules file — the non-negotiable defaults, skill routing, quality gates, and architecture memory. This covers ~80% of the value.
- **Skills directory** can be referenced by any agent that supports reading project files. Point the agent to `skills/` for the full 42-skill catalog.
