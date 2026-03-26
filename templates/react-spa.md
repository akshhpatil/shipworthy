# Architecture Specification: React SPA

## Project Identity
- **Type**: React Single-Page Application
- **Language**: TypeScript (strict mode)
- **Build Tool**: Vite
- **Runtime**: Browser

## Mandatory Rules

1. **TypeScript strict mode** — no `any`. All props interfaces defined.
2. **Function components only** — no class components.
3. **Co-located tests** — `Component.test.tsx` next to `Component.tsx`.
4. **Accessible by default** — semantic HTML, ARIA labels, keyboard navigation.
5. **No direct API calls in components** — use custom hooks or TanStack Query.
6. **State lives close to use** — no global state unless truly global.
7. **CSS Modules or Tailwind** — no inline styles or global CSS.
8. **No circular imports** — components don't import from pages.
9. **Lazy load routes** — `React.lazy()` for route-level code splitting.

## Directory Structure

```
src/
├── main.tsx                # Entry point
├── App.tsx                 # Root component with router
├── pages/                  # Route-level components
├── components/             # Reusable components
│   ├── ui/                 # Base primitives
│   └── [feature]/          # Feature-specific
├── hooks/                  # Custom hooks
├── services/               # API client functions
├── types/                  # Shared types
├── utils/                  # Utility functions
└── assets/                 # Static assets
```

## Naming Conventions
- **Components**: PascalCase (`UserProfile.tsx`)
- **Hooks**: camelCase with `use` prefix (`useAuth.ts`)
- **Utils**: camelCase (`formatDate.ts`)
- **Types**: PascalCase

## Testing Strategy
- **Framework**: Vitest + React Testing Library
- **Coverage**: 70% for components with logic
- **Pattern**: Test user interactions, not implementation details

## Performance Budgets
- Initial bundle: <200KB gzipped
- Per-route chunk: <50KB gzipped
- LCP: <2.5s
