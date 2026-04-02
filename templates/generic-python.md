# Architecture Specification: Python Project

When applying this template, first output:
> ⚓ **shipworthy** › template: `generic-python` — scaffolding Python project structure

## Project Identity
- **Type**: Python application/library
- **Language**: Python 3.11+ with type hints
- **Package Manager**: pip / poetry / uv

## Mandatory Rules

1. **Type hints everywhere** -- all function parameters and return types annotated.
2. **Tests for all business logic** -- pytest for every function with logic.
3. **No bare `except:`** -- always catch specific exceptions.
4. **Virtual environments** -- never install to system Python.
5. **Dependencies pinned** -- exact versions in requirements.txt or poetry.lock.
6. **No circular imports** -- strict module dependency flow.
7. **Docstrings on public functions** -- Google or NumPy style.
8. **No mutable default arguments** -- use `None` and assign inside function body.
9. **Single responsibility** -- each module has one clear purpose.
10. **Configuration via environment variables** -- no hardcoded secrets or config values.

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
- **Test files**: `test_[name].py`
- **Private members**: single underscore prefix (`_internal_method`)

## Type System
- Type hints on all function signatures
- Use `Optional[]` explicitly, avoid implicit `None`
- Use `TypeVar` and generics for reusable patterns
- Use `Protocol` for structural typing (duck typing with type safety)
- Run `mypy` in strict mode

## Testing Strategy
- **Framework**: pytest
- **Coverage**: 80% (pytest-cov)
- **Fixtures**: conftest.py for shared setup
- **Mocking**: `unittest.mock` or `pytest-mock`

## Error Handling
- Custom exception hierarchy inheriting from a base AppError
- Catch at module boundaries
- Never silently swallow exceptions
- Use logging module for error reporting, not print statements

## Security Baseline
- Never use `eval()` or `exec()` on user input
- Validate and sanitize all external input
- Use parameterized queries for database access (no f-string SQL)
- Audit dependencies with `pip-audit` or `safety`
- Store secrets in environment variables or secret managers
- Pin dependencies to prevent supply chain attacks

## Performance Budgets
- Startup time: <2s
- Hot path latency: <50ms
- Memory usage: profile with `tracemalloc` for large datasets
- Import time: keep lazy where possible for CLI tools

## Quality Gate Levels
- Level 1 (always): Tests pass, `mypy` clean, no lint errors
- Level 2 (10+ files): Coverage >80%, no TODOs without tickets
- Level 3 (50+ files): No circular imports, all public functions documented
- Level 4 (100+ files): Performance benchmarks, `pip-audit` clean, profiling for hot paths

## Common Mistakes
1. Using mutable default arguments (`def f(items=[])`) -- causes shared state bugs
2. Bare `except:` catching SystemExit and KeyboardInterrupt
3. Not using virtual environments (polluting system Python)
4. Using `print()` instead of the `logging` module
5. Not closing file handles (use context managers / `with` statements)
6. Circular imports between modules
7. Hardcoding file paths instead of using `pathlib.Path`
