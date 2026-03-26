---
name: test-driven-development
description: RED-GREEN-REFACTOR discipline. No production code without a failing test first. Integrates with architecture.md to know the project's testing framework and patterns.
invoke_when: Writing any production code, adding features, fixing bugs, or refactoring. This is the most fundamental quality skill.
---

# Test-Driven Development

## The Iron Rule

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

If you wrote production code and then wrote a test, you did it backwards. If you didn't watch the test fail, delete the code and start over.

## RED-GREEN-REFACTOR Cycle

### RED: Write a Failing Test
1. Decide what the code should DO (not how it should work internally)
2. Write a test that asserts the expected behavior
3. Run the test — it MUST fail
4. If it passes, your test is wrong or the feature already exists

### GREEN: Make It Pass
1. Write the MINIMUM code to make the test pass
2. Do not write elegant code — write working code
3. Do not add features the test doesn't require
4. Run the test — it MUST pass

### REFACTOR: Clean Up
1. Now that it works, make it clean
2. Extract common patterns, improve naming, simplify logic
3. Run tests after EVERY refactor step — they must still pass
4. If tests break during refactoring, your refactor changed behavior — undo it

## What MUST Be Tested

- Pure functions and business logic — ALWAYS
- API endpoints — ALWAYS (request/response contract)
- Data transformations — ALWAYS
- Error handling paths — ALWAYS
- Edge cases identified during brainstorming — ALWAYS

## What MAY Skip Tests

- Simple pass-through wrappers with no logic
- Configuration files
- Static markup with no dynamic behavior
- Third-party library usage that's already tested by the library

## Testing Anti-Patterns to Avoid

1. **Testing implementation, not behavior** — test WHAT it does, not HOW it does it
2. **Mocking everything** — mocks that diverge from reality give false confidence
3. **Testing the framework** — don't test that React renders a div
4. **No assertions** — a test without assertions is not a test
5. **Flaky tests** — fix or delete; a flaky test is worse than no test
6. **Testing trivial getters/setters** — this adds maintenance, not confidence

## Integration with Architecture Spec

Read `architecture.md` to determine:
- Which testing framework to use (Jest, Vitest, pytest, Go testing, etc.)
- Where test files should live (co-located, `__tests__/`, `tests/`)
- Naming conventions for test files
- Coverage thresholds (if specified)

Follow whatever the architecture spec says. If it doesn't specify, ask the user.
