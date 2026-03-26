# Founder Test 06: Full SaaS Application — Realistic Founder Brief

## Persona
Non-technical startup founder who has a clear product vision but no engineering knowledge. They describe their app the way they'd describe it to a freelance developer they hired.

## Prompt

> I'm building a SaaS app called "InvoiceFlow" — it's an invoicing tool for freelancers and small agencies.
>
> Here's what I need:
>
> **User accounts:**
> - Freelancers sign up with email and password
> - They can update their profile (name, business name, address, logo)
> - They should stay logged in between visits
>
> **Clients:**
> - Users can add their clients (name, email, company, address)
> - Users can see a list of all their clients
> - Users can edit or delete a client
>
> **Invoices:**
> - Users can create an invoice for a client
> - Each invoice has line items (description, quantity, rate)
> - The total is calculated automatically
> - Invoice has a status: draft, sent, paid, overdue
> - Users can mark an invoice as sent or paid
> - Users should see a list of all their invoices with filters (by status, by client)
>
> **Dashboard:**
> - Show total revenue (sum of paid invoices)
> - Show outstanding amount (sum of sent invoices)
> - Show overdue count
> - Show recent invoices
>
> **Important:**
> - A user should ONLY see their own clients and invoices, never another user's data
> - The app should work well on mobile since freelancers use phones a lot
> - I want it to look clean and professional, not like a homework project
>
> Use Next.js with TypeScript. Start with the backend API first, then we'll do the frontend.

## Setup

Empty Next.js + TypeScript project with package.json and tsconfig.json only.

## What Production-Grade Looks Like (Founder Would Never Ask For These)

### Data Layer
1. **Proper database** — SQLite/PostgreSQL, not in-memory arrays
2. **Schema with relations** — users → clients → invoices → line_items
3. **Foreign key constraints** — can't create invoice for non-existent client
4. **Cascade deletes** — deleting a client handles their invoices
5. **Indexes** — on user_id columns for fast queries
6. **Timestamps** — created_at, updated_at on all tables

### Security
7. **Password hashing** — bcrypt, not plaintext
8. **Authorization on EVERY endpoint** — user can only see their own data (IDOR prevention)
9. **Input validation** — email format, required fields, numeric validation on amounts
10. **No secrets in code** — JWT/session secret from env
11. **Safe error messages** — no internal details leaked

### API Design
12. **Consistent REST patterns** — /api/clients, /api/invoices
13. **Proper status codes** — 201 for create, 404 for not found, 403 for unauthorized
14. **Pagination** on list endpoints
15. **Filtering** on invoices (by status, by client)

### Code Quality
16. **TypeScript types** for all entities (User, Client, Invoice, LineItem)
17. **No `any` types**
18. **Tests** for at least: auth, CRUD operations, authorization checks
19. **Separation of concerns** — routes, services/logic, data access
20. **Error handling** — structured errors, not raw catches

### Calculation Correctness
21. **Line item totals** — quantity * rate
22. **Invoice total** — sum of line item totals
23. **Dashboard aggregations** — correct sums, not double-counting

## Scoring (30 points — larger task gets more points)

| Check | Points | What We're Looking For |
|-------|--------|----------------------|
| Database used (not in-memory) | 3 | SQLite, PostgreSQL, or proper DB |
| Schema with proper relations | 3 | Foreign keys between users→clients→invoices→line_items |
| Password hashing | 2 | bcrypt/argon2 |
| Authorization (IDOR prevention) | 3 | Every query filters by userId — user can't see others' data |
| Input validation | 2 | Required fields, email format, numeric amounts |
| TypeScript types defined | 2 | Interfaces for User, Client, Invoice, LineItem |
| Tests exist and pass | 3 | At least 5 meaningful tests |
| REST conventions followed | 2 | Consistent /api/ routes, proper HTTP methods |
| Proper status codes | 2 | 201, 400, 401, 403, 404 used correctly |
| Line item math correct | 2 | quantity * rate calculated |
| Invoice total calculated | 2 | Sum of line items |
| Secrets from env vars | 1 | JWT_SECRET or equivalent |
| Build compiles | 1 | tsc passes |
| No any types | 1 | Zero any in source files |
| Separation of concerns | 1 | Not everything in one file |

## Anti-Patterns (A Founder Would Ship These Without Knowing)
- In-memory data storage (lost on restart)
- User A can see User B's invoices (missing authorization)
- Hardcoded JWT secret
- No validation (can create invoice with negative amounts)
- Invoice total not calculated (relies on client to send total)
- No tests (regression bugs on every change)
- Passwords stored in plain text
- All logic in route handlers (untestable, unmaintainable)
