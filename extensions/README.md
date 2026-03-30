# Shipworthy Extensions

Extensions add industry-specific skills on top of Shipworthy's core 42 skills.

## Available Extensions

| Extension | Description | Status |
|-----------|-------------|--------|
| **healthcare** | HIPAA compliance, PHI handling, audit trails | Planned |
| **fintech** | PCI-DSS, payment patterns, financial math | Planned |
| **e-commerce** | Cart, inventory, orders, shipping | Planned |
| **mobile** | React Native, Flutter, offline-first | Planned |
| **enterprise** | SOC2, RBAC, multi-tenancy | Planned |

## Creating an Extension

An extension is a directory with:
```
extensions/[name]/
├── EXTENSION.md          # Metadata (name, description, version, dependencies)
├── skills/               # Additional SKILL.md files
│   └── [skill-name]/
│       └── SKILL.md
└── templates/            # Optional architecture template overrides
```

### EXTENSION.md Format
```yaml
---
name: my-extension
description: What this extension adds
version: 1.0.0
requires: []              # Core skills this depends on
---
```

### Contributing an Extension
1. Create a directory under `extensions/`
2. Add EXTENSION.md with metadata
3. Add skills following the SKILL.md frontmatter format
4. Update `catalog.json`
5. Submit a PR
