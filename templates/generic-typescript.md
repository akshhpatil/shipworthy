# Architecture Specification: TypeScript Project

## Project Identity
- **Type**: TypeScript application/library
- **Language**: TypeScript (strict mode)
- **Runtime**: Node.js 20+
- **Package Manager**: [npm/pnpm/yarn]

## Mandatory Rules

1. **TypeScript strict mode** — no `any` types. `strict: true` in tsconfig.json.
2. **ESM modules** — use ES module syntax with `.js` extensions in imports.
3. **Tests for all business logic** — pure functions and transformations must have tests.
4. **No circular imports** — unidirectional dependency flow.
5. **Structured error handling** — no raw string throws, use typed error classes.
6. **Environment variables validated at startup** — fail fast if missing.
7. **No `console.log` in production** — use a logging utility.

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

## Testing Strategy
- **Framework**: Vitest
- **Coverage**: 80% for business logic
- **Pattern**: Test behavior, not implementation

## Error Handling
- AppError class with code, message, context
- Catch at module boundaries, propagate otherwise

## Quality Gate Levels
- Level 1 (always): Tests pass, `tsc --noEmit` clean
- Level 2 (10+ files): Coverage >80%, no TODOs without tickets
- Level 3 (50+ files): No circular imports, all exports documented
