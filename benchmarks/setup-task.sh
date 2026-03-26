#!/usr/bin/env bash
# Setup a starter project for a benchmark task
# Usage: ./setup-task.sh <task-number> <target-directory>
#
# Creates a clean project in the target directory with the starter code
# appropriate for the given task number.

set -euo pipefail

TASK_NUM="${1:-}"
TARGET_DIR="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STARTERS_DIR="$SCRIPT_DIR/starters"

if [ -z "$TASK_NUM" ] || [ -z "$TARGET_DIR" ]; then
  echo "Usage: $0 <task-number> <target-directory>"
  echo "Example: $0 1 /tmp/benchmark-task-01"
  exit 1
fi

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Initialize git repo
git init --quiet

setup_express_ts() {
  mkdir -p src
  cp "$STARTERS_DIR/express-ts-starter.json" package.json
  cp "$STARTERS_DIR/express-ts-tsconfig.json" tsconfig.json
  cp "$STARTERS_DIR/express-ts-index.ts" src/index.ts
  echo "node_modules/" > .gitignore
  echo "dist/" >> .gitignore
  echo ".env" >> .gitignore
}

case "$TASK_NUM" in
  1)
    # REST API CRUD — empty Express+TS project
    setup_express_ts
    echo "Task 1: Build REST API with CRUD. Starter: empty Express+TS project."
    ;;
  2)
    # Authentication — Express+TS with health endpoint
    setup_express_ts
    echo "Task 2: Add JWT auth. Starter: Express+TS with /health endpoint."
    ;;
  3)
    # Payment integration — Express+TS with auth assumed working
    setup_express_ts
    # Add a simple auth middleware placeholder
    mkdir -p src/middleware
    cat > src/middleware/auth.ts << 'AUTHEOF'
import { Request, Response, NextFunction } from 'express';

export interface AuthRequest extends Request {
  userId?: string;
}

export function authenticate(req: AuthRequest, res: Response, next: NextFunction) {
  // Simulated auth — in real app this would verify JWT
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  req.userId = 'user-123'; // Would be extracted from JWT
  next();
}
AUTHEOF
    echo "Task 3: Add Stripe payments. Starter: Express+TS with auth middleware."
    ;;
  4)
    # Fix security bug — vulnerable Express app
    setup_express_ts
    cp "$STARTERS_DIR/security-bug-starter.ts" src/index.ts
    echo "Task 4: Fix security bug (IDOR). Starter: vulnerable Express app."
    ;;
  5)
    # Dashboard page — Next.js project
    mkdir -p src/app src/components src/lib src/types
    cat > package.json << 'PKGEOF'
{
  "name": "benchmark-dashboard",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "test": "vitest run"
  },
  "dependencies": {
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "typescript": "^5.7.0",
    "@types/react": "^19.0.0",
    "@types/node": "^22.0.0",
    "vitest": "^2.1.0",
    "@testing-library/react": "^16.0.0"
  }
}
PKGEOF
    cat > tsconfig.json << 'TSEOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "esnext"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "preserve",
    "strict": true,
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src"],
  "exclude": ["node_modules"]
}
TSEOF
    echo "node_modules/" > .gitignore
    echo ".next/" >> .gitignore
    echo ".env" >> .gitignore
    echo "Task 5: Build dashboard page. Starter: Next.js project skeleton."
    ;;
  6)
    # Database refactor — Express with raw SQL
    setup_express_ts
    mkdir -p src/db
    cat > src/db/queries.ts << 'SQLEOF'
// Raw SQL queries — these should be refactored to use Prisma
import { Pool } from 'pg';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

export async function getUsers() {
  const result = await pool.query('SELECT * FROM users');
  return result.rows;
}

export async function getUserById(id: string) {
  const result = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
  return result.rows[0];
}

export async function createUser(name: string, email: string) {
  const result = await pool.query(
    'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
    [name, email]
  );
  return result.rows[0];
}

export async function updateUser(id: string, name: string, email: string) {
  const result = await pool.query(
    'UPDATE users SET name = $1, email = $2 WHERE id = $3 RETURNING *',
    [id, name, email]
  );
  return result.rows[0];
}

export async function deleteUser(id: string) {
  await pool.query('DELETE FROM users WHERE id = $1', [id]);
}
SQLEOF
    echo "Task 6: Refactor raw SQL to Prisma. Starter: Express with raw pg queries."
    ;;
  7)
    # Rate limiting and logging — Express with console.log
    setup_express_ts
    # Replace index.ts with one that uses console.log everywhere
    cat > src/index.ts << 'LOGEOF'
import express from 'express';

const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
  console.log('Health check hit');
  res.json({ status: 'ok' });
});

app.get('/users', (req, res) => {
  console.log('Fetching users');
  console.log('Query params:', req.query);
  res.json([{ id: '1', name: 'Alice' }]);
});

app.post('/users', (req, res) => {
  console.log('Creating user:', req.body);
  console.log('Headers:', req.headers);
  res.status(201).json({ id: '2', ...req.body });
});

app.get('/orders', (req, res) => {
  console.log('Fetching orders');
  res.json([{ id: '1', total: 99.99 }]);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
LOGEOF
    echo "Task 7: Add rate limiting + structured logging. Starter: Express with console.log."
    ;;
  8)
    # CI/CD pipeline — TypeScript project with tests, no CI
    setup_express_ts
    mkdir -p src tests
    cat > tests/health.test.ts << 'TESTEOF'
import { describe, it, expect } from 'vitest';
import request from 'supertest';
import app from '../src/index.js';

describe('GET /health', () => {
  it('returns 200 with ok status', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});
TESTEOF
    echo "Task 8: Set up GitHub Actions CI/CD. Starter: Express+TS with tests, no CI."
    ;;
  9)
    # Performance fix — N+1 query problem
    setup_express_ts
    cp "$STARTERS_DIR/performance-bug-starter.ts" src/index.ts
    echo "Task 9: Fix performance (N+1 query). Starter: slow Express app."
    ;;
  10)
    # Cross-session consistency — empty Express+TS for session 1
    setup_express_ts
    echo "Task 10: Cross-session consistency. Starter: empty Express+TS. Will run 2 sessions."
    ;;
  *)
    echo "Unknown task number: $TASK_NUM (valid: 1-10)"
    exit 1
    ;;
esac

# Initial commit
git add -A
git commit --quiet -m "Initial starter project for benchmark task $TASK_NUM"

echo "Starter project ready at: $TARGET_DIR"
