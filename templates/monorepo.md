# Architecture Specification: Monorepo

## Project Identity
- **Type**: Monorepo (multi-package)
- **Language**: [TypeScript/Python/Mixed]
- **Build Tool**: Turborepo / Nx / Lerna / pnpm workspaces
- **Package Manager**: pnpm (preferred for monorepos)

## Mandatory Rules

1. **Package boundaries are strict** — packages only import from each other via published exports, never via relative paths.
2. **Shared types in a dedicated package** — `packages/types` or `packages/shared`.
3. **Each package has its own tests** — tests run independently per package.
4. **Consistent tooling** — same test framework, linter config, and TS config across packages.
5. **Root scripts orchestrate** — `npm run build` at root builds everything in dependency order.
6. **No circular package dependencies** — package A depends on B, B must not depend on A.
7. **Changes to shared packages require cross-package testing** — if `packages/shared` changes, all consumers must pass tests.
8. **Version together or independently** — document the strategy in this file.

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
```

## Naming Conventions
- **Packages**: `@scope/package-name` (scoped to organization)
- **Within packages**: follow the individual package type conventions

## Testing Strategy
- Each package runs tests independently
- CI runs all affected package tests on PR
- Shared packages trigger downstream tests

## Quality Gate Levels
- Level 1: Each package's tests pass independently
- Level 2: Cross-package integration tests pass
- Level 3: Build artifacts valid, bundle sizes within budget
- Level 4: E2E tests across the full application
