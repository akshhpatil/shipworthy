# Architecture Specification: TypeScript Project

## Project Identity
- **Type**: TypeScript application/library
- **Language**: TypeScript (strict mode)
- **Runtime**: Node.js 20+
- **Package Manager**: [npm/pnpm/yarn]

## Mandatory Rules

1. **TypeScript strict mode** -- no `any` types. `strict: true` in tsconfig.json.
2. **ESM modules** -- use ES module syntax with `.js` extensions in imports.
3. **Tests for all business logic** -- pure functions and transformations must have tests.
4. **No circular imports** -- unidirectional dependency flow.
5. **Structured error handling** -- no raw string throws, use typed error classes.
6. **Environment variables validated at startup** -- fail fast if missing.
7. **No `console.log` in production** -- use a logging utility.
8. **Dependencies pinned** -- exact versions in lockfile, reviewed before update.
9. **Single responsibility** -- each module has one clear purpose.
10. **No side effects in imports** -- modules should not execute logic on import.

## Directory Structure

```
src/
├── index.ts                # Entry point
├── [domain]/               # Domain modules
├── types/                  # Shared type definitions
├── utils/                  # Utility functions
└── config/                 # Configuration
tests/
├── [domain].test.ts        # Tests mirror src/ structure
```

## Naming Conventions
- **Files**: kebab-case (`user-service.ts`)
- **Variables/functions**: camelCase
- **Types/interfaces**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Test files**: `[name].test.ts`

## Type System
- `strict: true` in tsconfig.json
- No `any` -- use `unknown` and type guards to narrow
- Prefer interfaces for object shapes, type aliases for unions/intersections
- Use generics for reusable utilities
- Discriminated unions for state machines

## Testing Strategy
- **Framework**: Vitest
- **Coverage**: 80% for business logic
- **Pattern**: Test behavior, not implementation
- **Mocking**: Mock external dependencies, not internal modules

## Error Handling
- AppError class with code, message, context
- Catch at module boundaries, propagate otherwise
- Never silently swallow errors
- Use Result types for operations that can fail predictably

## Security Baseline
- Validate and sanitize all external input
- No secrets in source code -- environment variables only
- Audit dependencies regularly (`npm audit`)
- Use parameterized queries for any database access
- Sanitize log output to avoid leaking sensitive data

## Performance Budgets
- Startup time: <2s
- Hot path latency: <50ms
- Memory usage: monitor for leaks, alert on sustained growth
- Bundle size (if applicable): <500KB

## Quality Gate Levels
- Level 1 (always): Tests pass, `tsc --noEmit` clean
- Level 2 (10+ files): Coverage >80%, no TODOs without tickets
- Level 3 (50+ files): No circular imports, all exports documented
- Level 4 (100+ files): Performance benchmarks, dependency audit clean, profiling for hot paths

## Common Mistakes
1. Using `any` to silence type errors instead of fixing the root cause
2. Not handling Promise rejections (missing `.catch()` or try/catch with await)
3. Circular imports causing undefined values at runtime
4. Forgetting `.js` extensions in ESM imports
5. Using `console.log` for debugging and leaving it in production code
6. Not validating environment variables at startup (silent failures later)
7. Throwing raw strings instead of Error objects
