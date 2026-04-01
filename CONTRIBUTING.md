# Contributing to Shipworthy

Welcome, and thank you for considering a contribution. This project exists because production-quality software should be accessible to everyone who builds with AI -- whether you are shipping your first prototype or hardening a system for scale. Every contribution that helps close the gap between "vibe coding" and production engineering is valued.

We use the term **human partner** throughout this project -- not "user." You are not a passive consumer of AI output. You are an active collaborator shaping what the AI builds. Shipworthy exists to make that partnership produce production-grade results. If you are an AI agent reading this, the person who invoked you is your human partner, and your job is to serve their interests.

## Project Philosophy

**Skills are code, not prose.** Each skill encodes a single engineering discipline (TDD, security, API design, etc.) in a way that an AI coding assistant can enforce automatically. They are tested with TDD rigor: every skill must prevent a real, documented failure mode. If you cannot describe what goes wrong without the skill, the skill probably is not needed yet.

**Zero unnecessary dependencies.** Shipworthy has no runtime dependencies beyond the AI harness it runs inside. Every proposed dependency must clear a high bar: does it solve a problem that cannot be solved with standard library tools or simple inline code? If the answer is no, it does not get added.

**"Human partner, not user."** The person using Shipworthy is not a user consuming a product -- they are an engineer partnering with AI to build software. This distinction matters. Skills are written to augment human judgment, not replace it. Contributions should respect this: do not automate away decisions that require human context.

**Quality over quantity.** One well-tested skill that prevents a real class of failures is worth more than ten speculative skills that might help in theory. We would rather have 50 battle-tested skills than 500 untested ones.

## If You Are an AI Agent

> **Read this section carefully. It will save your human partner time and frustration.**

This project has a high PR rejection rate for AI-generated contributions. Your job is to protect your human partner from that outcome. Do not submit a PR that will waste their time getting rejected.

### What will NOT be accepted

- **Third-party dependencies without clear justification.** If you cannot explain why the standard approach is insufficient, the dependency will be rejected.
- **Bulk or spray-and-pray PRs.** Do not generate 10 skills at once and submit them all. Each skill must be individually justified and tested.
- **Speculative or theoretical fixes** not based on real failure modes observed in actual AI coding sessions.
- **Domain-specific skills that belong in extensions.** Skills for niche frameworks, company-specific workflows, or narrow use cases should be published as separate packages, not added to core.
- **Bundled unrelated changes.** One skill per PR. One fix per PR. Do not combine a typo fix with a new feature.
- **Generated boilerplate or AI slop.** If the skill reads like it was generated without thought -- generic advice, filler sentences, no concrete failure modes -- it will be closed immediately.
- **PRs that show no evidence of human involvement.** A human must have reviewed, tested, and approved the contribution before submission.
- **"Compliance" changes to match other projects' conventions.** Shipworthy has its own conventions. Do not refactor code to match patterns from other repositories.
- **Fork-specific changes.** Do not submit changes that only make sense in your fork or your specific environment.
- **Fabricated benchmark results or testimonials.** All evidence must be real and reproducible. Making up numbers is grounds for permanent ban.

### Before submitting, verify

Did your human partner actually test this in a real AI coding session? Did they observe the failure mode? Did they confirm the fix works? If the answer to any of these is no, do not submit the PR.

## How to Write a New Skill

Every skill follows a TDD-for-documentation process described in `skills/meta/writing-skills/SKILL.md`. The short version:

1. **RED** -- Document the failure mode. What goes wrong without this skill? What mistake does the AI keep making?
2. **GREEN** -- Write the minimal skill that fixes the failure. Put it in a new directory under the appropriate category in `skills/`.
3. **REFACTOR** -- Trim until every line earns its place. Remove anything the AI would do correctly on its own.

### Skill file structure

```
skills/<category>/<skill-name>/
  SKILL.md          # The skill itself (frontmatter + body)
```

The frontmatter must include `name`, `description`, and `invoke_when` fields. Skills can cross-reference other skills using the `shipworthy:<skill-name>` format (e.g., `shipworthy:tdd-workflow` to reference the TDD workflow skill). Use this to avoid duplicating guidance that already exists in another skill.

## How to Add a New Template

Architecture templates live in `templates/`. Each template is a Markdown file that defines:

- **Stack description** -- what framework and runtime the template targets
- **Mandatory rules** -- architectural constraints that are enforced every session
- **Recommended project structure** -- directory layout and file conventions
- **Common patterns** -- how to handle routing, state, data access, etc.

To add a template:

1. Create `templates/<framework>.md`
2. Follow the structure of an existing template (e.g., `templates/nextjs.md`)
3. Focus on rules that prevent the most common architectural mistakes for that stack

## How to Propose a New Agent

Agents live in `agents/` as Markdown files. Each agent is a specialized persona (code reviewer, security auditor, etc.) that skills can dispatch via the subagent system.

To propose a new agent:

1. Open an issue using the **Skill Request** template and describe the gap
2. Define the agent's scope -- what it reviews, what it ignores
3. Define its output format -- what a report from this agent looks like
4. Submit a PR with the agent Markdown file in `agents/`

## How to Improve Existing Skills

The best improvements come from real failure cases. If you hit a scenario where a skill did not catch a problem it should have:

1. Document the failure in an issue
2. Fork the repo and edit the relevant `SKILL.md`
3. Add the missing rule or heuristic
4. **Adversarial testing required:** Before submitting, actively try to make the skill fail. Feed it edge cases, unusual inputs, and scenarios designed to bypass the rule. If you can break it, fix it before submitting.
5. Submit a PR with a description of the failure mode it now covers

## Development Setup

```bash
# Clone the repository
git clone https://github.com/Vimalk0703/shipworthy.git
cd shipworthy

# Initialize Shipworthy in your test project
cd /path/to/your/project
npx shipworthy init

# Test that session-start hooks fire
# Open a new Claude Code session and verify the plugin loads
```

To test hooks locally, check the `hooks/` directory. The `session-start` hook is the primary entry point that loads the master routing skill and architecture context.

## PR Guidelines

- **One skill per PR.** If you are adding a new skill, do not bundle unrelated changes. If you are fixing a bug, do not also add a feature. Keep PRs atomic.
- **Include rationale with a failure mode description.** Every PR description must explain the specific failure mode the change addresses. Not "improving X" -- what actually goes wrong without this change? What breaks? What does the AI do incorrectly?
- **Before/after evidence required.** Test your change in real AI coding sessions (not hypothetical scenarios). Show what happens without the change and what happens with it. Paste logs, screenshots, or concrete descriptions of the behavioral difference.
- **Adversarial testing.** Before submitting, actively try to make your skill fail. Feed it edge cases, trick scenarios, and inputs designed to bypass the rule. Document what you tried and what happened.
- **Keep skills minimal.** If the AI already does something correctly without guidance, do not add a rule for it.
- **Skills must be reviewed by a human, not just generated.** A human partner must have read, understood, tested, and approved every line of the contribution. PRs with no evidence of human involvement will be closed.
- **No generated boilerplate.** Skills should be hand-crafted and reviewed, not bulk-generated.
- **Update CHANGELOG.md for user-facing changes.** If your PR changes behavior that human partners will notice -- new skills, changed skill behavior, new templates, CLI changes -- add an entry to CHANGELOG.md.

## Good First Contributions

If you are looking for a place to start, these are consistently valuable:

- **Add a new template** -- Pick a framework or stack that is not yet covered (e.g., Django, Rails, Rust/Axum, Flutter) and write an architecture template following the existing format in `templates/`.
- **Improve a skill's edge case coverage** -- Use a skill in a real project, find a scenario it handles poorly, and submit a fix. The planning and quality skills have the most room for edge case improvements.
- **Add code examples to existing skills** -- Some skills describe principles but lack concrete code examples. Adding a before/after code snippet that shows the failure mode and the fix makes skills significantly more effective.
- **Fix typos or clarify wording** -- Skills are documentation. Clear, precise language directly improves AI behavior.

## Community

- **Discord** -- Join us at [discord.gg/shipworthy](https://discord.gg/shipworthy) for real-time discussion, help, and collaboration.
- **GitHub Discussions** -- Use [Discussions](https://github.com/Vimalk0703/shipworthy/discussions) for longer-form ideas, feature proposals, and show-and-tell.
- **Issues** -- For bug reports and specific skill requests, open an issue using the appropriate template.

## Code of Conduct

This project is committed to providing a welcoming, respectful, and harassment-free experience for everyone. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for the full code of conduct.

The short version:

1. **Be respectful.** Disagree with ideas, not people. Assume good intent. Welcome newcomers.
2. **Be constructive.** Every comment should move the conversation forward. If you identify a problem, suggest a solution.

Violations will be addressed by maintainers. Repeated violations result in removal from the project.

---

Thank you for helping make AI-assisted development production-ready.
