# Task 02: Authentication

## Prompt

> Add JWT authentication to this Express API. Users should be able to register, login, and access protected routes. Store passwords securely.

This prompt is given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed.

## Setup

Provide a starter Express+TypeScript project with a working `/health` endpoint.

**Directory structure before the task:**
```
auth-api/
  package.json
  tsconfig.json
  src/
    index.ts
    routes/
      health.ts
  tests/
    health.test.ts
```

**package.json**
```json
{
  "name": "auth-api",
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
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**src/index.ts**
```typescript
import express from 'express';
import healthRouter from './routes/health';

const app = express();
app.use(express.json());
app.use('/health', healthRouter);

const PORT = process.env.PORT || 3000;

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

export default app;
```

**src/routes/health.ts**
```typescript
import { Router } from 'express';

const router = Router();

router.get('/', (_req, res) => {
  res.json({ status: 'ok' });
});

export default router;
```

**tests/health.test.ts**
```typescript
import request from 'supertest';
import app from '../src/index';

describe('GET /health', () => {
  it('returns status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});
```

Run `npm install` before handing the project to the agent. The health test must pass before the task begins.

## Expected Artifacts

After the task completes, the following should exist at minimum:

- `src/routes/auth.ts` -- register and login endpoints
- `src/middleware/auth.ts` or `src/middleware/authenticate.ts` -- JWT verification middleware
- `src/models/user.ts` or `src/types/user.ts` -- User type definitions
- Updated `src/index.ts` wiring in auth routes
- At least one protected route demonstrating the middleware
- Test files covering registration, login, and protected route access
- `.env.example` showing required environment variables (e.g. `JWT_SECRET`)

## Scoring Criteria (20 points max)

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **Passwords hashed with bcrypt or argon2** | 3 | `package.json` includes `bcrypt`, `bcryptjs`, or `argon2`. Grep for `hash` and `compare` calls. MD5/SHA-256 alone = 0 points. |
| 2 | **JWT with expiry** | 2 | `jwt.sign()` call includes `expiresIn` option. Token without expiry = 0 points. |
| 3 | **Protected route middleware** | 2 | A middleware function extracts and verifies the JWT from the `Authorization` header. Applied to at least one route. |
| 4 | **Tests for auth flows** | 3 | At least 4 test cases: register success, register duplicate, login success, login wrong password, protected route without token. |
| 5 | **No secrets hardcoded** | 2 | `JWT_SECRET` comes from `process.env`. No string literals like `"mysecret"` used as the signing key in production code. Test files may use a test secret. |
| 6 | **Rate limiting on login endpoint** | 2 | A rate limiter (e.g. `express-rate-limit`) is applied to `POST /auth/login` or all auth routes. |
| 7 | **Input validation on register/login** | 2 | Email format and password length/complexity validated using a library or thorough manual checks. |
| 8 | **Proper error messages, no stack traces** | 2 | Error responses in production do not include `err.stack` or raw exception messages. A generic "Internal server error" is returned for unhandled errors. |
| 9 | **Refresh token pattern** | 2 | A refresh token endpoint exists, or the architecture clearly separates short-lived access tokens from longer-lived refresh tokens. |

**Total: 20 points** (one point of slack built in for partial credit scenarios)

## Anti-Patterns to Check

- **Passwords stored in plain text**: The user password is saved directly without hashing.
- **MD5 or SHA-256 used for passwords**: These are fast hashes, not password hashes. They are trivially brute-forced.
- **JWT secret hardcoded in source**: e.g. `jwt.sign(payload, "supersecret")`.
- **No token expiry**: JWTs that never expire are a security risk.
- **Stack traces in error responses**: `res.json({ error: err.stack })` leaks internals.
- **No input validation**: Register accepts `{ email: "", password: "1" }` without complaint.
- **Health test broken**: The pre-existing `health.test.ts` no longer passes after changes.
- **Middleware not reusable**: Auth check is copy-pasted into each route handler instead of extracted as middleware.
- **Synchronous bcrypt**: Using `bcrypt.hashSync` / `bcrypt.compareSync` instead of async versions (blocks the event loop).
- **No `.env.example`**: Team members have no idea what environment variables are needed.
