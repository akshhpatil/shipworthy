# Quick Start

## 5-Minute Walkthrough

### 1. Install

```bash
npx shipworthy init
```

### 2. Open Your AI Agent

Start a Claude Code, Cursor, or Copilot session in your project.

### 3. Build Something

Ask your AI to build a feature — just describe what you want:

> "Build a user registration API with email and password"

### 4. Watch the Guardrails Work

Without Shipworthy, the AI might produce code with manual validation, no tests, console.log everywhere, and maybe even hardcoded secrets.

With Shipworthy, the AI automatically:
- Installs Zod for input validation
- Writes tests before implementation
- Uses structured logging instead of console.log
- Stores secrets in environment variables
- Uses proper HTTP status codes
- Hashes passwords with bcrypt

You didn't ask for any of this. The guardrails are invisible.

### 5. Check Your Score

```bash
npx shipworthy score
```

You should see a score of 18+ out of 25 (A grade).

## What Happens Behind the Scenes

1. **Session start**: Shipworthy loads 42 engineering skills into the AI's context
2. **Skill routing**: Based on your task (API, auth, database), the relevant skills activate
3. **Non-negotiable defaults**: Zod validation, structured logging, tests, no secrets in code
4. **Verification**: Before claiming "done", the AI runs tests and build to prove it works
5. **Architecture memory**: Your project's conventions are saved in `.shipworthy/architecture.md` and enforced on every future session
