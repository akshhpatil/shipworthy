## What changed

<!-- Describe the change in 1-3 sentences -->

## Why

<!-- Why is this change needed? Link to an issue if applicable -->

## Type of change

- [ ] Bug fix
- [ ] New skill
- [ ] New template
- [ ] Skill improvement
- [ ] Hook fix/improvement
- [ ] Documentation
- [ ] Benchmark addition
- [ ] Other: ___

## Checklist

- [ ] I have read [CONTRIBUTING.md](../CONTRIBUTING.md)
- [ ] New skills follow the SKILL.md frontmatter format (name, description, invoke_when)
- [ ] Hook tests pass: `bash tests/hooks/test-session-start.sh && bash tests/hooks/test-pre-tool-use.sh && bash tests/hooks/test-post-tool-use.sh`
- [ ] No hardcoded secrets or credentials in any file
- [ ] All references use `.shipworthy/` (not `docs/` or other paths)
- [ ] CHANGELOG.md updated (if user-facing change)
