# From Vibe Coding to Production: How I Built a Self-Improving Engineering Layer for AI-Assisted Development

## The Weekend That Changed How I Think About AI Code

I built an entire SaaS backend in a weekend. Customers, invoices, payment tracking, PDF exports, recurring billing — all of it. Just me and Claude Code.

It felt like a superpower. I'd describe what I wanted in plain English, and working code appeared. No Stack Overflow. No documentation rabbit holes. Just "build me X" and it was done.

Then on Monday, I showed it to a friend who's a senior engineer.

He opened the source code and went quiet for about ten seconds. Then: "Where's your database?" I pointed at the code. "That's an in-memory array," he said. "Restart the server and every invoice disappears."

He kept scrolling. No input validation — anyone could send malformed data and crash the API. No tests. `console.log` scattered everywhere instead of structured logging. An API key hardcoded in a config file. The `.env` file wasn't even in `.gitignore`.

The app worked. It just wasn't software.

## The Problem Isn't the AI

Here's what I've come to understand: Claude is genuinely exceptional at building what you ask for. The problem is that production software needs dozens of things you don't think to ask for — because you're not an engineer, or because you're moving fast, or because you've never been burned by a missing database migration at 2am.

When a non-technical founder says "build me an expense tracker," they mean the features. They don't mean "also set up SQLite with proper schema, add Zod validation on every endpoint, configure Vitest with coverage, install ESLint with strict rules, use pino instead of console.log, put .env in .gitignore, and write tests before writing code."

But all of those things are the difference between a demo and a product.

## The Gap I Wanted to Close

I started looking at what existed. There are incredible open source projects doing spec-driven development — structured workflows where you define what to build before writing code. They're brilliant for teams that want process.

But I wasn't looking for process. I was looking for something invisible. Something that would let me keep vibe coding at full speed while silently ensuring the output was production-grade.

No commands to learn. No workflow to follow. No configuration files to maintain. Just install it and forget it exists.

## What I Built

Shipworthy is an open source engineering layer for AI coding agents. You install it with one command:

```bash
npx shipworthy init
```

From that moment, every Claude Code session has invisible engineering guardrails.

### How It Actually Works

When you start a Claude Code session, a session-start hook fires in under 2 seconds. It detects your project type (Node.js, Python, Go), determines your project's maturity level, diagnoses what's missing (no tests? no linter? no .gitignore?), and injects a master routing skill that orchestrates 55 engineering skills.

You see none of this. You just start talking.

When you say "build me an invoice app," a chain of skills fires invisibly:

1. **Intent-to-Spec** generates a lightweight specification — what you want, what will be built, acceptance criteria. For non-technical users, this is completely silent. You never see it. But Claude now has a contract to build against instead of interpreting your vague description on the fly.

2. **Architecture Awareness** detects your tech stack and generates an architecture specification with mandatory rules. This persists across sessions — Claude remembers your project structure tomorrow.

3. **Test-Driven Development** writes a failing test before writing implementation code. For non-technical users, this is invisible too. You just see "Built the payment flow and verified it works correctly." You don't see the 12 tests that prove it.

4. **Verification** runs proof commands at the end — tests, linter, build. Claude doesn't say "this should work." It runs `npm test` and shows you the output.

Along the way, hooks are guarding every action:

- **Before a file is written**: checks for hardcoded secrets, API keys, `console.log` in production code
- **Before a bash command runs**: catches `rm -rf`, `git push --force`, `DROP TABLE` before they execute
- **After a file is written**: flags TypeScript `: any` types, route handlers without input validation

All of this is advisory. The hooks warn but never block. You're still in control.

### The Non-Negotiable Defaults

These apply to every project automatically:

- Use a structured logger (pino, Python logging, Go slog) — never `console.log`
- Use input validation (Zod, Pydantic, Go validator) on every route handler
- Use a real database (SQLite minimum) — never in-memory arrays
- Configure test coverage and a linter from the start
- Use proper HTTP status codes (201 for creation, 400 for validation errors, not 200 for everything)
- Never use TypeScript `: any` — use `unknown` with type guards

A non-technical founder doesn't know to ask for any of these. The plugin does them automatically.

### Quality Gates That Scale

The plugin adjusts its strictness based on how mature your project is:

- **Less than 5 files**: Light touch. Build runs, no hardcoded secrets. Don't overwhelm a new project with process.
- **5+ files**: Tests must pass. Linter must be clean. No `console.log`.
- **10+ files**: Code coverage above 70%. No `TODO` comments without tickets. No `: any` types.
- **50+ files**: Bundle size budgets. No circular imports. API contracts validated.
- **100+ files**: Performance benchmarks. Accessibility audit. Security scan.

You never configure this. It just tightens as the project grows — the same way a real engineering team adds process as they scale.

### The Self-Improving Loop

This is the part I'm most excited about.

After you finish building something, you run `/retro`. Sub-agents analyze the entire conversation and extract signals:

- What corrections did you make? ("No, use PostgreSQL not SQLite")
- What was redone or rebuilt? (Started with REST, switched to GraphQL)
- What steps were improvised that no skill covered? (Had to add CORS manually)
- What worked perfectly on first try? (TDD flow for API endpoints)

The findings are presented as a table. You approve or reject each one. Approved learnings are saved to your project's `.shipworthy/learnings/` directory.

Next session, those learnings are loaded automatically. Claude knows your preferences before you state them. Session after that, even fewer corrections. Eventually: one-shot execution.

Static tools stay the same forever. This one compounds.

### Integration With Claude Code's Memory

Claude Code recently shipped auto-memory and auto-dream — native features where Claude learns from corrections and consolidates memories overnight. Shipworthy works alongside these, not instead of them:

- **Auto-memory** captures individual corrections in real-time ("use PostgreSQL not SQLite")
- **Shipworthy's /retro** captures patterns across entire work sessions ("this team always needs CORS, rate limiting, and explicit error messages")
- **Auto-dream** consolidates everything overnight

Three layers, each operating at a different scale. Individual correction → session pattern → long-term consolidation.

## The Architecture

The entire plugin is Markdown and shell scripts. Zero dependencies.

```
shipworthy/
├── skills/          55 engineering skills (Markdown with YAML frontmatter)
├── hooks/           6 hook scripts (Bash) + shared library
├── agents/          6 specialized agent personas (Markdown)
├── commands/        5 slash commands (/scaffold, /audit, /health, /diagnose, /retro)
├── templates/       8 architecture spec templates
├── extensions/      Industry-specific skill packs (e-commerce, etc.)
├── presets/         Configuration bundles (startup, agency, enterprise)
├── adapters/        Rules for non-Claude agents (Cursor, Copilot, Codex, etc.)
└── tests/           190 automated tests
```

Skills are Markdown files with instructions. Hooks are shell scripts that run in milliseconds. There's no build step, no transpilation, no runtime. It's just text that makes Claude smarter.

### Context Window Efficiency

A common concern: "Doesn't loading 55 skills bloat the context window?"

No. Only the master routing skill (~2,000 tokens) is loaded at session start. The other 54 skills load on demand — when Claude determines one is relevant, it reads that specific file. After the task, the skill content naturally scrolls out of context.

On Claude's 200K context window, Shipworthy consumes about 1% at session start. On the 1M window, it's 0.2%. During active work with 3-4 skills loaded, it's still under 2%.

The `.shipworthy/` directory in your project is typically ~15KB. Smaller than most README files.

## What the Numbers Show

We ran a head-to-head test. Two Claude Code agents building the same product — an expense tracker with filtering, budgets, CSV export, and recurring expenses. Same 7 prompts, written like a non-technical founder would write them. Same model. Same everything.

The only difference: one had Shipworthy installed, the other didn't.

The scoring was automated — a bash script written before either agent ran, checking 25 objective metrics. No subjective LLM judgment. Just "does this file exist? does this command pass?"

The difference was stark. Not in features — both built a working expense tracker. The difference was in everything around the features. The things a founder doesn't know to ask for.

The agent with the plugin used a real database, validated every input, wrote tests, configured a linter, set up structured logging, used proper HTTP status codes, and created a `.gitignore`. The agent without the plugin used in-memory arrays, had no validation, no tests, no linter, `console.log` everywhere, and no `.gitignore`.

Both "worked." Only one was production software.

## The Broader Vision

Vibe coding isn't going away. It's too powerful. A non-technical person can now build real software in hours instead of months. That's a permanent shift.

But right now there's a gap. The software that gets built this way works as a demo but breaks as a product. Data disappears. Inputs aren't validated. Errors crash the server. Secrets get committed to GitHub.

I believe the solution isn't to make people stop vibe coding. It's to make vibe coding safe. To add an invisible engineering layer that handles the things you don't know to ask for, scales as your project grows, and gets better every time you use it.

That's what Shipworthy is trying to be.

It's fully open source: [github.com/Vimalk0703/shipworthy](https://github.com/Vimalk0703/shipworthy)

55 skills. 6 hooks. 6 agents. 190 tests. Zero dependencies. One install command.

Vibe coding is how you start. Engineering is what keeps it alive.
