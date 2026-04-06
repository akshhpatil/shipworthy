# Task 05: Dashboard Page

## Prompt

> I need a dashboard that shows me how my business is doing — how many orders came in, how much money we made, and what happened recently. Something clean I can check every morning.

This prompt is given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed.

## Setup

Provide a Next.js 14 project (App Router) with API routes already implemented. The API returns user statistics data. The project has Tailwind CSS configured but no pages built yet beyond a placeholder home page.

**Directory structure before the task:**
```
dashboard-app/
  package.json
  tsconfig.json
  next.config.js
  tailwind.config.ts
  postcss.config.js
  src/
    app/
      layout.tsx
      page.tsx
      globals.css
      api/
        stats/
          route.ts
        orders/
          route.ts
        activity/
          route.ts
    lib/
      types.ts
```

**package.json** (key dependencies):
```json
{
  "name": "dashboard-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "test": "jest",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^14.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "@types/react": "^18.2.48",
    "@types/react-dom": "^18.2.18",
    "@testing-library/react": "^14.1.2",
    "@testing-library/jest-dom": "^6.2.0",
    "jest": "^29.7.0",
    "jest-environment-jsdom": "^29.7.0",
    "typescript": "^5.3.3",
    "tailwindcss": "^3.4.1",
    "postcss": "^8.4.33",
    "autoprefixer": "^10.4.17"
  }
}
```

**src/lib/types.ts**:
```typescript
export interface UserStats {
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  conversionRate: number;
}

export interface Order {
  id: string;
  userId: string;
  amount: number;
  status: 'pending' | 'completed' | 'cancelled';
  createdAt: string;
}

export interface ActivityItem {
  id: string;
  type: 'order_placed' | 'order_completed' | 'refund_issued' | 'login';
  description: string;
  timestamp: string;
}
```

**src/app/api/stats/route.ts**:
```typescript
import { NextResponse } from 'next/server';
import { UserStats } from '@/lib/types';

export async function GET() {
  const stats: UserStats = {
    totalOrders: 156,
    totalRevenue: 24532.50,
    averageOrderValue: 157.26,
    conversionRate: 3.2,
  };
  return NextResponse.json(stats);
}
```

Similar mock API routes exist for `/api/orders` (returns `Order[]`) and `/api/activity` (returns `ActivityItem[]`). All return static mock data.

Run `npm install` before handing the project to the agent. `npm run build` should succeed.

## Expected Artifacts

After the task completes, the following should exist at minimum:

- `src/app/dashboard/page.tsx` -- the dashboard page (server or client component)
- `src/components/` -- reusable UI components (e.g. `StatCard.tsx`, `OrdersTable.tsx`, `ActivityFeed.tsx`)
- Test files for at least the data display components
- The page is accessible at `/dashboard` when the dev server runs

## Scoring Criteria (20 points max)

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **TypeScript strict, no `any`** | 2 | `grep -r ': any' src/` returns 0 results (excluding `node_modules`). All component props have typed interfaces. |
| 2 | **Loading states handled** | 2 | A loading indicator (skeleton, spinner, or text) is shown while data is being fetched. Verify by checking for a loading/suspense state in the component code. |
| 3 | **Error states handled** | 2 | If an API call fails, a user-friendly error message is shown, not a blank page or uncaught exception. Verify by checking for error state handling in fetch logic. |
| 4 | **Semantic HTML** | 2 | Uses `<main>`, `<section>`, `<h1>`/`<h2>`, `<table>` (or `<ul>` for lists) appropriately. Not all `<div>` soup. |
| 5 | **Accessible** | 2 | Key elements have `aria-label` or `aria-labelledby`. Interactive elements are keyboard-navigable. Currency/number values have proper formatting. |
| 6 | **Data fetching approach** | 2 | Data is fetched using a Next.js server component with `fetch()`, or a client component with `useEffect`/SWR/React Query. Not fetched at build time with stale data. |
| 7 | **Responsive design** | 1 | Layout adjusts for mobile viewports (uses CSS grid/flexbox with responsive breakpoints). Cards stack on small screens. |
| 8 | **No prop drilling** | 1 | Data is not passed through 3+ levels of components. If deep passing is needed, context or composition is used. |
| 9 | **Types match API response** | 2 | Components use the `UserStats`, `Order`, and `ActivityItem` types from `src/lib/types.ts`. No local re-definitions that drift from the API contract. |
| 10 | **Tests for data display logic** | 2 | At least 2 test cases: one verifying that stats render correctly, one verifying that the orders list renders items. |
| 11 | **No console.log statements** | 2 | `grep -r 'console.log' src/` returns 0 results (excluding API route mock data). |

**Total: 20 points**

## Anti-Patterns to Check

- **`any` types on component props**: e.g. `function StatCard(props: any)`.
- **No loading state**: The page is blank until data arrives, then pops in.
- **No error handling**: A failed fetch results in an unhandled promise rejection or blank page.
- **All `<div>` markup**: No semantic HTML elements used at all.
- **Hardcoded data in components**: Stats are hardcoded in JSX instead of fetched from the API.
- **Console.log left in components**: Debugging statements shipped to the page.
- **Fetching in `useEffect` without cleanup**: Missing abort controller or cleanup function causes memory leaks and race conditions.
- **Currency displayed without formatting**: Showing `24532.5` instead of `$24,532.50`.
- **No test file created**: The dashboard has no tests at all.
- **Massive single-file component**: The entire dashboard (stats, orders table, activity feed) is in one 300+ line file with no component extraction.
- **Prop drilling**: `page.tsx` passes data through 3+ intermediate components to reach the display component.
- **Images without alt text**: Any `<img>` tags missing `alt` attributes.
