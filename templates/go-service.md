# Architecture Specification: Go Service

When applying this template, first output:
> ⚓ **shipworthy** › template: `go-service` — scaffolding Go project structure

## Project Identity
- **Type**: Go HTTP service
- **Language**: Go 1.22+
- **Primary Framework**: stdlib net/http or Chi/Gin/Echo

## Mandatory Rules

1. **Handle every error** -- no `_ = err`. Every error checked or explicitly documented why ignored.
2. **Interfaces at consumption point** -- define interfaces where they're used, not where implemented.
3. **Tests for all packages** -- every package has `_test.go` files.
4. **No global state** -- use dependency injection via struct fields.
5. **Context propagation** -- pass `context.Context` as first parameter.
6. **Structured logging** -- `slog` or zerolog, not `fmt.Println`.
7. **Graceful shutdown** -- handle SIGTERM/SIGINT properly.
8. **Input validation on all endpoints** -- validate request bodies, query params, and path params before processing.
9. **No bare panics in library code** -- only `main()` or init may panic. Libraries return errors.
10. **Database access through repository pattern** -- handlers never query the database directly.

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
- **Test files**: `[name]_test.go`
- **Interfaces**: verb-noun or noun-er (`UserStore`, `Validator`)
- **Constants**: PascalCase for exported, camelCase for unexported

## Type System
- Use strong typing -- avoid `interface{}` / `any` unless truly generic
- Define domain types in `internal/model/`
- Use type aliases sparingly -- prefer distinct types
- Validate at boundaries, trust internally

## Testing Strategy
- **Framework**: stdlib `testing` + testify
- **Coverage**: 80% (`go test -cover`)
- **Table-driven tests** for functions with multiple input/output cases
- **Integration tests**: use build tags (`//go:build integration`)
- **Mocks**: use interfaces + generated mocks (mockgen or moq)

## Error Handling
- Wrap errors with `fmt.Errorf("context: %w", err)` for stack trace
- Sentinel errors for expected conditions
- Custom error types for domain errors
- Never log and return the same error -- do one or the other
- Use `errors.Is()` and `errors.As()` for error checking

## Security Baseline
- Validate and sanitize all user input at HTTP handler level
- Use parameterized queries only -- never string concatenation for SQL
- Set security headers (HSTS, X-Content-Type-Options, X-Frame-Options)
- Rate limit public endpoints
- Use TLS in production
- Store secrets in environment variables or secret managers, never in code
- Audit dependencies with `govulncheck`

## Performance Budgets
- API response (p95): <200ms reads, <500ms writes
- Database queries per request: <10
- Memory per request: <50MB
- Goroutine count: monitor for leaks, alert on sustained growth
- Startup time: <5s

## Quality Gate Levels
- Level 1 (always): Tests pass, `go vet` clean, `go build` succeeds
- Level 2 (10+ files): Coverage >80%, no `golangci-lint` errors
- Level 3 (50+ files): No circular imports, benchmark tests for hot paths
- Level 4 (100+ files): Load testing, `govulncheck` clean, profiling for memory/CPU

## Common Mistakes
1. Ignoring errors with `_ = someFunc()` -- always handle or document why ignored
2. Using `interface{}` / `any` when a concrete type would work
3. Not closing response bodies (`defer resp.Body.Close()`)
4. Goroutine leaks -- always ensure goroutines can exit (use context cancellation)
5. Mixing business logic into HTTP handlers -- keep handlers thin, push logic to services
6. Not using `context.Context` for cancellation and timeouts
7. Returning pointer to loop variable in range loops (fixed in Go 1.22+ but still common in older patterns)
8. Using `init()` functions for complex setup -- prefer explicit initialization
9. Not running `go mod tidy` after dependency changes
10. Logging sensitive data (passwords, tokens, PII) in error messages
