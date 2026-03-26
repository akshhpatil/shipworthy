# Architecture Specification: React SPA

## Project Identity
- **Type**: React Single-Page Application
- **Language**: TypeScript (strict mode)
- **Build Tool**: Vite
- **Runtime**: Browser

## Mandatory Rules

1. **TypeScript strict mode** -- no `any`. All props interfaces defined.
2. **Function components only** -- no class components.
3. **Co-located tests** -- `Component.test.tsx` next to `Component.tsx`.
4. **Accessible by default** -- semantic HTML, ARIA labels, keyboard navigation.
5. **No direct API calls in components** -- use custom hooks or TanStack Query.
6. **State lives close to use** -- no global state unless truly global.
7. **CSS Modules or Tailwind** -- no inline styles or global CSS.
8. **No circular imports** -- components don't import from pages.
9. **Lazy load routes** -- `React.lazy()` for route-level code splitting.
10. **Environment variables validated at startup** -- fail fast if required vars missing.

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
- **Constants**: UPPER_SNAKE_CASE
- **Test files**: `[Component].test.tsx`

## Type System
- `strict: true` in tsconfig.json
- No `any` -- use `unknown` and narrow with type guards
- Props interfaces co-located with component
- Shared types in `src/types/`
- Use discriminated unions for state machines

## Testing Strategy
- **Framework**: Vitest + React Testing Library
- **Coverage**: 80% for components with logic
- **Pattern**: Test user interactions, not implementation details
- **Mocking**: Mock API layer, not internal components
- **Accessibility**: Include a11y assertions in component tests

## Error Handling
- Use Error Boundaries (`error.tsx` or custom `ErrorBoundary` component) for unexpected runtime errors
- API errors: catch in service layer, return typed error objects
- Form validation: show inline errors, never silent failures
- Network failures: show retry UI with exponential backoff
- Never swallow errors silently -- at minimum log to error tracking service

## Security Baseline
- Sanitize all user-generated content rendered as HTML (prevent XSS)
- Use Content Security Policy headers
- No secrets in client-side code -- all secrets go through backend proxy
- Validate and sanitize URL parameters before use
- Use `httpOnly` and `secure` flags on cookies
- Audit dependencies regularly (`npm audit`)

## Performance Budgets
- Initial bundle: <200KB gzipped
- Per-route chunk: <50KB gzipped
- LCP: <2.5s
- FID: <100ms
- CLS: <0.1

## Quality Gate Levels
- Level 1 (always): Tests pass, build succeeds, no lint errors
- Level 2 (10+ files): Coverage >80%, no TODOs without tickets
- Level 3 (50+ files): Bundle size within budget, no circular imports
- Level 4 (100+ files): Accessibility audit passes, Lighthouse score >90, performance benchmarks met

## Common Mistakes
1. Forgetting `'use client'` on components that use hooks (if using Next.js/RSC patterns)
2. Not handling loading and error states for async data
3. Using `any` to bypass type errors instead of fixing them
4. Fetching data on every render -- missing dependency arrays or stale closure bugs in useEffect
5. Not memoizing expensive computations or stable callback references
6. Prop drilling instead of composition or context
7. Not cleaning up subscriptions, timers, or event listeners in useEffect
