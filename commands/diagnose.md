Run a full project infrastructure diagnosis.

Unlike `/audit` (which reviews code quality), this command checks what's **missing entirely** from the project.

## Process

1. Run through the `project-diagnosis` skill checklist:
   - Testing infrastructure (test directory, runner, coverage, actual tests)
   - CI/CD configuration (workflows, test step, lint step)
   - Security basics (.env in .gitignore, no hardcoded secrets, input validation, dependency audit)
   - Code quality tools (linter, formatter, type checking)
   - Architecture & documentation (architecture spec, README, .gitignore)
   - Deployment readiness (health endpoint, structured logging, error tracking, env config)

2. Present findings organized by severity:
   - **Critical** — fix immediately (security risks, secrets exposure)
   - **High** — fix soon (no tests, no input validation)
   - **Medium** — improve when convenient (no CI, no linter)
   - **Low** — nice to have (no health endpoint, no .env.example)
   - **Passed** — checks that passed (show as confirmation)

3. After presenting the report, ask the user:
   > "Want me to auto-fix what I can? I'll create missing configs and infrastructure files. I won't modify existing code without your approval."

4. If the user approves, dispatch the `project-doctor` agent (via `subagent-driven-development`) to fix the gaps.

5. After fixes, re-run the checklist and show before/after comparison.

## Example Output

```
## Project Diagnosis Report

### Critical (fix immediately)
- [ ] .env not in .gitignore — secrets may be committed to git

### High (fix soon)
- [ ] No test files found — need tests/ directory and at least one test
- [ ] No input validation on API routes — install Zod and validate inputs

### Medium (improve when convenient)
- [ ] No CI configuration — need .github/workflows/ci.yml
- [ ] No linter — need ESLint with strict config

### Low (nice to have)
- [ ] No health endpoint for monitoring
- [ ] No .env.example documenting required environment variables

### Passed
- [x] .gitignore exists
- [x] README.md exists
- [x] TypeScript strict mode enabled
- [x] No hardcoded secrets detected
- [x] Dependencies have no critical vulnerabilities

---
Score: 5/12 checks passed
Want me to auto-fix what I can?
```
