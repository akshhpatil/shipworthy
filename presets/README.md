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
