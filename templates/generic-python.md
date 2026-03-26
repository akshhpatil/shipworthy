# Architecture Specification: Python Project

## Project Identity
- **Type**: Python application/library
- **Language**: Python 3.11+ with type hints
- **Package Manager**: pip / poetry / uv

## Mandatory Rules

1. **Type hints everywhere** — all function parameters and return types annotated.
2. **Tests for all business logic** — pytest for every function with logic.
3. **No bare `except:`** — always catch specific exceptions.
4. **Virtual environments** — never install to system Python.
5. **Dependencies pinned** — exact versions in requirements.txt or poetry.lock.
6. **No circular imports** — strict module dependency flow.
7. **Docstrings on public functions** — Google or NumPy style.

## Directory Structure

```
src/
├── [package]/              # Main package
│   ├── __init__.py
│   ├── [module].py         # One concern per module
│   └── utils/              # Utility functions
tests/
├── conftest.py             # Shared fixtures
└── test_[module].py        # Tests mirror src/ structure
```

## Naming Conventions
- **Files/modules**: snake_case
- **Variables/functions**: snake_case
- **Classes**: PascalCase
- **Constants**: UPPER_SNAKE_CASE

## Testing Strategy
- **Framework**: pytest
- **Coverage**: 80% (pytest-cov)
- **Fixtures**: conftest.py for shared setup

## Error Handling
- Custom exception hierarchy inheriting from a base AppError
- Catch at module boundaries
- Never silently swallow exceptions
