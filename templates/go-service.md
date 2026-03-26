# Architecture Specification: Go Service

## Project Identity
- **Type**: Go HTTP service
- **Language**: Go 1.22+
- **Primary Framework**: stdlib net/http or Chi/Gin/Echo

## Mandatory Rules

1. **Handle every error** — no `_ = err`. Every error checked or explicitly documented why ignored.
2. **Interfaces at consumption point** — define interfaces where they're used, not where implemented.
3. **Tests for all packages** — every package has `_test.go` files.
4. **No global state** — use dependency injection via struct fields.
5. **Context propagation** — pass `context.Context` as first parameter.
6. **Structured logging** — `slog` or zerolog, not `fmt.Println`.
7. **Graceful shutdown** — handle SIGTERM/SIGINT properly.

## Directory Structure

```
cmd/
├── server/
│   └── main.go             # Entry point
internal/
├── handler/                # HTTP handlers
├── service/                # Business logic
├── repository/             # Data access
├── model/                  # Domain types
└── middleware/              # HTTP middleware
pkg/                        # Reusable packages (if any)
migrations/                 # Database migrations
```

## Naming Conventions
- **Files**: snake_case (`user_handler.go`)
- **Packages**: short, lowercase, no underscores
- **Exported**: PascalCase
- **Unexported**: camelCase

## Testing Strategy
- **Framework**: stdlib `testing` + testify
- **Coverage**: 80% (`go test -cover`)
- **Table-driven tests** for functions with multiple input/output cases

## Error Handling
- Wrap errors with `fmt.Errorf("context: %w", err)` for stack trace
- Sentinel errors for expected conditions
- Custom error types for domain errors
