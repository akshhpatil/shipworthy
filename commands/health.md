Show a comprehensive project and plugin health dashboard.

## Part 1: Plugin Installation Health

Verify Shipworthy is correctly installed and functioning:

1. **Hooks installed**: Check `hooks.json` has all 4 hook entries (SessionStart, PreToolUse×2, PostToolUse×2)
2. **Hook scripts exist**: All 5 hook scripts exist and are executable (`session-start`, `pre-tool-use`, `pre-tool-use-bash`, `post-tool-use`, `post-tool-use-write`)
3. **Shared library**: `hooks/lib.sh` exists and is sourceable
4. **JSON parser available**: Check if `jq` or `python3` is available for robust JSON parsing
5. **Detected tier**: What tier was this project assigned? Is it correct?
6. **Skills loaded**: How many skills are available? Any orphaned?
7. **Hook performance**: Run session-start hook and measure execution time. Flag if >3 seconds.
8. **Debug mode**: Is `SHIPWORTHY_DEBUG=1` set? If so, check log at `~/.shipworthy/debug.log`

## Part 2: Project Health

1. **Architecture spec**: Present / Missing at `.shipworthy/architecture.md`
2. **Test suite**: Pass / Fail / No tests found (run `npm test` or equivalent)
3. **Build status**: Pass / Fail (run `npm run build` or equivalent)
4. **Linter**: Configured / Passing / Missing
5. **Tech debt items**: Count from `.shipworthy/tech-debt.md`
6. **Dependency vulnerabilities**: Count from `npm audit` or equivalent
7. **File count**: Total source files (indicates quality gate level)
8. **Quality gate level**: 0-4 based on file count and tier
9. **Feature specs**: Count in `.shipworthy/specs/`
10. **In-progress plans**: Count in `.shipworthy/plans/`

Format as a concise dashboard:
```
Shipworthy Health Dashboard
============================

Plugin Status
  Hooks:          5/5 installed
  JSON parser:    jq available
  Tier detected:  maker
  Skills loaded:  46 (0 orphaned)
  Hook latency:   1.2s (OK)

Project Status
  Architecture:   Present
  Tests:          47 passing, 0 failing
  Build:          Clean
  Linter:         ESLint — passing
  Tech debt:      3 items (1 critical)
  Vulnerabilities: 0 known
  Source files:    42 → Quality Gate Level 2
  Specs:          3 in .shipworthy/specs/
  Plans:          1 in-progress
```
