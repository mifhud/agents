---
name: git-commit-workflow
description: Creates git commits using Conventional Commits format. Use when the user explicitly asks to commit changes, create a commit, or save their work to git. Do not use automatically after tasks.
---

# Commit Workflow

## When to Run

Trigger **only when the user explicitly requests** a commit:
- User says "commit this", "create a commit", "save to git"
- User asks to commit specific changes
- User wants to save their work

**Do NOT trigger automatically** after completing tasks.

## Pre-Commit Safety Checks

Before committing, check for uncommitted changes in protected paths:

```bash
git status --porcelain myspec/archive AGENTS.md CLAUDE.md .utcp_config.json ralphy.sh 2>/dev/null
```

### If protected files have uncommitted changes

Do **not** create a commit.

Instead, notify the user with this exact message:

> Skipping git-commit-workflow: Found uncommitted changes in protected files or folders (myspec/archive, AGENTS.md, CLAUDE.md, .utcp_config.json, ralphy.sh). Please handle these manually.
## Commit Rules

### Commit Message Format

Follow **Conventional Commits** strictly.
**Do not include a scope in conventional commit (scope_name).**

```
<type>: <description>

[optional body]
```

### Allowed Types

- `feat` — New feature
- `fix` — Bug fix
- `docs` — Documentation only changes
- `style` — Formatting, no logic changes
- `refactor` — Code refactoring
- `test` — Adding or updating tests
- `chore` — Maintenance, tooling, dependencies

### Message Guidelines

- Description must be:
  - Imperative mood
  - Under 72 characters
  - Concise and specific
  - Use backticks for code references
- Optional body:
  - Use bullet points (*)
  - Explain *why* or *what changed*, not obvious details

### Examples

```
feat: add user authentication endpoint

* Implement JWT validation
* Add login and logout routes
* Introduce auth middleware
```

```
fix: handle `null` return in `UserService.getById`
```

```
refactor: extract database logic into `DbPool`

* Improve connection reuse
* Add configurable timeout
```

## Commit Workflow

1. Wait for explicit user request to commit
2. Run protected-path checks
3. If checks fail → skip commit and notify the user
4. Stage relevant files (`git add <files>`)
5. Create the commit using Conventional Commits
6. Confirm the commit was created successfully