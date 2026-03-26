# Task 04: Fix Security Bug

## Prompt

> Users are reporting they can see other users' data. Fix this security issue.

This prompt is given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed.

## Setup

Provide an Express+TypeScript API with a broken authorization model. The `GET /users/:id` endpoint returns any user's profile data regardless of who is making the request. Authentication exists (JWT-based), but no authorization check is performed.

**Directory structure before the task:**
```
secure-api/
  package.json
  tsconfig.json
  .env.example
  src/
    index.ts
    config.ts
    routes/
      users.ts
      auth.ts
    middleware/
      authenticate.ts
      errorHandler.ts
    models/
      user.ts
    services/
      user.service.ts
    types/
      index.ts
  tests/
    users.test.ts
    auth.test.ts
```

**src/routes/users.ts** (the buggy file):
```typescript
import { Router } from 'express';
import { authenticate } from '../middleware/authenticate';
import { UserService } from '../services/user.service';

const router = Router();
const userService = new UserService();

// BUG: No authorization check -- any authenticated user can fetch any other user's data
router.get('/:id', authenticate, (req, res) => {
  const user = userService.findById(req.params.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  // Returns full user object including email, address, phone -- no field filtering
  const { password, ...userData } = user;
  res.json(userData);
});

router.get('/:id/orders', authenticate, (req, res) => {
  const orders = userService.getOrdersByUserId(req.params.id);
  res.json(orders);
});

router.put('/:id', authenticate, (req, res) => {
  const updated = userService.updateUser(req.params.id, req.body);
  res.json(updated);
});

export default router;
```

**src/middleware/authenticate.ts**:
```typescript
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';

export interface AuthRequest extends Request {
  user?: { id: string; email: string };
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  try {
    const decoded = jwt.verify(token, config.jwtSecret) as { id: string; email: string };
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid token' });
  }
};
```

**tests/users.test.ts** (existing tests that must continue to pass):
```typescript
import request from 'supertest';
import app from '../src/index';
import { generateToken } from './helpers';

describe('GET /users/:id', () => {
  it('returns 401 without auth token', async () => {
    const res = await request(app).get('/users/user-1');
    expect(res.status).toBe(401);
  });

  it('returns user data with valid token', async () => {
    const token = generateToken({ id: 'user-1', email: 'user1@test.com' });
    const res = await request(app)
      .get('/users/user-1')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.email).toBe('user1@test.com');
  });

  it('does not return password field', async () => {
    const token = generateToken({ id: 'user-1', email: 'user1@test.com' });
    const res = await request(app)
      .get('/users/user-1')
      .set('Authorization', `Bearer ${token}`);
    expect(res.body.password).toBeUndefined();
  });
});
```

All existing tests pass before the task begins. The in-memory user store is seeded with at least 3 users.

## Expected Artifacts

After the task completes:

- `src/routes/users.ts` updated with authorization checks
- Possibly a new `src/middleware/authorize.ts` for reusable authorization logic
- New or updated tests verifying the authorization fix
- No changes to `src/middleware/authenticate.ts` that break existing auth
- Existing tests still pass

## Scoring Criteria (20 points max)

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **Authorization check added** | 3 | `GET /users/:id` now compares `req.user.id` with `req.params.id`. A user can only access their own data unless they have an admin role. |
| 2 | **Tests for authorization** | 3 | At least 2 new test cases: (a) user A cannot access user B's data, (b) user A can access their own data. |
| 3 | **No regression in existing tests** | 2 | Run `npm test`. All pre-existing tests in `users.test.ts` and `auth.test.ts` still pass. |
| 4 | **Root cause identified, not just symptom fixed** | 2 | The fix addresses all three endpoints (`GET /:id`, `GET /:id/orders`, `PUT /:id`), not just one. If only one endpoint is fixed, award 0 points. |
| 5 | **Proper 403 response** | 2 | Unauthorized access returns HTTP 403 (Forbidden), not 401 (Unauthorized) or 404 (Not Found). The response body explains the denial without leaking info. |
| 6 | **Audit logging of access attempts** | 2 | Failed authorization attempts are logged with the requesting user ID, the target resource, and a timestamp. |
| 7 | **Does not break existing functionality** | 3 | Users can still access their own profile, their own orders, and update their own data. The health endpoint still works. |
| 8 | **Fix is minimal and focused** | 3 | The diff is small and targeted. No unrelated refactoring, no rewriting of files that were not involved in the bug. |

**Total: 20 points**

## Anti-Patterns to Check

- **Only one endpoint fixed**: Fixing `GET /:id` but leaving `GET /:id/orders` and `PUT /:id` wide open.
- **Using 404 to hide resources**: Returning "User not found" for unauthorized access is security through obscurity and makes debugging harder.
- **Using 401 instead of 403**: 401 means "not authenticated." 403 means "authenticated but not authorized." Conflating them causes confusion.
- **Overly broad fix**: Removing the `GET /users/:id` endpoint entirely instead of adding authorization.
- **Authorization logic copy-pasted**: The same `if (req.user.id !== req.params.id)` check duplicated in every handler instead of extracted as middleware.
- **Breaking the user's ability to read their own data**: The fix is so restrictive that legitimate access is denied.
- **No tests added**: The fix is applied but there are no tests proving it works.
- **Logging sensitive data**: Audit logs include passwords, tokens, or full user objects.
- **Modifying unrelated files**: Touching auth middleware, health routes, or config files that have nothing to do with the bug.
- **Admin role added without being asked**: Creating an admin system when the prompt only asked to fix a bug. Complexity creep.
