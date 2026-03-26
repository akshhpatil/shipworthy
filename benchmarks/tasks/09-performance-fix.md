# Task 09: Performance Fix

## Prompt

> The API is slow. The GET /orders endpoint takes 5+ seconds. Investigate and fix the performance issue.

This prompt is given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed.

## Setup

Provide an Express+TypeScript API with a deliberate N+1 query problem and missing database indexes. The `GET /orders` endpoint fetches all orders, then for each order makes a separate query to fetch the user and the product.

**Directory structure before the task:**
```
perf-api/
  package.json
  tsconfig.json
  .env.example
  docker-compose.yml
  src/
    index.ts
    config.ts
    db.ts
    routes/
      orders.ts
      users.ts
      products.ts
    services/
      order.service.ts
      user.service.ts
      product.service.ts
    types/
      index.ts
  tests/
    orders.test.ts
    users.test.ts
  scripts/
    schema.sql
    seed.sql
```

**src/services/order.service.ts** (the problematic file):
```typescript
import { query } from '../db';

export class OrderService {
  async findAll() {
    // Step 1: Get all orders
    const ordersResult = await query('SELECT * FROM orders');
    const orders = ordersResult.rows;

    // Step 2: N+1 problem -- for each order, fetch user and product separately
    const enrichedOrders = [];
    for (const order of orders) {
      const userResult = await query('SELECT id, name, email FROM users WHERE id = $1', [order.user_id]);
      const productResult = await query('SELECT id, name, price FROM products WHERE id = $1', [order.product_id]);

      enrichedOrders.push({
        ...order,
        user: userResult.rows[0],
        product: productResult.rows[0],
      });
    }

    return enrichedOrders;
  }

  async findByUserId(userId: string) {
    // Same N+1 pattern for user-specific orders
    const ordersResult = await query('SELECT * FROM orders WHERE user_id = $1', [userId]);
    const orders = ordersResult.rows;

    const enrichedOrders = [];
    for (const order of orders) {
      const productResult = await query('SELECT id, name, price FROM products WHERE id = $1', [order.product_id]);
      enrichedOrders.push({
        ...order,
        product: productResult.rows[0],
      });
    }

    return enrichedOrders;
  }

  async findById(id: string) {
    const result = await query('SELECT * FROM orders WHERE id = $1', [id]);
    return result.rows[0] || null;
  }
}
```

**scripts/schema.sql** (note: NO indexes defined):
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  product_id UUID NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  total_amount INTEGER NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);
-- NOTE: No indexes on orders.user_id, orders.product_id, or orders.status
```

**scripts/seed.sql**: Seeds the database with 50 users, 100 products, and 1000 orders. This is enough data that the N+1 problem is clearly visible (each request generates 2001 queries: 1 for orders + 1000 user lookups + 1000 product lookups).

Run `docker-compose up -d` and `npm install` before handing the project to the agent. Seed the database. The `GET /orders` endpoint should take 3-5+ seconds to respond, demonstrating the problem.

## Expected Artifacts

After the task completes:

- `src/services/order.service.ts` refactored to eliminate N+1 queries
- Index migration or SQL file adding appropriate indexes
- Optionally pagination support on the endpoint
- All existing tests still pass
- Measurably faster response time

## Scoring Criteria (20 points max)

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **Root cause identified (N+1)** | 3 | The agent explicitly identifies the N+1 query problem in its explanation or code comments. The loop-per-row pattern is eliminated. |
| 2 | **Fix uses JOIN or eager loading** | 3 | The `findAll` method now uses a SQL `JOIN` (e.g. `SELECT orders.*, users.name ... FROM orders JOIN users ON ...`) or an ORM eager loading mechanism instead of per-row queries. |
| 3 | **Index added** | 2 | At least `CREATE INDEX ON orders(user_id)` and `CREATE INDEX ON orders(product_id)` are added. Verify with `\di` in psql or a migration file. |
| 4 | **Pagination added** | 2 | The endpoint accepts `?page=1&limit=20` (or `?offset=0&limit=20`) query parameters. The SQL uses `LIMIT` and `OFFSET`. A default limit is set. |
| 5 | **Performance test or benchmark** | 2 | A script, test, or documentation shows before/after response times. Even a comment like "Reduced from 2001 queries to 1 query" counts. |
| 6 | **No regression in existing tests** | 2 | Run `npm test`. All pre-existing tests still pass. |
| 7 | **Before/after metrics documented** | 2 | The agent notes the query count reduction (e.g. "from 2001 queries to 1") or response time improvement. |
| 8 | **Query count reduced** | 2 | The total number of SQL queries for `GET /orders` is reduced from O(n) to O(1) or O(constant). Verify by counting `query()` calls or adding query logging. |
| 9 | **Caching considered** | 2 | The agent at least discusses caching (Redis, in-memory) for frequently accessed data, even if it decides not to implement it. Or a simple cache is added. |

**Total: 20 points**

## Anti-Patterns to Check

- **N+1 still present**: The loop-per-row pattern remains, just made slightly faster (e.g. with `Promise.all` but still N queries).
- **`Promise.all` used as the fix**: Running all N queries in parallel is faster but still makes N queries. It does not fix the root cause and will not scale.
- **No indexes added**: The JOIN is correct but performance will still degrade at scale without indexes on the foreign key columns.
- **No pagination**: Returning all 1000+ orders in a single response. This works in dev but is a production problem.
- **`SELECT *` retained**: The query still selects all columns including potentially large text fields, even when only a few fields are needed.
- **Breaking the response format**: The API response shape changes (e.g. user/product data no longer nested), breaking existing clients.
- **Existing tests broken**: The fix changes the service method signatures or response shape, causing test failures.
- **No explanation of the root cause**: The code is changed but no comment or documentation explains what was wrong or why the fix works.
- **Over-engineering**: Adding Redis, a query builder library, and a caching layer when a simple JOIN solves the problem.
- **Hardcoded pagination defaults**: `LIMIT 1000000` instead of a reasonable default like 20 or 50.
- **Missing total count for pagination**: Pagination returns a page of results but no way for the client to know how many total pages exist.
