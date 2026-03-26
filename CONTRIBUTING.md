# Contributing to Engineering With Vibes

Welcome, and thank you for considering a contribution. This project exists because production-quality software should be accessible to everyone who builds with AI -- whether you are shipping your first prototype or hardening a system for scale. Every contribution that helps close the gap between "vibe coding" and production engineering is valued.

## Project Philosophy

Skills are the atomic unit of this plugin. Each skill encodes a single engineering discipline (TDD, security, API design, etc.) in a way that Claude Code can enforce automatically. The bar for a good skill is simple: **it must prevent a real failure mode.** If you cannot describe what goes wrong without the skill, the skill probably is not needed yet.

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

The frontmatter must include `name`, `description`, and `invoke_when` fields.

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
4. Submit a PR with a description of the failure mode it now covers

## Development Setup

```bash
# Clone the repository
git clone https://github.com/Vimalk0703/engineering-with-vibes.git
cd engineering-with-vibes

# Install the plugin locally in Claude Code
/plugin install /path/to/engineering-with-vibes

# Test that session-start hooks fire
# Open a new Claude Code session and verify the plugin loads
```

To test hooks locally, check the `hooks/` directory. The `session-start` hook is the primary entry point that loads the master routing skill and architecture context.

## PR Guidelines

- **One skill per PR.** If you are adding a new skill, do not bundle unrelated changes.
- **Include rationale.** Every PR description must explain the failure mode the change addresses. "What goes wrong without this?"
- **Keep skills minimal.** If the AI already does something correctly without guidance, do not add a rule for it.
- **Test your skill.** Before submitting, use the skill in a real Claude Code session and verify it changes behavior.
- **No generated boilerplate.** Skills should be hand-crafted and reviewed, not bulk-generated.

## Code of Conduct

This project follows two simple rules:

1. **Be respectful.** Disagree with ideas, not people. Assume good intent. Welcome newcomers.
2. **Be constructive.** Every comment should move the conversation forward. If you identify a problem, suggest a solution.

Violations will be addressed by maintainers. Repeated violations result in removal from the project.

## Good First Contributions

If you are looking for a place to start, these are consistently valuable:

- **Add a new template** -- Pick a framework or stack that is not yet covered (e.g., Django, Rails, Rust/Axum, Flutter) and write an architecture template following the existing format in `templates/`.
- **Improve a skill's edge case coverage** -- Use a skill in a real project, find a scenario it handles poorly, and submit a fix. The planning and quality skills have the most room for edge case improvements.
- **Add code examples to existing skills** -- Some skills describe principles but lack concrete code examples. Adding a before/after code snippet that shows the failure mode and the fix makes skills significantly more effective.
- **Fix typos or clarify wording** -- Skills are documentation. Clear, precise language directly improves AI behavior.

---

Thank you for helping make AI-assisted development production-ready.
