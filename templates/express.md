# Architecture Specification: Express API Service

## Project Identity
- **Type**: Express REST API service
- **Language**: TypeScript (strict mode)
- **Runtime**: Node.js 20+
- **Primary Framework**: Express 4/5
- **Package Manager**: [npm/pnpm]

## Mandatory Rules

1. **Never break existing endpoints** — read entire route files before modifying. Verify all callers when changing response shapes.
2. **TypeScript strict mode** — no `any` types. All request/response types defined.
3. **Input validation on every endpoint** — use Zod schemas for body, query, and params.
4. **Standardized error handling** — all routes use the error middleware, never send raw errors.
5. **Authentication middleware on protected routes** — never rely on client-side auth alone.
6. **ESM imports with `.js` extensions** — required for Node.js ES modules.
7. **Pure business logic** — scoring/calculation functions must be pure with no side effects.
8. **No circular imports** — services don't import from routes, routes don't import from middleware.
9. **Tests required for routes and services** — every endpoint and business function must have tests.
10. **Environment variables validated at startup** — crash immediately if required vars missing.

## Directory Structure

```
src/
├── index.ts                # Server entry point
├── routes/                 # Express route handlers
│   └── [resource].ts       # One file per resource (users.ts, orders.ts)
├── services/               # Business logic
│   └── [domain].ts         # Domain services (user-service.ts)
├── middleware/              # Express middleware
│   ├── auth.ts             # Authentication
│   ├── validate.ts         # Request validation
│   └── error-handler.ts    # Centralized error handling
├── types/                  # Shared TypeScript types
├── data/                   # Database access layer
│   ├── models/             # Schema definitions
│   └── migrations/         # Database migrations
├── utils/                  # Utility functions
└── config/                 # Configuration management
    └── env.ts              # Environment variable validation
```

## Naming Conventions
- **Files**: kebab-case (`user-service.ts`, `auth-middleware.ts`)
- **Variables/functions**: camelCase
- **Types/interfaces**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Routes**: plural nouns (`/users`, `/orders`)

## Testing Strategy
- **Framework**: Vitest or Jest + Supertest
- **Location**: `tests/` mirroring `src/` structure
- **Coverage**: 80% for services, all routes tested via HTTP
- **Pattern**: Integration tests for routes, unit tests for services

## Error Handling
- Centralized error middleware catches all errors
- AppError class with code, message, statusCode, context
- Routes throw AppError, middleware formats the response
- Never send stack traces to clients

## Security Baseline
- `helmet()` for security headers
- `express-rate-limit` on all public endpoints
- CORS with explicit origins
- Input validation via Zod middleware
- Parameterized database queries only

## Performance Budgets
- API response (p95): <200ms reads, <500ms writes
- Database queries per request: <10
- Payload size: <1MB per response

## Type System
- `strict: true` in tsconfig.json
- No `any` -- use `unknown` and type guards
- Request/response types defined for every endpoint
- Zod schemas for runtime validation, infer TypeScript types from schemas

## Quality Gate Levels
- Level 1 (always): Tests pass, build succeeds, no lint errors
- Level 2 (10+ files): Coverage >80%, no hardcoded secrets
- Level 3 (50+ files): No circular imports, API docs synchronized
- Level 4 (100+ files): Load testing, security scan clean, dependency audit passes

## Common Mistakes
1. Not using centralized error handling -- catching errors in individual routes
2. Sending raw error objects to clients (leaking stack traces and internals)
3. Missing input validation on endpoints (trusting client data)
4. Not using async error handling middleware (unhandled promise rejections crash the server)
5. Hardcoding CORS origins instead of using environment configuration
6. Missing rate limiting on public endpoints
7. Not closing database connections properly on shutdown
