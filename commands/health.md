Show a project health dashboard.

Quickly assess and display:

1. **Architecture spec**: Present / Missing
2. **Test suite**: Pass / Fail / No tests found (run `npm test` or equivalent)
3. **Build status**: Pass / Fail (run `npm run build` or equivalent)
4. **Tech debt items**: Count from `.engineering-with-vibes/tech-debt.md`
5. **Dependency vulnerabilities**: Count from `npm audit` or equivalent
6. **File count**: Total source files (indicates quality gate level)
7. **Quality gate level**: 1-4 based on file count

Format as a concise dashboard:
```
Project Health Dashboard
========================
Architecture spec:  ✓ Present / ✗ Missing
Tests:             ✓ 47 passing / ✗ 3 failing
Build:             ✓ Clean / ✗ 2 errors
Tech debt:         3 items (1 critical)
Vulnerabilities:   0 known
Source files:      42 → Quality Gate Level 2
```
