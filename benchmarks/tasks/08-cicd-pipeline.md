# Task 08: CI/CD Pipeline

## Prompt

> Every time I push code I'm scared I'll break something. I want it set up so the code gets checked automatically before it goes live — run the tests, make sure nothing is broken, and deploy it if everything looks good.

This prompt is given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed.

## Setup

Provide a TypeScript project with existing tests and lint configuration but no CI/CD. The project has a `Dockerfile` for containerized deployment.

**Directory structure before the task:**
```
cicd-project/
  package.json
  tsconfig.json
  Dockerfile
  .eslintrc.json
  .prettierrc
  src/
    index.ts
    routes/
      health.ts
      users.ts
      orders.ts
    middleware/
      authenticate.ts
      errorHandler.ts
    services/
      user.service.ts
      order.service.ts
    types/
      index.ts
  tests/
    health.test.ts
    users.test.ts
    orders.test.ts
```

**package.json** (key scripts):
```json
{
  "name": "cicd-project",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "ts-node-dev src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest --forceExit --detectOpenHandles --coverage",
    "lint": "eslint src/ --ext .ts",
    "lint:fix": "eslint src/ --ext .ts --fix",
    "format": "prettier --check 'src/**/*.ts'",
    "format:fix": "prettier --write 'src/**/*.ts'"
  },
  "dependencies": {
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/jest": "^29.5.11",
    "@types/node": "^20.11.0",
    "eslint": "^8.56.0",
    "@typescript-eslint/eslint-plugin": "^6.19.0",
    "@typescript-eslint/parser": "^6.19.0",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.3.3",
    "prettier": "^3.2.4",
    "supertest": "^6.3.3",
    "@types/supertest": "^6.0.2"
  }
}
```

**Dockerfile**:
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**.eslintrc.json**:
```json
{
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": "warn"
  }
}
```

All tests pass (`npm test`), lint passes (`npm run lint`), and build succeeds (`npm run build`) before the task begins. No `.github/` directory exists.

## Expected Artifacts

After the task completes, the following should exist at minimum:

- `.github/workflows/ci.yml` -- the main CI/CD workflow file
- Optionally `.github/dependabot.yml` for dependency updates
- Updated `README.md` with a status badge (optional but scored)

## Scoring Criteria (20 points max)

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **`.github/workflows/ci.yml` exists** | 2 | The file exists with valid YAML syntax. Run `yq '.' .github/workflows/ci.yml` or a YAML linter. |
| 2 | **Lint step** | 2 | The workflow has a step that runs `npm run lint` or equivalent. It should fail the pipeline if lint errors are found. |
| 3 | **Test step** | 2 | The workflow has a step that runs `npm test`. Test failures fail the pipeline. |
| 4 | **Build step** | 2 | The workflow has a step that runs `npm run build` or `docker build`. Build failures fail the pipeline. |
| 5 | **Deploy step with environment** | 2 | The workflow has a deploy step/job that only runs on `push` to `main` (not on PRs). It references a GitHub environment (e.g. `environment: staging`). |
| 6 | **Secrets used, not hardcoded** | 2 | Any deployment credentials, API keys, or tokens reference `${{ secrets.* }}`. No hardcoded values. |
| 7 | **Branch protection mentioned** | 1 | A comment in the workflow or a separate document mentions that branch protection rules should require CI to pass before merging. |
| 8 | **Caching for node_modules** | 2 | The workflow uses `actions/cache` or `actions/setup-node` with `cache: 'npm'` to cache `node_modules` between runs, speeding up CI. |
| 9 | **Proper job dependencies** | 2 | Jobs are structured with `needs:` so that deploy only runs after lint, test, and build all succeed. Or steps are ordered correctly in a single job. |
| 10 | **Status badge** | 1 | A markdown badge referencing the workflow status is added (e.g. to `README.md`). Example: `![CI](https://github.com/owner/repo/actions/workflows/ci.yml/badge.svg)` |
| 11 | **Matrix testing considered** | 2 | The workflow uses a matrix strategy to test against multiple Node.js versions (e.g. 18, 20), or includes a comment explaining why matrix testing was not necessary. |

**Total: 20 points**

## Anti-Patterns to Check

- **Invalid YAML syntax**: The workflow file does not parse as valid YAML. Indentation errors, missing colons, or wrong nesting.
- **Deploy on every push**: The deploy step runs on pushes to feature branches, not just `main`.
- **Deploy on pull request**: Deploying from a PR is dangerous since the code has not been reviewed/merged.
- **Hardcoded secrets**: Deployment tokens or API keys embedded in the workflow file.
- **No caching**: Every CI run installs all dependencies from scratch, making the pipeline slow.
- **Steps can run out of order**: Deploy runs even if tests failed because there is no `needs:` dependency or conditional.
- **No test coverage threshold**: Tests run but there is no coverage check or report upload.
- **Missing `--forceExit` on Jest**: The CI hangs because Jest does not exit after tests complete.
- **No artifact upload**: Build output is not preserved, making it impossible to inspect what was deployed.
- **Using `npm install` instead of `npm ci`**: `npm install` can modify `package-lock.json`, causing flaky builds. `npm ci` is deterministic.
- **Missing `actions/checkout`**: The workflow does not check out the repository code before running commands.
- **Deprecated action versions**: Using `actions/checkout@v2` instead of `@v4`, or `actions/setup-node@v2` instead of `@v4`.
- **No timeout on jobs**: A hung test suite can block CI indefinitely. Jobs should have `timeout-minutes` set.
