---
name: Template Request
about: Propose a new architecture template
title: "[Template] "
labels: enhancement, template
assignees: ''
---

## What framework or stack?

Name the framework, language, or stack this template would cover (e.g., Django, Rails, Rust/Axum, Flutter, SvelteKit).

## What mandatory rules would it include?

List the architectural constraints that should be enforced every session. Focus on rules that prevent the most common mistakes for this stack.

Example:
- All routes must use [pattern]
- State management must follow [approach]
- Database access must go through [layer]

## Example project structure

Provide a recommended directory layout:

```
project-root/
  src/
    ...
  tests/
    ...
  ...
```

## Why is this template needed?

How popular is this stack? What goes wrong when Claude generates code for it without architectural guidance?

## References

Link to any official style guides, best-practice docs, or example projects that should inform this template.
