# Architecture Specification: Monorepo

## Project Identity
- **Type**: Monorepo (multi-package)
- **Language**: [TypeScript/Python/Mixed]
- **Build Tool**: Turborepo / Nx / Lerna / pnpm workspaces
- **Package Manager**: pnpm (preferred for monorepos)

## Mandatory Rules

1. **Package boundaries are strict** -- packages only import from each other via published exports, never via relative paths.
2. **Shared types in a dedicated package** -- `packages/types` or `packages/shared`.
3. **Each package has its own tests** -- tests run independently per package.
4. **Consistent tooling** -- same test framework, linter config, and TS config across packages.
5. **Root scripts orchestrate** -- `npm run build` at root builds everything in dependency order.
6. **No circular package dependencies** -- package A depends on B, B must not depend on A.
7. **Changes to shared packages require cross-package testing** -- if `packages/shared` changes, all consumers must pass tests.
8. **Version together or independently** -- document the strategy in this file.
9. **Each package has a README** -- purpose, API surface, and usage examples documented.
10. **Dependency hoisting controlled** -- shared dependencies at root, package-specific at package level.

## Directory Structure

```
packages/
├── [app-name]/             # Application packages
│   ├── src/
│   ├── tests/
│   ├── package.json
│   └── tsconfig.json
├── [lib-name]/             # Library packages
│   ├── src/
│   ├── tests/
│   ├── package.json
│   └── tsconfig.json
└── shared/                 # Shared types, utils, config
    ├── src/
    └── package.json
turbo.json / nx.json        # Build orchestration config
package.json                # Root workspace config
tsconfig.base.json          # Shared TS config
.github/workflows/          # CI configuration
```

## Naming Conventions
- **Packages**: `@scope/package-name` (scoped to organization)
- **Package directories**: kebab-case (`user-service`, `shared-utils`)
- **Within TypeScript packages**: follow TypeScript naming (PascalCase components, camelCase functions)
- **Within Python packages**: follow Python naming (snake_case modules)
- **Config files**: dot-prefixed at root (`.eslintrc`, `.prettierrc`)
- **Shared configs**: `packages/config-*` for shared ESLint, TSConfig, etc.

## Type System
- Shared types live in a dedicated `packages/types` or `packages/shared` package
- Each package re-exports only its public API types
- Use TypeScript project references for cross-package type checking
- `tsconfig.base.json` at root with strict settings inherited by all packages

## Testing Strategy
- Each package runs tests independently
- CI runs all affected package tests on PR
- Shared packages trigger downstream tests
- **Framework**: consistent across packages (Vitest or Jest)
- **Coverage**: 80% per package
- **Integration tests**: separate package or top-level `tests/` directory
- **E2E tests**: dedicated package (e.g., `packages/e2e`)

## Error Handling
- Each package defines its own error types extending a shared base error
- Errors cross package boundaries as typed objects, never raw strings
- Shared error codes in `packages/shared/errors`
- Logging strategy consistent across packages (shared logger config)
- Unhandled rejections caught at application entry points

## Security Baseline
- Run `npm audit` / `pnpm audit` on all packages in CI
- Shared authentication/authorization logic in a dedicated package
- No secrets in any package -- environment variables only
- Dependency updates reviewed at package level (Renovate or Dependabot)
- Lock file committed and integrity-checked in CI

## Performance Budgets
- Build time (full): <5 minutes with cache, <15 minutes cold
- Individual package build: <60 seconds
- Bundle size per application package: defined per app (see app-specific spec)
- Test suite per package: <2 minutes
- CI pipeline total: <10 minutes with parallelization

## Quality Gate Levels
- Level 1 (always): Each package's tests pass independently, build succeeds
- Level 2 (5+ packages): Coverage >80% per package, no circular package dependencies
- Level 3 (10+ packages): Cross-package integration tests pass, build artifacts valid, bundle sizes within budget
- Level 4 (20+ packages): E2E tests across the full application, dependency audit clean, build cache hit rate >80%

## Common Mistakes
1. Importing from another package via relative path (`../../packages/foo`) instead of scoped import (`@scope/foo`)
2. Not running affected package tests when modifying shared packages
3. Circular dependencies between packages (A imports B, B imports A)
4. Inconsistent tooling versions across packages (different ESLint or TS versions)
5. Not using workspace protocol (`workspace:*`) for internal dependencies
6. Forgetting to update `exports` field in package.json when adding new public APIs
7. Build ordering issues -- not declaring dependencies correctly in turbo.json/nx.json
8. Hoisting dependencies that should be package-local (causes phantom dependency issues)
