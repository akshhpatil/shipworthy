---
name: brainstorming
description: 9-step design discovery process that prevents wasted work on wrong assumptions. Enforces design-before-code discipline with architecture-aware constraints.
invoke_when: User wants to build something new, add a significant feature, or redesign existing functionality. Do NOT implement until design is approved.
---

# Brainstorming

## Hard Gate

**Do NOT implement until design is approved.** Writing code before understanding the problem wastes hours of work when assumptions are wrong.

## The 9 Steps

### Step 1: Explore Context
- Read relevant existing code, configs, and architecture.md
- Understand what exists, what patterns are established, what constraints apply
- If architecture.md exists, all proposals MUST comply with its Mandatory Rules

### Step 2: Understand the Problem
- What problem is being solved? (Not "what feature to build" — what PROBLEM)
- Who is affected?
- What happens if this isn't solved?

### Step 3: Ask Clarifying Questions
- What's unclear about the requirements?
- What are the edge cases?
- What are the constraints (performance, security, compatibility)?
- Ask these questions NOW, not after implementing the wrong thing

### Step 4: Propose Alternatives
- Present at least 2-3 approaches
- For each: brief description, pros, cons, estimated complexity
- Include a "simplest possible" option — sometimes it's the right one

### Step 5: Recommend an Approach
- State which approach you recommend and why
- Reference architecture.md constraints that influenced the recommendation
- Identify risks and mitigations

### Step 6: Write a Design Spec
- Save to `docs/engineering-with-vibes/specs/[feature-name].md`
- Include: problem, approach, data model changes, API changes, UI changes, testing approach
- Keep it concise — a spec is not a novel

### Step 7: Self-Review
- Does this violate any Mandatory Rules from architecture.md?
- Does this introduce circular dependencies?
- Does this increase complexity proportional to the value it delivers?
- Is there a simpler way?

### Step 8: Present for Approval
- Show the user the design spec
- Ask for explicit approval before proceeding
- "Does this approach make sense? Should I proceed with writing the implementation plan?"

### Step 9: Transition to Planning
- Once approved, invoke the `writing-plans` skill
- Pass the approved design spec as context

## Anti-Pattern: Skipping Brainstorming

If you catch yourself writing implementation code before completing at least steps 1-5, STOP. Delete the code. Go back to step 1. The 10 minutes you spend brainstorming saves hours of rework.
