# Release Checklist

Personal checklist for cutting a Shipworthy release. Follow every step in order.

## Pre-release

- [ ] All tests pass: `bash tests/run-all-tests.sh`
- [ ] Full validation passes: `bash tests/validate-all.sh`
- [ ] CI is green on main

## Version Bump

- [ ] Update `version` in `package.json`
- [ ] Update version line in `CLAUDE.md` (bottom of file)
- [ ] Update version reference in `README.md` if present
- [ ] Update count references if skills/hooks/agents/etc changed

## Changelog

- [ ] Move items from `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD` in `CHANGELOG.md`
- [ ] Add new `[Unreleased]` section at top
- [ ] Update comparison links at bottom of `CHANGELOG.md`
- [ ] Update `RELEASE-NOTES.md` with user-facing summary

## Tag & Push

```bash
git add package.json CLAUDE.md CHANGELOG.md RELEASE-NOTES.md
git commit -m "vX.Y.Z: <one-line summary>"
git tag vX.Y.Z
git push origin main --tags
```

## Post-release

- [ ] Verify CI passes on the tag
- [ ] Publish to npm: `npm publish`
- [ ] Create GitHub Release from the tag (paste RELEASE-NOTES.md content)
- [ ] Update landing page (`site/index.html`) if needed
- [ ] Announce on Discord / GitHub Discussions

## Versioning Rules

- **Patch** (1.2.x): Bug fixes in hooks/skills, typo fixes, test improvements
- **Minor** (1.x.0): New skills, new hooks, new templates, new commands/agents
- **Major** (x.0.0): Breaking changes to hook JSON format, skill frontmatter schema, or CLI interface
