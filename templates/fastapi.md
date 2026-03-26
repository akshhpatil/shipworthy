# Architecture Specification: FastAPI Service

## Project Identity
- **Type**: FastAPI REST/GraphQL service
- **Language**: Python 3.11+ with type hints
- **Primary Framework**: FastAPI
- **Package Manager**: pip / poetry / uv

## Mandatory Rules

1. **Type hints everywhere** -- all function parameters and return types annotated.
2. **Pydantic models for all request/response schemas** -- never use raw dicts.
3. **Dependency injection for shared resources** -- database sessions, auth, config via `Depends()`.
4. **Async by default** -- use `async def` for route handlers unless there's a reason not to.
5. **Tests required for routes and services** -- every endpoint tested via TestClient.
6. **No circular imports** -- strict unidirectional dependency flow.
7. **Environment variables via pydantic-settings** -- validated at startup.
8. **Database access through repository pattern** -- routes never query the database directly.
9. **Alembic for all migrations** -- never modify schema manually.
10. **No bare `except:`** -- always catch specific exceptions.

## Directory Structure

```
app/
├── main.py                 # FastAPI app instance and startup
├── routers/                # Route handlers
│   └── [resource].py       # One file per resource
├── services/               # Business logic
├── models/                 # SQLAlchemy/Pydantic models
│   ├── database.py         # DB models
│   └── schemas.py          # Pydantic request/response schemas
├── repositories/           # Database access layer
├── middleware/              # Custom middleware
├── dependencies/           # Dependency injection providers
├── utils/                  # Utility functions
└── config.py               # Settings management
tests/
├── conftest.py             # Shared fixtures
├── test_[resource].py      # Route tests
└── test_[service].py       # Service tests
alembic/                    # Database migrations
```

## Naming Conventions
- **Files**: snake_case (`user_service.py`)
- **Variables/functions**: snake_case
- **Classes**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Test files**: `test_[name].py`

## Type System
- Type hints on all function signatures (parameters and return types)
- Pydantic models for request/response validation
- Use `Optional[]` explicitly, avoid `None` default without annotation
- Generic types for reusable patterns (`PaginatedResponse[T]`)

## Testing Strategy
- **Framework**: pytest + httpx AsyncClient
- **Coverage**: 80% for services, all routes tested
- **Fixtures**: conftest.py for shared setup
- **Database**: Use test database, rollback after each test

## Error Handling
- Custom exception handlers registered on the app
- HTTPException for expected errors with proper status codes
- Global exception handler for unexpected errors (log + 500)
- Never expose stack traces or internal details to clients

## Security Baseline
- OAuth2/JWT via FastAPI security utilities
- CORS middleware with explicit origins
- Rate limiting via slowapi
- SQL injection prevention via SQLAlchemy ORM
- Input validation automatic via Pydantic
- Audit dependencies with `pip-audit` or `safety`

## Performance Budgets
- API response (p95): <200ms reads, <500ms writes
- Database queries per request: <10
- Payload size: <1MB per response
- Startup time: <5s

## Quality Gate Levels
- Level 1 (always): Tests pass, `mypy` clean, no lint errors
- Level 2 (10+ files): Coverage >80%, no hardcoded secrets
- Level 3 (50+ files): No circular imports, API docs synchronized
- Level 4 (100+ files): Load testing, `pip-audit` clean, profiling for slow endpoints

## Common Mistakes
1. Using raw dicts instead of Pydantic models for request/response
2. Bare `except:` swallowing all exceptions including SystemExit and KeyboardInterrupt
3. Not using `async def` for I/O-bound route handlers
4. Querying the database directly in route handlers instead of using repositories
5. Forgetting to add Alembic migration after model changes
6. Not closing database sessions properly (use dependency injection with `yield`)
7. Hardcoding configuration values instead of using pydantic-settings
