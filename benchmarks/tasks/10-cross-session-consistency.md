# Task 10: Cross-Session Consistency

## Overview

This task evaluates whether code generated across multiple independent sessions maintains consistent patterns and conventions. It is the only task in this benchmark that uses two separate prompts, run in two separate Claude Code sessions against the same project.

The key question: **Does the second session produce code that looks like it was written by the same developer as the first session?**

## Prompt (Session 1)

> I need a user profile page where people can see their info and update things like their name and email.

This prompt is given first, in a fresh Claude Code session. The agent builds the user profile API from scratch on top of the starter project.

## Prompt (Session 2)

> Now I need to add orders — people should be able to place an order, see their past orders, and cancel one if they need to.

This prompt is given in a **new** Claude Code session, starting from the state left by Session 1. The agent must build the orders API on top of whatever Session 1 produced.

Both prompts are given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed in either session.

## Setup

Provide a minimal Express+TypeScript starter project. Both sessions start from this base (Session 2 starts from Session 1's output).

**Directory structure before Session 1:**
```
consistency-api/
  package.json
  tsconfig.json
  .env.example
  src/
    index.ts
    config.ts
  tests/
    (empty)
```

**package.json**:
```json
{
  "name": "consistency-api",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "ts-node-dev src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest --forceExit --detectOpenHandles"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/jest": "^29.5.11",
    "@types/node": "^20.11.0",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.3.3",
    "supertest": "^6.3.3",
    "@types/supertest": "^6.0.2"
  }
}
```

**tsconfig.json**:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**src/index.ts**:
```typescript
import express from 'express';

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

export default app;
```

**src/config.ts**:
```typescript
export const config = {
  port: process.env.PORT || 3000,
};
```

Run `npm install` before handing the project to the agent.

## Running the Benchmark

1. **Session 1**: Start a fresh Claude Code session with the starter project. Give it the Session 1 prompt. Let it complete. Save the project state.
2. **Session 2**: Start a **new** Claude Code session (no conversation history from Session 1). Point it at the project directory left by Session 1. Give it the Session 2 prompt. Let it complete.
3. **Evaluation**: Compare the patterns used in Session 1 and Session 2 output.

For the **with-plugin** run, the Engineering With Vibes plugin is active in both sessions. For the **without-plugin** run, no plugin is active in either session.

## Expected Artifacts

After Session 1:
- `src/routes/users.ts` or `src/routes/profiles.ts` -- user profile endpoints
- `src/services/user.service.ts` or `src/services/profile.service.ts` -- business logic
- `src/types/user.ts` or types in a shared file -- User type definition
- Test files for user profile endpoints

After Session 2 (in addition to Session 1 output):
- `src/routes/orders.ts` -- order endpoints
- `src/services/order.service.ts` -- business logic
- `src/types/order.ts` or types in a shared file -- Order type definition
- Test files for order endpoints
- Updated `src/index.ts` wiring in order routes

## Scoring Criteria (20 points max)

Scoring focuses entirely on **consistency between Session 1 and Session 2 output**. Each check compares a specific dimension of the code.

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **Session 2 follows same patterns as Session 1** | 3 | Overall architectural pattern matches: if Session 1 used routes/services/types separation, Session 2 does the same. If Session 1 used a flat structure, Session 2 matches. |
| 2 | **Same error response format** | 2 | Compare error responses across both APIs. If Session 1 returns `{ "error": { "code": "NOT_FOUND", "message": "..." } }`, Session 2 uses the exact same shape. |
| 3 | **Same file location pattern** | 2 | If Session 1 put routes in `src/routes/users.ts`, Session 2 puts routes in `src/routes/orders.ts` (not `src/api/orders.ts` or `src/order/routes.ts`). |
| 4 | **Same naming convention** | 2 | If Session 1 named the service class `UserService`, Session 2 names it `OrderService` (not `OrdersController` or `orderHandler`). Same for function names: if Session 1 uses `findById`, Session 2 uses `findById` (not `getById`). |
| 5 | **Same auth middleware pattern** | 2 | If Session 1 applied authentication middleware, Session 2 applies the same middleware in the same way (e.g. `router.get('/', authenticate, handler)` vs `app.use('/orders', authenticate, router)`). |
| 6 | **Same validation approach** | 2 | If Session 1 used zod for input validation, Session 2 also uses zod (not joi, or no validation). Schema definition style should match. |
| 7 | **Same test structure** | 2 | Test file naming, test organization (`describe`/`it` style), setup/teardown patterns, and assertion style match across both APIs. |
| 8 | **No breaking changes to Session 1 code** | 3 | All Session 1 tests still pass after Session 2 modifications. Session 1 endpoints still respond correctly. `npm test` passes. |
| 9 | **Types consistent** | 2 | Type definition style matches: if Session 1 uses `interface`, Session 2 uses `interface` (not `type`). If Session 1 uses enums for status values, Session 2 does the same. |

**Total: 20 points**

## Evaluation Method

For each check, perform the following comparison:

1. **Extract the pattern from Session 1 output**: Look at how Session 1 structured its code, named its files, handled errors, etc.
2. **Check if Session 2 matches**: Look at the same dimensions in Session 2's code and verify they align.
3. **Score based on match quality**:
   - Full match: all points
   - Partial match (e.g. same file location but different naming): half points
   - No match (completely different approach): 0 points

### Specific Comparisons to Run

```bash
# 1. File location pattern
diff <(ls src/routes/ | head -5) <(echo "Expected: users.ts and orders.ts in same directory")

# 2. Error format comparison
grep -A3 'status(4' src/routes/users.ts > /tmp/user-errors.txt
grep -A3 'status(4' src/routes/orders.ts > /tmp/order-errors.txt
diff /tmp/user-errors.txt /tmp/order-errors.txt

# 3. Service method naming
grep 'async ' src/services/user.service.ts | sed 's/(.*//' > /tmp/user-methods.txt
grep 'async ' src/services/order.service.ts | sed 's/(.*//' > /tmp/order-methods.txt
# Methods should follow same naming: findAll, findById, create, update, delete

# 4. Test structure
head -20 tests/users.test.ts > /tmp/user-test-structure.txt
head -20 tests/orders.test.ts > /tmp/order-test-structure.txt
# Same import style, same describe/it pattern

# 5. Type definitions
grep 'interface\|type\|enum' src/types/user.ts > /tmp/user-types.txt
grep 'interface\|type\|enum' src/types/order.ts > /tmp/order-types.txt
# Same keyword used (interface vs type), same style

# 6. All Session 1 tests still pass
npm test
```

## Anti-Patterns to Check

- **Completely different architecture**: Session 1 uses routes/services/types, Session 2 puts everything in one file.
- **Different error formats**: Session 1 returns `{ error: "message" }`, Session 2 returns `{ success: false, message: "..." }`.
- **Inconsistent naming**: Session 1 uses `UserService.findAll()`, Session 2 uses `OrderController.getAll()`.
- **Different validation libraries**: Session 1 uses zod, Session 2 uses joi or no validation at all.
- **Different test patterns**: Session 1 tests use `describe`/`it` with `supertest`, Session 2 tests use raw `fetch` calls.
- **Session 2 breaks Session 1**: Adding orders routes causes user routes to fail or changes the user API response format.
- **Different middleware application**: Session 1 applies auth per-route, Session 2 applies auth at the router level. Or vice versa.
- **Type definition drift**: Session 1 uses `interface User { ... }`, Session 2 uses `type Order = { ... }`. Or Session 1 defines types in `src/types/user.ts`, Session 2 defines types inline in the route file.
- **Different HTTP method conventions**: Session 1 uses `PUT` for full updates, Session 2 uses `PATCH`. Or Session 1 returns 204 for deletes, Session 2 returns 200 with a body.
- **Import style differences**: Session 1 uses named exports, Session 2 uses default exports. Or Session 1 uses path aliases, Session 2 uses relative paths.
