# Task 06: Database Refactor

## Prompt

> Refactor the raw SQL queries to use Prisma ORM. Create proper migrations. Don't break existing functionality.

This prompt is given identically for both the **with-plugin** and **without-plugin** runs. No additional guidance or follow-up prompts are allowed.

## Setup

Provide an Express+TypeScript API that uses raw `pg` (node-postgres) queries for all database operations. The database has three tables: `users`, `orders`, and `products`. There are foreign key relationships between them.

**Directory structure before the task:**
```
db-refactor-api/
  package.json
  tsconfig.json
  .env.example
  docker-compose.yml
  src/
    index.ts
    config.ts
    db.ts
    routes/
      users.ts
      orders.ts
      products.ts
    services/
      user.service.ts
      order.service.ts
      product.service.ts
    types/
      index.ts
  tests/
    users.test.ts
    orders.test.ts
    products.test.ts
  scripts/
    seed.sql
    schema.sql
```

**src/db.ts** (current database connection):
```typescript
import { Pool } from 'pg';
import { config } from './config';

export const pool = new Pool({
  connectionString: config.databaseUrl,
});

export async function query(text: string, params?: unknown[]) {
  const result = await pool.query(text, params);
  return result;
}
```

**src/services/user.service.ts** (example raw SQL usage):
```typescript
import { query } from '../db';

export class UserService {
  async findAll() {
    const result = await query('SELECT * FROM users ORDER BY created_at DESC');
    return result.rows;
  }

  async findById(id: string) {
    const result = await query('SELECT * FROM users WHERE id = $1', [id]);
    return result.rows[0] || null;
  }

  async create(email: string, name: string, passwordHash: string) {
    const result = await query(
      'INSERT INTO users (email, name, password_hash) VALUES ($1, $2, $3) RETURNING *',
      [email, name, passwordHash]
    );
    return result.rows[0];
  }

  async update(id: string, data: { name?: string; email?: string }) {
    const fields: string[] = [];
    const values: unknown[] = [];
    let paramIndex = 1;

    if (data.name) {
      fields.push(`name = $${paramIndex++}`);
      values.push(data.name);
    }
    if (data.email) {
      fields.push(`email = $${paramIndex++}`);
      values.push(data.email);
    }

    values.push(id);
    const result = await query(
      `UPDATE users SET ${fields.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
      values
    );
    return result.rows[0];
  }

  async delete(id: string) {
    await query('DELETE FROM users WHERE id = $1', [id]);
  }
}
```

**scripts/schema.sql**:
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price INTEGER NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  total_amount INTEGER NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_users_email ON users(email);
```

**scripts/seed.sql**:
```sql
INSERT INTO users (id, email, name, password_hash) VALUES
  ('a1b2c3d4-0000-0000-0000-000000000001', 'alice@test.com', 'Alice', '$2b$10$...'),
  ('a1b2c3d4-0000-0000-0000-000000000002', 'bob@test.com', 'Bob', '$2b$10$...');

INSERT INTO products (id, name, description, price, stock) VALUES
  ('p1p2p3p4-0000-0000-0000-000000000001', 'Widget', 'A standard widget', 1999, 100),
  ('p1p2p3p4-0000-0000-0000-000000000002', 'Gadget', 'A fancy gadget', 4999, 50);

INSERT INTO orders (user_id, product_id, quantity, total_amount, status) VALUES
  ('a1b2c3d4-0000-0000-0000-000000000001', 'p1p2p3p4-0000-0000-0000-000000000001', 2, 3998, 'completed'),
  ('a1b2c3d4-0000-0000-0000-000000000002', 'p1p2p3p4-0000-0000-0000-000000000002', 1, 4999, 'pending');
```

The order and product services follow the same raw SQL pattern as the user service. All existing tests pass against a running PostgreSQL instance (via Docker Compose). Run `docker-compose up -d` and `npm install` before handing the project to the agent.

## Expected Artifacts

After the task completes, the following should exist at minimum:

- `prisma/schema.prisma` -- Prisma schema matching the existing database tables
- `prisma/migrations/` -- at least one migration file
- `src/services/user.service.ts` -- refactored to use Prisma Client instead of raw SQL
- `src/services/order.service.ts` -- refactored to use Prisma Client
- `src/services/product.service.ts` -- refactored to use Prisma Client
- `src/db.ts` -- either removed or replaced with Prisma Client instantiation
- `prisma/seed.ts` -- seed data ported from SQL to TypeScript
- Updated `package.json` with `prisma` and `@prisma/client` as dependencies
- All existing tests still pass

## Scoring Criteria (20 points max)

| # | Check | Points | How to verify |
|---|-------|--------|---------------|
| 1 | **Prisma schema matches existing tables** | 2 | All three models (`User`, `Order`, `Product`) are defined in `schema.prisma` with correct field types, matching the SQL schema. |
| 2 | **Migration files created** | 3 | `prisma/migrations/` contains at least one migration directory with a `migration.sql` file. Running `npx prisma migrate status` shows no pending migrations. |
| 3 | **All existing tests still pass** | 3 | Run `npm test`. Every test that passed before the refactor still passes. Zero regressions. |
| 4 | **No raw SQL remaining** | 2 | `grep -r "pool.query\|await query(" src/` returns 0 results. All database operations use Prisma Client methods. |
| 5 | **Proper relations defined** | 2 | `schema.prisma` includes `@relation` directives: Order belongs to User, Order belongs to Product, User has many Orders. |
| 6 | **Indexes maintained** | 2 | The indexes from `schema.sql` (`idx_orders_user_id`, `idx_orders_status`, `idx_users_email`) are preserved in the Prisma schema using `@@index` or `@unique`. |
| 7 | **Seed data works** | 1 | `npx prisma db seed` runs without errors and populates the database with the same test data from `seed.sql`. |
| 8 | **Types generated from schema** | 2 | `npx prisma generate` produces types. Service files import types from `@prisma/client` rather than maintaining manual type definitions. |
| 9 | **No data loss risk** | 3 | The migration does not contain `DROP TABLE` or `DROP COLUMN` statements that would destroy existing data. If destructive changes are necessary, they are documented. |

**Total: 20 points**

## Anti-Patterns to Check

- **Schema mismatch**: Prisma schema has different column names, missing fields, or wrong types compared to the SQL schema.
- **No migration created**: Prisma is set up but `npx prisma migrate dev` was never run, so there is no migration history.
- **Raw SQL still used alongside Prisma**: Some services use Prisma, others still use `pool.query`. Inconsistent.
- **Relations not defined**: Models exist but have no `@relation` directives, so eager loading and nested queries do not work.
- **Missing indexes**: The original schema had indexes for performance. The Prisma schema drops them silently.
- **Hardcoded database URL**: `datasource db` in `schema.prisma` uses a hardcoded connection string instead of `env("DATABASE_URL")`.
- **Prisma Client instantiated per request**: Creating `new PrismaClient()` in every service method instead of sharing a singleton.
- **No seed script**: The seed data is lost in the refactor, making it impossible to set up a dev environment.
- **Destructive migration**: The migration drops and recreates tables instead of adapting the existing schema.
- **Tests break silently**: Tests pass because they are skipped or mocked at the wrong level, not because the refactor actually works.
