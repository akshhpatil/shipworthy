# CLAUDE.md — Shipworthy

## What This Is

Shipworthy is an open-source Claude Code plugin that enforces production engineering practices across AI coding sessions. v1.2.0 with 55 skills, 6 hooks, 6 agents, 8 templates, 5 adapters, 3 presets, 6 commands.

## Repository Structure

```
skills/              55 engineering skills as SKILL.md files (YAML frontmatter + Markdown)
  core/              Master router, architecture awareness, intent-to-spec
  planning/          Brainstorming, writing-plans, executing-plans, design-documents, decision-frameworks
  quality/           TDD, quality-gates, verification, error-handling, code-complexity
  security/          11 skills: adaptive-security, secrets, supply-chain, PII, compliance, etc.
  architecture/      API design, database, performance, observability, resilience, 12-factor
  collaboration/     Subagent-driven-dev, parallel agents, code review
  operations/        12 skills: CI/CD, git worktrees, migrations, feature flags, incident response
  frontend/          Accessibility, frontend standards
  debugging/         Systematic debugging
  documentation/     Documentation as code
  meta/              Writing skills, retrospective
hooks/               6 bash hook scripts + shared library
  lib.sh             Shared utilities: JSON parsing, escaping, debug logging, transparency functions
  session-start      SessionStart hook — tier detection, arch spec loading, transparency banner
  pre-tool-use       PreToolUse (Write|Edit) — secrets, eval, console.log detection
  pre-tool-use-bash  PreToolUse (Bash) — destructive command detection
  pre-push-validate  PreToolUse (Bash) — blocks git push if validation fails (90s timeout)
  post-tool-use      PostToolUse (Bash) — commit, dependency, migration monitoring
  post-tool-use-write PostToolUse (Write|Edit) — :any, test location, route validation
commands/            6 slash commands (Markdown): /audit, /diagnose, /health, /retro, /scaffold, /validate
agents/              6 agent personas (Markdown): code-reviewer, architecture-analyzer, security-auditor, test-strategist, project-doctor, pre-push-validator
templates/           8 architecture templates: nextjs, express, fastapi, go-service, react-spa, generic-typescript, generic-python, monorepo
adapters/            5 multi-agent adapters: cursor, copilot, codex, windsurf, gemini
presets/             3 config presets: startup.json, agency.json, enterprise.json
extensions/          Domain-specific extensions: e-commerce, fintech, healthcare
bin/shipworthy.cjs   CLI entry point (npx shipworthy init)
tests/               Test suites (11 suites, all passing)
  hooks/             Hook tests: test-session-start, test-pre-tool-use, test-post-tool-use, test-transparency
  skills/            Skill tests: test-skill-frontmatter, test-cso-format, test-cross-references, test-skill-routing, test-skill-quality, test-transparency-instructions
  run-all-tests.sh   Master test runner (auto-discovers test-*.sh files)
  validate-all.sh    Pre-push validation (7 checks, called by pre-push-validate hook)
site/                Landing page (GitHub Pages): index.html, og-image.html
docs/                Documentation site: getting-started/, guides/, reference/, blog/
benchmarks/          Reproducible benchmark suite with scoring scripts
```

## Key Conventions

### Skills
- Every skill is a `SKILL.md` with YAML frontmatter: `name`, `description`, `invoke_when`
- `name` must match the directory name (kebab-case)
- `description` and `invoke_when` must start with "Use when..." (CSO standard)
- Total frontmatter under 1024 characters
- Skills reference each other via `shipworthy:skill-name` syntax

### Hooks
- All hooks are bash scripts sourcing `hooks/lib.sh`
- Hooks communicate with Claude Code via JSON on stdout: `{"hookSpecificOutput":{...}}`
- Transparency logging goes to stderr (ANSI colors, `sw_log`/`sw_check`/`sw_banner` functions)
- Hooks must output valid JSON even on error (ERR trap)
- Timeouts: session-start 5s, pre/post-tool-use 3s, pre-push-validate 90s
- Advisory only (warn but don't block) except pre-push-validate which can block

### Transparency System
- Shell track: `sw_log <level> <source> <message>` writes to stderr with ANSI colors
- Instruction track: Transparency Protocol in `using-shipworthy/SKILL.md` — Claude announces skills, routing, defaults, guards
- Toggle: `SHIPWORTHY_TRANSPARENCY=0` env var or `"transparency": false` in config
- Brand prefix: `⚓ shipworthy ›` in bold cyan
- Levels: info (cyan), security (green), warn (yellow), block (red)

### Tests
- Test files follow `test-*.sh` pattern, auto-discovered by `run-all-tests.sh`
- Test helpers: `pass()`, `fail()`, `setup_temp_project()`, `cleanup()`, `validate_json()`
- Hook tests suppress stderr with `2>/dev/null` (transparency-safe)
- All tests must pass before push (enforced by pre-push-validate hook)

## Running Tests

```bash
bash tests/run-all-tests.sh           # all 11 suites
bash tests/hooks/test-transparency.sh  # transparency shell tests only
bash tests/skills/test-transparency-instructions.sh  # instruction track tests
bash tests/validate-all.sh             # pre-push validation (7 checks)
```

## Common Workflows

### Adding a New Skill
1. Create `skills/<category>/<skill-name>/SKILL.md` with CSO-compliant frontmatter
2. Add cross-references to related skills via `shipworthy:skill-name`
3. Add transparency instruction header (follows Transparency Protocol)
4. Add routing entry in `skills/core/using-shipworthy/SKILL.md` skill selection table
5. Run `bash tests/run-all-tests.sh` — CSO format and frontmatter tests will validate

### Modifying a Hook
1. Edit the hook script in `hooks/`
2. Use `sw_log`/`sw_check` for transparency (they no-op if disabled)
3. Ensure JSON output on stdout is not affected
4. Run `bash tests/hooks/test-<hookname>.sh` and `test-transparency.sh`

### Adding a Command/Agent
1. Create Markdown file in `commands/` or `agents/`
2. Add transparency header (see existing files for format)
3. Run `bash tests/skills/test-transparency-instructions.sh`

## Don't

- Don't use `console.log` in any example code — use structured logging (pino, logging, slog)
- Don't use `: any` in TypeScript examples — use `unknown` with type guards
- Don't add dependencies — this is a zero-dependency project (bash + Markdown)
- Don't break JSON output from hooks — always test with `validate_json()`
- Don't write hooks that block (except pre-push-validate) — advisory only
- Don't use relative dates in docs/learnings — always YYYY-MM-DD
- Don't skip transparency announcements in skill/command/agent files

## Version

v1.2.0 — Full Transparency (April 2, 2026)
