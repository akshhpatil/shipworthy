---
name: observability-by-default
description: Structured logging, request tracing, health checks, error tracking, and key metrics. Every service should be observable from day one.
invoke_when: Creating services, API endpoints, background jobs, or when setting up logging/monitoring.
---

# Observability by Default

## Principle

If you can't see it, you can't fix it. Every service should be observable from the first commit, not bolted on after the first outage.

## Structured Logging

### Rules
- **JSON format** — not free-text strings
- **Correlation IDs** — every request gets a unique ID, propagated through all log entries
- **Log levels used correctly**:
  - `error`: something failed that shouldn't have (action needed)
  - `warn`: something unexpected but handled (investigate if frequent)
  - `info`: significant business events (user created, order placed)
  - `debug`: detailed diagnostic info (disabled in production)
- **Never log**: passwords, tokens, PII, credit card numbers, full request bodies with sensitive fields

### Pattern
```typescript
logger.info('User created', {
  correlationId: req.id,
  userId: user.id,
  email: user.email, // only if non-sensitive
  duration: Date.now() - start
});
```

## Health Check Endpoints

Every service MUST expose:
- `GET /health` — returns 200 if service is running
- `GET /health/ready` — returns 200 if service can handle traffic (DB connected, dependencies available)

## Key Metrics (The Four Golden Signals)

1. **Latency** — how long requests take (p50, p95, p99)
2. **Traffic** — requests per second
3. **Errors** — error rate (5xx responses / total responses)
4. **Saturation** — how full your resources are (CPU, memory, connections)

## Error Tracking

- Capture unhandled exceptions with context (request, user, stack trace)
- Group errors by type to identify patterns
- Alert on new error types and error rate spikes

## Request Tracing

- Assign a unique ID to every inbound request
- Pass it through all internal service calls
- Include it in all log entries and error reports
- Return it in response headers for client-side debugging: `X-Request-Id`
