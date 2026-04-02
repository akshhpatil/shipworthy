Before executing this command, output:
> ⚓ **shipworthy** › command: `/audit` — running full quality audit

---

Run a full quality audit on this project.

Perform a comprehensive review covering:

1. **Architecture compliance** — check all code against `.shipworthy/architecture.md` Mandatory Rules
2. **Security scan** — review for OWASP Top 10 vulnerabilities (hardcoded secrets, SQL injection, XSS, missing auth)
3. **Test coverage** — identify untested business logic and critical paths
4. **Dependency health** — run `npm audit` / `pip audit`, check for outdated packages
5. **Tech debt review** — check `.shipworthy/tech-debt.md` for outstanding items
6. **Performance** — identify obvious bottlenecks (N+1 queries, missing indexes, large bundles)
7. **Accessibility** — check UI components for WCAG 2.1 AA compliance

Present results organized by severity:
- **Critical** — must fix immediately
- **Important** — should fix soon
- **Advisory** — improve when convenient

End with an overall health score (A-F) and top 3 recommended actions.
