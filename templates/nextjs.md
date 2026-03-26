# Architecture Specification: Next.js Application

## Project Identity
- **Type**: Next.js App Router application
- **Language**: TypeScript (strict mode)
- **Runtime**: Node.js 20+
- **Primary Framework**: Next.js 14/15
- **Package Manager**: [npm/pnpm/yarn]

## Mandatory Rules

1. **Never break existing features** — read entire files before modifying. Verify all callers when changing function signatures.
2. **Server components by default** — only add `'use client'` when the component needs useState, useEffect, event handlers, or browser APIs.
3. **TypeScript strict mode** — no `any` types. All function parameters and return types must be typed.
4. **Co-located types** — shared types in `src/types/`. Component-specific types in the component file.
5. **API routes validate input** — use Zod schemas for all request body and query parameter validation.
6. **Error boundaries on every route** — each route segment should have an `error.tsx`.
7. **No `console.log` in production code** — use structured logging utilities.
8. **Tests required for business logic** — pure functions, API routes, and data transformations must have tests.
9. **No circular imports** — unidirectional dependency flow. Lower modules don't import from higher modules.
10. **Environment variables validated at startup** — fail fast if required variables are missing.

## Directory Structure

```
src/
├── app/                    # Next.js App Router pages and layouts
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Home page
│   ├── error.tsx           # Root error boundary
│   ├── loading.tsx         # Root loading state
│   └── [feature]/          # Feature route segments
│       ├── page.tsx
│       ├── layout.tsx
│       ├── error.tsx
│       └── loading.tsx
├── components/             # Reusable UI components
│   ├── ui/                 # Base UI primitives
│   └── [feature]/          # Feature-specific components
├── lib/                    # Utility functions and shared logic
├── services/               # External API/service integrations
├── types/                  # Shared TypeScript types
├── hooks/                  # Custom React hooks
└── data/                   # Constants, seed data, configuration
```

## Naming Conventions
- **Files**: kebab-case for utilities (`date-utils.ts`), PascalCase for components (`UserProfile.tsx`)
- **Variables/functions**: camelCase
- **Types/interfaces**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Test files**: `[name].test.ts` or `[name].test.tsx`

## Testing Strategy
- **Framework**: Vitest + React Testing Library
- **Location**: Co-located (`src/lib/utils.test.ts`) or `__tests__/`
- **Coverage**: 70% for business logic, API routes tested E2E
- **Pattern**: Test behavior, not implementation

## Error Handling
- API routes: try/catch with structured AppError, return consistent JSON error format
- Client components: Error boundaries (`error.tsx`) per route segment
- Server actions: return `{ success: boolean, error?: string }` pattern

## Security Baseline
- Zod validation on all API route inputs
- CSRF protection on mutations
- Auth middleware on protected routes
- No secrets in client-side code
- CSP headers via `next.config.ts`

## Performance Budgets
- Initial JS bundle: <250KB gzipped
- Per-route chunk: <50KB gzipped
- LCP: <2.5s
- API response (p95): <200ms

## Quality Gate Levels
- Level 1 (always): Tests pass, build succeeds, no lint errors
- Level 2 (10+ files): Coverage >70%, no TODOs without tickets
- Level 3 (50+ files): Bundle size within budget, no circular imports
- Level 4 (100+ files): Accessibility audit, performance benchmarks

## Common Mistakes
1. Forgetting `'use client'` on components that use hooks
2. Importing server-only code into client components
3. Not handling loading and error states for async routes
4. Using `any` to bypass type errors instead of fixing them
5. Fetching data in client components when server components would work
6. Missing `key` prop on mapped elements
7. Not validating environment variables at startup
