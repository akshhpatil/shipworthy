# Architecture Specification: FastAPI Service

## Project Identity
- **Type**: FastAPI REST/GraphQL service
- **Language**: Python 3.11+ with type hints
- **Primary Framework**: FastAPI
- **Package Manager**: pip / poetry / uv

## Mandatory Rules

1. **Type hints everywhere** — all function parameters and return types annotated.
2. **Pydantic models for all request/response schemas** — never use raw dicts.
3. **Dependency injection for shared resources** — database sessions, auth, config via `Depends()`.
4. **Async by default** — use `async def` for route handlers unless there's a reason not to.
5. **Tests required for routes and services** — every endpoint tested via TestClient.
6. **No circular imports** — strict unidirectional dependency flow.
7. **Environment variables via pydantic-settings** — validated at startup.
8. **Database access through repository pattern** — routes never query the database directly.
9. **Alembic for all migrations** — never modify schema manually.
10. **No bare `except:`** — always catch specific exceptions.

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

## Testing Strategy
- **Framework**: pytest + httpx AsyncClient
- **Coverage**: 80% for services, all routes tested
- **Fixtures**: conftest.py for shared setup
- **Database**: Use test database, rollback after each test

## Error Handling
- Custom exception handlers registered on the app
- HTTPException for expected errors with proper status codes
- Global exception handler for unexpected errors (log + 500)

## Security Baseline
- OAuth2/JWT via FastAPI security utilities
- CORS middleware with explicit origins
- Rate limiting via slowapi
- SQL injection prevention via SQLAlchemy ORM
- Input validation automatic via Pydantic
