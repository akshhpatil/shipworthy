---
name: threat-modeling
description: STRIDE-based systematic security analysis. For each component, ask what can go wrong across six threat categories and document mitigations.
invoke_when: Designing new features that handle user data, authentication, authorization, payments, or external integrations. Also before security audits or when reviewing architecture for security gaps.
---

# Threat Modeling (STRIDE)

## When to Threat Model

- New service or API endpoint that handles sensitive data
- Authentication or authorization changes
- Payment or billing features
- File upload or user-generated content
- Third-party integrations
- Any feature that stores or transmits PII

## The STRIDE Framework

For each component or feature, evaluate all six threat categories:

### S — Spoofing (Identity)
**Question:** Can someone pretend to be another user or service?
**Check:**
- Every endpoint has authentication
- Service-to-service calls use mutual TLS or signed tokens
- Session tokens are cryptographically secure and expire
- No shared credentials between users or environments
**Mitigations:** Strong authentication, MFA, certificate pinning, API key rotation

### T — Tampering (Integrity)
**Question:** Can someone modify data in transit or at rest without detection?
**Check:**
- All communication uses TLS (no mixed content)
- Database has integrity constraints (foreign keys, check constraints)
- API inputs are validated and sanitized
- File uploads are verified (type, size, content scanning)
- Signed payloads for webhooks and callbacks
**Mitigations:** TLS everywhere, input validation, checksums, database constraints

### R — Repudiation (Accountability)
**Question:** Can someone deny performing an action?
**Check:**
- Audit logs capture: who, what, when, from where
- Sensitive operations (payments, deletions, permission changes) are logged
- Logs are immutable (append-only, shipped to external system)
- Timestamps are server-generated, not client-provided
**Mitigations:** Audit logging, immutable logs, server-side timestamps

### I — Information Disclosure (Confidentiality)
**Question:** Can someone access data they should not see?
**Check:**
- Authorization checks on every data access (not just UI hiding)
- Error messages do not leak internal details (stack traces, SQL, file paths)
- Logs do not contain PII, passwords, or tokens
- API responses include only fields the user is authorized to see
- Debug endpoints disabled in production
**Mitigations:** Authorization middleware, safe error messages, data classification, log sanitization

### D — Denial of Service (Availability)
**Question:** Can someone make the system unavailable?
**Check:**
- Rate limiting on all public endpoints
- Input size limits (request body, file upload, query params)
- Query timeouts on database operations
- Resource quotas (connection pools, memory limits)
- No unbounded operations (unlimited loops, recursive queries)
**Mitigations:** Rate limiting, input validation, timeouts, resource quotas, caching

### E — Elevation of Privilege (Authorization)
**Question:** Can someone gain permissions they should not have?
**Check:**
- Role-based access control enforced server-side
- No admin endpoints accessible without admin authentication
- Default deny — users have no permissions until explicitly granted
- Permission changes require re-authentication
- API keys are scoped to minimum required permissions
**Mitigations:** RBAC, principle of least privilege, permission validation on every request

## Practical Walkthrough: Typical Web App

```
Component: User Registration API
├── S: Can someone register as admin? → Validate role assignment, default to "user"
├── T: Can someone modify their role after registration? → Server-side role management only
├── R: Can someone deny creating an account? → Log account creation with IP and timestamp
├── I: Can someone enumerate existing emails? → Use constant-time responses for existence checks
├── D: Can someone spam registrations? → Rate limit by IP, CAPTCHA after 3 attempts
└── E: Can a regular user access admin endpoints? → Middleware checks role on every request
```

## Output Format

Document threats in `.engineering-with-vibes/decisions/` as:
```markdown
# Threat Model: [Feature Name]
## Date: YYYY-MM-DD
## Components Analyzed: [list]
## Threats Identified:
| Category | Threat | Severity | Mitigation | Status |
## Accepted Risks: [documented and justified]
```
