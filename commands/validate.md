# /validate — Pre-Push Validation Gate

Run the comprehensive Shipworthy validation suite before pushing changes.

## What This Does

Dispatches the **pre-push-validator** agent to run all validation checks against the current state of the repository. This catches issues before they reach CI.

## Steps

1. Run `bash tests/validate-all.sh` to execute the full validation suite
2. Report results grouped by category:
   - **Hook tests** — session-start, pre-tool-use, post-tool-use (37 tests)
   - **Skill frontmatter** — name, description, invoke_when fields on all skills
   - **CSO compliance** — invoke_when starts with "Use when...", length limits, name/directory match
   - **Skill routing** — all skills reachable from the master routing table
   - **Cross-references** — all shipworthy:skill-name references resolve to real skills
   - **Skill quality** — no duplicates, minimum content, anti-patterns sections, markdown structure
   - **Repo structure** — required files, directories, agents, templates, commands, secrets scan
3. If any check fails, list the specific failures and suggest fixes
4. If all checks pass, confirm it is safe to push

## When to Run

- Before every `git push`
- After adding or modifying skills
- After changing hooks
- Before creating a PR
- When the user runs `/validate`

## Output Format

Report results as a clear summary table:

| Check | Status | Details |
|-------|--------|---------|
| Hook tests | PASS/FAIL | 37/37 passed |
| Skill frontmatter | PASS/FAIL | 55/55 valid |
| CSO compliance | PASS/FAIL | All "Use when..." |
| ... | ... | ... |
