---
name: executing-plans
description: Systematic task-by-task execution with TDD flow, verification checkpoints after each task, and architecture compliance checks. Updates tech debt tracker if shortcuts are taken.
invoke_when: An implementation plan has been written and approved, and it's time to start coding.
---

# Executing Plans

## Execution Flow

For each task in the plan:

### 1. Announce
Tell the user which task you're starting and what files you'll touch.

### 2. Write the Test First
- Write the failing test as specified in the plan
- Run it — confirm it FAILS
- If it passes without implementation, the test is wrong — fix it

### 3. Write the Implementation
- Write the minimal code to make the test pass
- Follow architecture.md constraints
- No extra code beyond what the test requires

### 4. Verify
- Run the test — confirm it PASSES
- Run the full test suite — confirm nothing is broken
- Run the build — confirm no type errors

### 5. Refactor (if needed)
- Clean up without changing behavior
- Re-run tests after refactoring

### 6. Mark Complete
- Announce task completion with evidence (test output, build output)
- Move to the next task

## Critical Rules

### Never Skip Verification
After implementing a task, you MUST run the verification command. Do not say "this should work" — prove it works.

### Architecture Compliance Check
Before each task, re-read the relevant Mandatory Rules from architecture.md. If the task would violate a rule, STOP and discuss with the user rather than proceeding.

### Handling Failures
- If a test fails unexpectedly: invoke `systematic-debugging` — do NOT guess-fix
- If 3+ attempts fail: stop and reassess — likely an architectural issue
- If you need to take a shortcut: invoke `tech-debt-tracking` to document it

### Handling Plan Deviations
- If you discover the plan needs changes mid-execution:
  1. Stop executing
  2. Explain what changed and why
  3. Propose plan updates
  4. Get approval before resuming

### Commit Cadence
- Commit after each task (or group of tightly related tasks)
- Commit message should reference the plan task number
- Never batch all tasks into one giant commit
