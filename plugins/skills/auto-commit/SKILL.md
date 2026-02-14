---
name: auto-commit
description: Automatically creates a git commit after completing a task session using Conventional Commits format. Use after any fully completed task to commit changes. Excludes commits if there are uncommitted changes in myspec folder, AGENTS.md, CLAUDE.md, or .utcp_config.json.
---

# Auto-Commit After Task Completion

## When to Run

Trigger automatically **after any fully completed task** in the session.

A task is considered completed when:
- Code changes have been made
- The solution has been verified (tests pass if applicable)
- The repository is in a committable state

## Pre-Commit Safety Checks

Before committing, check for uncommitted changes in protected paths:

\`\`\`bash
git status --porcelain myspec/ AGENTS.md CLAUDE.md .utcp_config.json 2>/dev/null
```

### If protected files have uncommitted changes

Do **not** create a commit.

Instead, notify the user with this exact message:

> Skipping auto-commit: Found uncommitted changes in protected files (myspec/, AGENTS.md, CLAUDE.md, or .utcp\_config.json). Please handle these manually.

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
	- Use bullet points (`*`)
	- Explain *why* or *what changed*, not obvious details

### Examples

```
feat: add user authentication endpoint

* Implement JWT validation
* Add login and logout routes
* Introduce auth middleware
```
```
fix: handle \`null\` return in \`UserService.getById\`
```
```
refactor: extract database logic into \`DbPool\`

* Improve connection reuse
* Add configurable timeout
```

## Commit Workflow

1. Verify the task is complete
2. Run protected-path checks
3. If checks fail → skip commit and notify the user
4. Stage relevant files (`git add <files>`)
5. Create the commit using Conventional Commits
6. Confirm the commit was created successfully

1. Complete the task
2. Run pre-commit checks for protected paths
3. If protected files have changes → skip commit, notify user
4. Stage relevant changes: `git add <files>`
5. Create commit with Conventional Commits message
6. Confirm commit was created