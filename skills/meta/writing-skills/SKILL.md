---
name: writing-skills
description: TDD for documentation — write skills that prevent failure modes by first documenting what goes wrong without the skill, then writing the minimal skill to fix it.
invoke_when: Creating a new skill for the engineering-with-vibes plugin, or when a recurring failure mode needs to be codified into a reusable guide.
---

# Writing Skills

## Skills Are Tests for Behavior

Just like code tests verify behavior, skills verify that the AI follows correct processes. Write skills the same way you write tests: identify the failure first, then write the fix.

## TDD for Skills

### RED: Document the Failure
What goes wrong WITHOUT this skill?
- What mistake does the AI make?
- What does the user have to correct repeatedly?
- What quality issue keeps appearing?

### GREEN: Write the Minimal Skill
Write just enough guidance to prevent the documented failures:
- Clear trigger condition (when does this skill activate?)
- Specific rules (what must the AI do/not do?)
- Verification steps (how do you know the skill worked?)

### REFACTOR: Close Loopholes
Review the skill for:
- Rationalizations that could bypass it (add to red flags list)
- Edge cases where the guidance is ambiguous
- Overly broad rules that would cause false positives

## Skill File Structure

```
skills/[category]/[skill-name]/
├── SKILL.md           # The skill itself (required)
└── [supporting].md    # Heavy reference material (optional)
```

### SKILL.md Frontmatter
```yaml
---
name: skill-name
description: One line — what this skill does (used for matching)
invoke_when: When should this skill activate (specific, not vague)
---
```

## Rules for Good Skills

1. **Description says WHEN, not HOW** — prevents skipping the content
2. **Rules are specific and testable** — "write good code" is not a rule
3. **Address rationalizations** — explicitly list reasons someone might skip this skill
4. **Minimal supporting files** — only add separate files for heavy reference material
5. **One skill, one concern** — don't combine unrelated guidance
6. **Skills are prescriptive** — tell the AI what to DO, not what to think about
