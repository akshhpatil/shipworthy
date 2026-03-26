# Task 07: Rate Limiting and Logging

## Prompt

> Add rate limiting to all public endpoints and structured logging throughout the application.

This prompt is given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed.

## Setup

Provide an Express+TypeScript API with several endpoints but no rate limiting and `console.log` used everywhere for logging.

**Directory structure before the task:**
```
logging-api/
  package.json
  tsconfig.json
  .env.example
  src/
    index.ts
    config.ts
    routes/
      auth.ts
      users.ts
      products.ts
    middleware/
      authenticate.ts
      errorHandler.ts
    services/
      auth.service.ts
      user.service.ts
      product.service.ts
    types/
      index.ts
  tests/
    auth.test.ts
    users.test.ts
    products.test.ts
```

**src/index.ts** (with console.log everywhere):
```typescript
import express from 'express';
import authRouter from './routes/auth';
import usersRouter from './routes/users';
import productsRouter from './routes/products';
import { errorHandler } from './middleware/errorHandler';

const app = express();
app.use(express.json());

console.log('Setting up routes...');

app.use('/auth', authRouter);
app.use('/users', usersRouter);
app.use('/products', productsRouter);

app.use(errorHandler);

const PORT = process.env.PORT || 3000;

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Server started on port ${PORT}`);
  });
}

export default app;
```

**src/services/auth.service.ts** (example of scattered console.log):
```typescript
export class AuthService {
  async register(email: string, password: string) {
    console.log('Registering user:', email);
    // ... registration logic
    console.log('User registered successfully');
    return user;
  }

  async login(email: string, password: string) {
    console.log('Login attempt for:', email);
    // ... login logic
    if (!user) {
      console.log('Login failed - user not found:', email);
      throw new Error('Invalid credentials');
    }
    console.log('Login successful for:', email);
    return { token, user };
  }
}
```

All other services follow the same pattern: `console.log` with unstructured messages at arbitrary points. No rate limiting exists on any endpoint.

Public endpoints (no auth required): `POST /auth/register`, `POST /auth/login`, `GET /products`.
Protected endpoints (auth required): `GET /users/:id`, `PUT /users/:id`, `GET /users/:id/orders`.

All existing tests pass. Run `npm install` before handing the project to the agent.

## Expected Artifacts

After the task completes, the following should exist at minimum:

- `src/middleware/rateLimiter.ts` -- rate limiting middleware configuration
- `src/lib/logger.ts` or `src/utils/logger.ts` -- structured logger setup
- All `console.log` calls replaced with logger calls
- Rate limiter applied to public routes
- A health check endpoint (`GET /health`)
- Tests for rate limiting behavior
- Updated `.env.example` with any new config vars (e.g. `RATE_LIMIT_WINDOW_MS`, `RATE_LIMIT_MAX`)

## Scoring Criteria (20 points max)

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **Rate limiter middleware on public routes** | 3 | `express-rate-limit` or equivalent is in `package.json`. Middleware is applied to `/auth/register`, `/auth/login`, and `/products`. Protected routes may have a separate, more lenient limiter or none. |
| 2 | **Structured JSON logging** | 3 | A logging library (`winston`, `pino`, or `bunyan`) is used. Log output is JSON format with at minimum `timestamp`, `level`, and `message` fields. |
| 3 | **Correlation IDs on requests** | 2 | Each incoming request is assigned a unique ID (e.g. UUID). This ID is included in all log entries for that request and returned in a response header (e.g. `X-Request-Id`). |
| 4 | **No console.log remaining** | 2 | `grep -r 'console.log\|console.error\|console.warn' src/` returns 0 results. All output goes through the structured logger. |
| 5 | **Rate limit returns 429 with Retry-After** | 2 | When the rate limit is exceeded, the response has HTTP status 429 and includes a `Retry-After` header. |
| 6 | **Log levels used correctly** | 2 | `logger.info` for normal operations, `logger.warn` for recoverable issues, `logger.error` for failures. Not all messages at the same level. |
| 7 | **Health check endpoint added** | 2 | `GET /health` returns `{ "status": "ok" }` with a 200 status. Not behind auth or rate limiting. |
| 8 | **Sensitive data not logged** | 2 | Passwords, tokens, and full user objects are NOT included in log messages. Grep for `password`, `token`, `secret` in logger calls. |
| 9 | **Tests for rate limiting** | 2 | At least 2 tests: (a) requests within the limit succeed, (b) requests exceeding the limit receive 429. |

**Total: 20 points**

## Anti-Patterns to Check

- **console.log still present**: Some `console.log` calls remain alongside the new logger.
- **Rate limiter applied globally including health check**: The health check endpoint should be exempt from rate limiting so monitoring systems can poll it.
- **No JSON format in logs**: Using `winston` but with the default text format instead of JSON, making logs unparseable by log aggregators.
- **Logging passwords or tokens**: `logger.info('User logged in', { email, password })` or `logger.info('Token generated', { token })`.
- **Rate limit too restrictive for tests**: Tests fail because the rate limiter blocks rapid sequential requests during test execution. The limiter should be configurable or disabled in test mode.
- **Same rate limit for all routes**: Login should have a stricter limit than product listing to prevent brute force.
- **No correlation ID**: Logs from a single request cannot be traced together because there is no shared request identifier.
- **Log level everything as `info`**: Errors logged as `info` level, making it impossible to filter by severity.
- **Rate limiter state shared across test suites**: If tests run in parallel, rate limit state from one test bleeds into another.
- **Health check behind authentication**: Monitoring tools cannot access the health endpoint without a token.
