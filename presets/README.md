# Shipworthy Presets

Presets configure which skills are active and how strict the quality gates are.

## Available Presets

| Preset | Tier | Quality Gate | Best For |
|--------|------|-------------|----------|
| **startup** | Builder | Level 1 | MVPs, prototypes, hackathons |
| **agency** | Maker | Level 2 | Client work, freelance projects |
| **enterprise** | Engineer | Level 4 | Production systems, regulated industries |

## Using a Preset

```bash
npx shipworthy init --preset startup
npx shipworthy init --preset enterprise
```

## What Presets Control

- **tier** — Builder/Maker/Engineer (affects TDD visibility, brainstorming depth)
- **quality_gate_level** — Maximum quality gate level enforced
- **active_categories** — Which skill categories are loaded
- **skip_skills** — Specific skills to disable
- **overrides** — Fine-grained behavior settings

## Per-Project Configuration

Create `.shipworthy/config.json` in your project root for per-project overrides:

```json
{
  "preset": "enterprise",
  "overrides": {
    "allow_console_log": false,
    "allow_any_types": false,
    "project_type": "api"
  },
  "ignore_paths": ["legacy/", "vendor/", "generated/", "migrations/"]
}
```

### Override Reference

| Override | Type | Default | Purpose |
|----------|------|---------|---------|
| `allow_console_log` | boolean | false | Skip console.log warnings (for CLI tools) |
| `allow_any_types` | boolean | false | Skip TypeScript `:any` warnings (for legacy code) |
| `project_type` | string | auto | Override auto-detection: `api`, `cli`, `frontend`, `library`, `monorepo` |

### Ignore Paths

Files in `ignore_paths` skip all pre-tool-use and post-tool-use checks. Use for:
- Legacy code you can't change
- Vendored dependencies
- Generated/auto-generated files
- Third-party code

## Creating a Custom Preset

Create a JSON file in `presets/`:

```json
{
  "name": "my-preset",
  "description": "What this preset is for",
  "tier": "maker",
  "quality_gate_level": 2,
  "active_categories": ["core", "quality", "security"],
  "skip_skills": [],
  "overrides": {}
}
```
