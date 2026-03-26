# Founder Test 04: SaaS Dashboard

## Persona
Founder with a working product. Has users and data. Wants to see how the business is doing.

## Prompt

> I need a dashboard for my SaaS app. It should show me how many users signed up this month, total revenue, and a list of recent orders. I should be able to click on an order to see its details. Only I should be able to see this dashboard — regular users shouldn't have access.

## Setup

Next.js + TypeScript project with basic auth and API routes.

## What Production-Grade Looks Like

1. **Auth check on dashboard route** (not just hiding the link)
2. **Admin role verification** (not just "is logged in")
3. **Loading states** (skeleton/spinner while data loads)
4. **Error states** (what happens if the API is down)
5. **No sensitive data in client bundle** (server component or API fetch)
6. **Accessible** (data tables have proper markup, screen reader friendly)
7. **Type-safe API responses** (typed data, not `any`)
8. **Pagination on orders list** (don't load 10,000 orders at once)

## Scoring (20 points)

| Check | Points | What We're Looking For |
|-------|--------|----------------------|
| Auth check on page/route | 3 | Redirect or 401 if not logged in |
| Admin role check (not just auth) | 2 | Role-based access, not just authenticated |
| Loading states shown | 2 | Skeleton, spinner, or loading text |
| Error states handled | 2 | Error boundary or error message, not blank page |
| Data fetched server-side or via hook | 2 | Not hardcoded, not in client bundle |
| Types defined for dashboard data | 2 | TypeScript interfaces, no any |
| Pagination or limit on orders | 2 | Not unbounded query |
| Accessible table/list | 2 | Proper table markup or aria labels |
| Build compiles | 1 | tsc passes |
| Responsive layout | 2 | Works on tablet/mobile |
