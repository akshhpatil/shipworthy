# Task 01: REST API CRUD

## Prompt

> I need a to-do list feature for my app. People should be able to add tasks, check them off, edit them, and delete them. It needs to work as a backend that a mobile app or website could talk to.

This prompt is given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed.

## Setup

Create an empty project directory with only the following starter files:

**package.json**
```json
{
  "name": "todo-api",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "ts-node-dev src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3",
    "ts-node-dev": "^2.0.0"
  }
}
```

**tsconfig.json**
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
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**Directory structure before the task:**
```
todo-api/
  package.json
  tsconfig.json
```

No `src/` directory, no installed `node_modules/`. The agent must scaffold everything.

## Expected Artifacts

After the task completes, the following should exist at minimum:

- `src/index.ts` -- application entry point, starts the server
- `src/routes/` -- route definitions (e.g. `todo.routes.ts`)
- `src/controllers/` or `src/handlers/` -- request handler functions
- `src/types/` or `src/models/` -- TypeScript type/interface definitions for Todo
- `src/middleware/` -- error handling middleware at minimum
- Test files (e.g. `src/__tests__/`, `tests/`, or `*.test.ts` files)
- Validation logic (inline or in a dedicated `src/validators/` or `src/schemas/` directory)

The project must compile with `npx tsc --noEmit` and tests must pass with the chosen test runner.

## Scoring Criteria (20 points max)

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **Tests exist and pass** | 3 | Run the test command. At least 3 test cases covering create, read, and delete. |
| 2 | **Input validation with zod or joi** | 2 | A validation library is in `package.json` and used in route/controller logic. Raw `if (!req.body.title)` does not count. |
| 3 | **Proper HTTP status codes** | 2 | 201 for create, 200 for read/update, 204 or 200 for delete, 404 for not found, 400 for bad input. Grep response status codes. |
| 4 | **Error-handling middleware** | 2 | An Express error middleware (`(err, req, res, next)`) is registered and used. |
| 5 | **TypeScript strict mode enabled** | 2 | `tsconfig.json` has `"strict": true` and `npx tsc --noEmit` exits 0. |
| 6 | **No `any` types** | 1 | `grep -r ': any' src/` returns 0 results (excluding `node_modules`). |
| 7 | **Structured error responses** | 2 | Error responses follow a consistent shape, e.g. `{ "error": { "code": "...", "message": "..." } }`. Not bare strings. |
| 8 | **Env vars not hardcoded** | 2 | Port and any config values come from `process.env` with a fallback, not magic numbers in code. |
| 9 | **Types/interfaces defined** | 2 | A `Todo` interface or type exists with at least `id`, `title`, `completed`, `createdAt`. |
| 10 | **Build passes** | 2 | `npm run build` exits 0 and produces files in `dist/`. |

**Total: 20 points**

## Anti-Patterns to Check

These are red flags indicating the code is NOT production-ready. Each one found should be noted in the evaluation report.

- **No validation at all**: The API accepts any payload shape without complaint.
- **`any` used as a type escape hatch**: e.g. `const todos: any[] = []`.
- **Hardcoded port**: `app.listen(3000)` with no env var support.
- **No error handling middleware**: Errors crash the process or return raw stack traces.
- **Global mutable state without acknowledgment**: Using a plain array as a database is acceptable for a demo, but it should be clearly marked (e.g. a comment saying "in-memory store") rather than silently used as if it were persistent.
- **Console.log as the only error reporting**: No structured logging or error response.
- **Missing `.gitignore`**: `node_modules/` and `dist/` would be committed.
- **No test runner configured**: Tests referenced but no way to run them.
- **catch blocks that swallow errors**: `catch (e) {}` with no logging or re-throw.
- **Request body used without parsing middleware**: `express.json()` not registered.
