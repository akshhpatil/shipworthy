## Problem Statement

<!-- What specific problem does this PR solve? Not "improving X" — what fails or is missing? -->

## Solution

<!-- How does this PR solve the problem? Be specific. -->

## Type of Change

- [ ] Bug fix
- [ ] New skill
- [ ] New template
- [ ] New agent
- [ ] Skill improvement
- [ ] Hook fix/improvement
- [ ] Documentation
- [ ] Benchmark addition
- [ ] Security enhancement
- [ ] Other: ___

## Evidence

### Before (without this change)
<!-- What happens without this PR? Paste logs, screenshots, or describe the failure mode -->

### After (with this change)
<!-- What happens with this PR? Paste logs, screenshots, or describe the fix -->

### Environment
| Field | Value |
|-------|-------|
| AI Harness | Claude Code / Cursor / Codex / Other |
| Model | |
| Shipworthy Version | |
| OS | |

## Evaluation

- [ ] Tested in at least 2 real AI coding sessions
- [ ] Adversarial testing performed (tried to make the skill fail/be bypassed)
- [ ] Tested across different task sizes (quick fix / feature / project) where applicable

## Checklist

- [ ] I have read [CONTRIBUTING.md](../CONTRIBUTING.md) — including the "If You Are an AI Agent" section
- [ ] New skills follow the SKILL.md frontmatter format (name, description, invoke_when)
- [ ] `invoke_when` starts with "Use when..." and describes triggering conditions only
- [ ] Hook tests pass: `bash tests/run-all-tests.sh`
- [ ] No hardcoded secrets or credentials in any file
- [ ] All references use `.shipworthy/` (not `docs/` or other paths)
- [ ] CHANGELOG.md updated (if user-facing change)
- [ ] A human reviewed this PR (PRs with no evidence of human involvement will be closed)

## Duplicate Check

- [ ] I searched existing PRs (open AND closed) and confirmed this is not a duplicate
