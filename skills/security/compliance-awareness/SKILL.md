---
name: compliance-awareness
description: SOC 2, GDPR, HIPAA awareness for data handling, audit logging, right-to-deletion, and data classification. Practical engineering checks, not legal advice.
invoke_when: Handling PII, health data, financial data, user consent, data deletion requests, or when the project targets regulated industries (healthcare, finance, EU users).
---

# Compliance Awareness

**Disclaimer:** This skill provides engineering patterns for compliance. It is not legal advice. Consult legal counsel for compliance obligations.

## Data Classification

Classify every data field your system stores:

| Level | Examples | Requirements |
|-------|---------|-------------|
| **Public** | Marketing content, docs | No restrictions |
| **Internal** | Internal APIs, architecture docs | Authentication required |
| **Confidential** | PII (name, email, address), financial data | Encryption at rest, access logging, retention policies |
| **Restricted** | Passwords, API keys, health records, SSN | HSM/KMS, never in logs, automatic rotation, minimal access |

## GDPR (EU Users)

### Engineering Requirements
1. **Right to Deletion**: Implement a `DELETE /users/:id` endpoint that cascades deletion through all related data. Verify with: "If I delete user X, is their data gone from every table, cache, log, and backup?"
2. **Data Portability**: Implement a `GET /users/:id/export` endpoint returning all user data in JSON/CSV
3. **Consent Management**: Record when and what the user consented to. Never assume consent.
4. **Data Minimization**: Only collect data you actively use. If a field exists "just in case," delete it.
5. **Privacy by Default**: New features default to minimum data collection. Opt-in, not opt-out.
6. **Breach Notification**: Log enough to detect breaches. Have a plan for 72-hour notification.

### Actionable Checks
- [ ] Can you delete a user and all their data in one operation?
- [ ] Can you export all of a user's data?
- [ ] Do you record consent with timestamps?
- [ ] Are you collecting only necessary data?

## SOC 2

### Engineering Requirements
1. **Access Controls**: Role-based access, MFA for admin, least privilege
2. **Audit Logging**: Log all data access, authentication events, permission changes, admin actions
3. **Change Management**: All changes go through PR review, CI/CD, no direct production access
4. **Availability**: Health checks, monitoring, incident response plan
5. **Encryption**: Data encrypted in transit (TLS) and at rest

### Actionable Checks
- [ ] All data access is logged with user identity
- [ ] All code changes go through pull request review
- [ ] No engineer has direct database write access in production
- [ ] Encryption enabled on all data stores

## HIPAA (Health Data)

### Engineering Requirements
1. **PHI Encryption**: All Protected Health Information encrypted at rest AND in transit
2. **Access Controls**: Minimum necessary access, audit trail for all PHI access
3. **Audit Trail**: Immutable logs of who accessed what PHI, when, why
4. **BAA**: Business Associate Agreements with all vendors who touch PHI
5. **Breach Detection**: Monitoring for unauthorized PHI access

### Actionable Checks
- [ ] PHI fields identified and encrypted
- [ ] Access to PHI logged with user identity and justification
- [ ] PHI never appears in application logs
- [ ] Vendors handling PHI have signed BAAs

## Practical Patterns

### Audit Logging Pattern
```typescript
async function auditLog(event: {
  action: string;      // 'user.read' | 'user.delete' | 'payment.create'
  actor: string;       // userId or serviceId
  resource: string;    // resourceType:resourceId
  timestamp: Date;
  ip?: string;
  metadata?: Record<string, unknown>;
}) {
  await auditStore.append(event); // append-only, immutable
}
```

### Soft Delete for Compliance
```typescript
// Instead of hard delete, soft delete with scheduled purge
await db.users.update({ id, deletedAt: new Date(), anonymizedAt: null });
// Background job anonymizes PII after retention period
// Then hard-deletes after legal hold period expires
```
