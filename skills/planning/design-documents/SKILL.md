---
name: design-documents
description: Formal RFC/design doc template for significant changes. Includes second-order effects, rollout plan, rollback plan, and alternatives considered.
invoke_when: Change exceeds 500 LOC, introduces a new service, adds a new database table, adopts a new external dependency, or makes a significant architectural decision.
---

# Design Documents

## When to Write a Design Doc

A design doc is required when any of these apply:
- Change exceeds **500 lines of code**
- Introduces a **new service or major module**
- Adds a **new database table or schema change**
- Adopts a **new external dependency or service** (Stripe, Supabase, etc.)
- Makes a **significant architectural decision** that affects multiple components
- Changes **API contracts** in a breaking way

For smaller changes, a PR description is sufficient. Do not write design docs for routine feature work.

## Template

Save design docs to `.engineering-with-vibes/decisions/design-[feature-name].md`:

```markdown
# Design: [Feature Name]

## Metadata
- **Author**: [name]
- **Status**: Draft | In Review | Approved | Rejected | Superseded
- **Date**: YYYY-MM-DD
- **Reviewers**: [list]

## Context & Problem Statement
[What problem are we solving? Why now? What happens if we don't solve it?]

## Goals
[What must this solution achieve?]

## Non-Goals
[What is explicitly out of scope? This prevents scope creep.]

## Proposed Solution
[Detailed description. Include diagrams if helpful. Be specific about:
- Data flow
- API changes (with request/response examples)
- Database changes (with schema)
- UI changes (with wireframes or descriptions)]

## Alternatives Considered
[At least 2 alternatives. For each: description, pros, cons, why rejected.]

### Alternative A: [Name]
- **Description**: ...
- **Pros**: ...
- **Cons**: ...
- **Why rejected**: ...

### Alternative B: [Name]
- **Description**: ...
- **Pros**: ...
- **Cons**: ...
- **Why rejected**: ...

## Data Model Changes
[New tables, columns, indexes. Migration strategy.]

## API Changes
[New or modified endpoints. Backward compatibility analysis.]

## Security Considerations
[Auth changes, data access changes, new attack surface, threat model.]

## Performance Implications
[Expected load, query patterns, caching strategy, bundle size impact.]

## Second-Order Effects
[What else does this change affect?
- Other teams or services
- Data pipelines or reports
- Monitoring and alerting
- On-call burden
- Future flexibility (does this close off options?)]

## Rollout Plan
[How will this be deployed?
- Feature flags?
- Percentage rollout?
- Database migration strategy?
- Rollback trigger criteria?]

## Rollback Plan
[How to undo if it goes wrong. Specific steps, not "we'll figure it out."]

## Testing Strategy
[What tests will verify this works? Unit, integration, E2E?]

## Open Questions
[What is still unresolved? Who needs to answer?]

## Timeline
[Rough estimate. Not a commitment, but a sense of scale.]
```

## Review Process

1. Author writes the doc and shares for review
2. Reviewers provide feedback (focus on: feasibility, risks, alternatives)
3. Author addresses feedback
4. Doc moves to "Approved" when reviewers agree
5. Implementation begins only after approval

## After Implementation

Update the doc's status to note what actually happened vs. what was planned. This helps future design docs be more realistic.
