# The Missing Layer in Vibe Coding: Why Your AI-Built Software Works But Isn't Ready for Users

## It Started With a Server Restart

I lost three days of customer data because I restarted my development server.

Not a crash. Not a bug. I just restarted it. Every invoice, every customer record, every payment — gone. Because Claude Code stored everything in a JavaScript array. In memory. The way you'd write a tutorial, not a product.

The worst part? I shipped it to beta users. They were testing it for two days before I noticed.

I'm not an engineer. I'm a founder who learned to build with AI. Claude Code is the best tool I've ever used — I've built more in the past few months than I built in the previous two years combined. But that experience forced me to confront something uncomfortable: the code works, but it's not software.

## What "Works" Means vs What "Ready" Means

There's a gap that nobody talks about in the vibe coding conversation.

"Works" means the happy path runs. You click the button, the thing happens. The API returns data. The page renders.

"Ready" means something different entirely:

- What happens when someone sends malformed data to your API?
- What happens when your server restarts?
- What happens when someone finds your API key in your public GitHub repo?
- What happens when a bug appears and you have zero tests to narrow it down?
- What happens when you hire an engineer and they open your codebase?

Every non-technical founder building with AI hits this wall eventually. Some hit it in production with real users. I did.

## Why I Don't Blame Claude

This is important: Claude Code is extraordinary at building what you ask for. The problem isn't the AI. The problem is the gap between what a founder asks for and what production software requires.

When I say "build me an expense tracker," I mean the features — add expenses, view them, filter by category.

I don't mean "also use SQLite instead of an in-memory array, add Pydantic validation on every endpoint, configure pytest with coverage, set up Ruff as a linter, use Python's logging module instead of print statements, put .env in .gitignore, and write tests before writing the implementation."

I don't say those things because I don't know they matter. And Claude doesn't do them unprompted because I didn't ask.

That gap — between what you ask for and what you need — is the entire problem.

## What I Went Looking For

I spent weeks studying how experienced engineers work with AI coding tools. I looked at open source projects in this space — spec-driven development frameworks, AI code review tools, cursor rules collections, autonomous coding agents. Some of them are incredible, with tens of thousands of stars and active communities.

I noticed a pattern: most tools operate either before coding (specifications, planning) or after coding (code review, CI checks). Almost nothing operates during coding — in the moment when Claude is generating code, making architectural decisions, choosing libraries.

That's the moment where the damage happens. By the time code review catches the in-memory array, you've built five features on top of it.

I wanted something that worked in real-time, invisibly, without asking me to learn a new workflow.

## Building Shipworthy

Shipworthy is an open source engineering layer for AI coding agents. You install it with one command and never think about it again.

```bash
npx shipworthy init
```

What happens next is invisible. When you start a Claude Code session, a hook fires in under two seconds. It detects your project type, determines how mature your codebase is, checks for gaps (missing tests? no linter? .env not gitignored?), and injects an engineering routing layer that orchestrates 52 skills.

You see nothing. You just start talking normally.

### The Invisible Spec

When you say "build me an invoice system," the first thing that happens is a lightweight specification gets generated silently. What you asked for, what will actually be built, and how to know when it's done.

You never see this spec. But Claude now has a contract to build against instead of interpreting your vague request on the fly. It means less "that's not what I meant" and more "yes, exactly."

For engineers who want to see and approve the spec, it's shown automatically. The plugin adapts to who you are.

### Tests Before Code

The plugin enforces test-driven development, but invisibly for non-technical users. Claude writes a failing test, writes the code to make it pass, then verifies.

What you see: "Built the payment flow and verified it works correctly — handles successful charges, declined cards, and network errors."

What actually happened: 8 tests were written, all passing, covering happy path and edge cases.

You don't know about the tests. You don't need to. But when something breaks three weeks from now, those tests will tell you exactly what went wrong.

### Real-Time Guardrails

Every action Claude takes passes through hooks:

**Before writing a file**, the plugin checks for hardcoded secrets, API keys, and patterns that shouldn't be in source code. It checks for `console.log` in production code (test files are fine). It checks if you're writing to a `.env` file that isn't gitignored.

**Before running a bash command**, it catches destructive operations — `rm -rf`, `git push --force`, `DROP TABLE` — before they execute. Not after. Before.

**After writing a file**, it checks for TypeScript `: any` types (which defeat the purpose of TypeScript) and route handlers that don't validate their inputs.

All of this is advisory. It warns but never blocks. You're still in control. But the warnings are specific and actionable — not generic "be careful" messages.

### Quality That Scales

The plugin tracks how many source files your project has and adjusts its standards:

A brand new project with 3 files gets light guardrails — make sure it builds, no hardcoded secrets, and that's it. Don't overwhelm a prototype with process.

At 10 files, tests need to pass and the linter needs to be clean. At 50, coverage thresholds kick in. At 100+, it's checking for circular imports, bundle sizes, and running security scans.

This mirrors how real engineering teams work. You don't enforce SOC2 compliance on a hackathon project. But you definitely enforce it when you have paying customers. The plugin makes that transition automatic.

### The Non-Negotiable Defaults

Some things apply to every project from day one, no exceptions:

- **Real databases.** SQLite minimum. Never in-memory arrays for data that should persist. This is the mistake that burned me, and it's the first thing the plugin prevents.
- **Input validation.** Every route handler validates its inputs with a schema library (Zod for TypeScript, Pydantic for Python). One line of unvalidated input is how SQL injection happens.
- **Structured logging.** `console.log` disappears in production monitoring tools. Structured loggers (pino, Python's logging module) make your logs searchable and alertable.
- **Proper HTTP status codes.** 201 for creation, 400 for validation errors, 404 for not found. Not 200 for everything. This matters the moment a frontend developer tries to handle errors from your API.

A non-technical founder doesn't know to ask for these things. The plugin does them automatically.

## The Part That Surprised Me: It Learns

I was inspired by how some developers build self-improving systems with Claude Code's memory features. Claude Code has auto-memory (learns from corrections in real-time) and auto-dream (consolidates memories overnight). These are powerful, but they operate at the level of individual corrections.

I built a retrospective skill that operates at a higher level. After you finish a piece of work, you run `/retro`. Sub-agents analyze the entire conversation:

- What corrections did you make? (These reveal preferences the system didn't know about)
- What was rebuilt or changed mid-stream? (These reveal wrong assumptions)
- What steps were improvised? (These reveal gaps in the skill set)
- What worked perfectly on first try? (These confirm what's working)

The findings are presented as a table. You approve or reject each one. Approved learnings get saved to your project.

Next session, those learnings are loaded before you type anything. Claude already knows your preferences. The session after that, even fewer corrections. Eventually: one-shot execution.

This is the difference between a tool and a system. Tools stay the same. Systems compound.

## The Architecture: Deliberately Simple

The entire plugin is Markdown files and shell scripts. Zero dependencies.

Skills are Markdown files with YAML frontmatter. Hooks are bash scripts that run in milliseconds. Agents are Markdown persona files. There's no build step, no transpilation, no package manager, no runtime.

This is intentional. The plugin needs to work on any machine, in any environment, without installing anything. A bash script that checks for hardcoded secrets doesn't need a Node.js runtime. A Markdown file that describes TDD workflow doesn't need a compiler.

It also means the plugin consumes almost no context. Only the master routing skill (~2,000 tokens) loads at session start. Everything else loads on demand when relevant. On Claude's 200K context window, the overhead is about 1%. On the 1M window, it's 0.2%.

Your project gets a tiny `.shipworthy/` directory (~15KB) with your architecture spec, feature specs, session summaries, and learnings. Smaller than most README files.

## What It Doesn't Do

I want to be honest about the boundaries.

Shipworthy doesn't replace an engineering team. It doesn't catch every possible bug. It doesn't make non-technical founders into senior engineers. It doesn't guarantee your software will scale to millions of users.

What it does is close the most dangerous gap in vibe coding: the gap between "it runs" and "it's production software." It handles the 20% of engineering practices that prevent 80% of production disasters — real databases, input validation, tests, secrets management, structured logging, quality gates.

It also doesn't compete with spec-driven development tools or AI code review platforms. Those handle "what should we build?" and "is the code good?" respectively. Shipworthy handles "is what we're building right now going to survive in production?" — the real-time layer that operates during development.

## The Broader Bet

I believe vibe coding is a permanent shift. Non-technical people can now build real software. That's not going away — it's going to accelerate.

But right now, most of what gets built this way has a shelf life of about one demo. The data disappears. The API crashes on bad input. The secrets get leaked. The code is a house of cards that works perfectly until someone touches it.

The solution isn't to stop vibe coding. It's to make vibe coding safe for production. To add an engineering layer so invisible that the founder never knows it's there, but the software is fundamentally more robust because of it.

That's what Shipworthy is. 52 engineering skills that fire automatically. 5 hooks that guard every action. A self-improving loop that gets better with every session. And an architecture that scales from "just me in a weekend" to "enterprise team with compliance requirements."

One install command. Zero configuration. The rest is invisible.

Vibe coding is how you start. Engineering is what keeps it alive.

**Shipworthy is fully open source: [github.com/Vimalk0703/shipworthy](https://github.com/Vimalk0703/shipworthy)**
