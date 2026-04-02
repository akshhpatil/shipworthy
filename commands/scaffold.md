Before executing this command, output:
> ⚓ **shipworthy** › command: `/scaffold` — generating architecture specification

---

Analyze this project and generate an architecture specification.

Use the `architecture-awareness` skill to:
1. Detect the project type and technology stack
2. Analyze existing code patterns (if any code exists)
3. Select the most appropriate template from `templates/`
4. Generate `.shipworthy/architecture.md`
5. Present the specification for approval before saving

If an architecture spec already exists, ask the user if they want to regenerate it (this will replace the existing one).
