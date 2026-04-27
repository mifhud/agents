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
git status --porcelain docs myspec AGENTS.md CLAUDE.md .utcp_config.json ralphy.sh .github .opencode .pi opencode.json agent-config 2>/dev/null
```

### If protected files have uncommitted changes

Do **not** stage or include those protected files in the commit.

Instead, **continue the commit** with the remaining non-protected changes, and notify the user with a warning:

> ⚠️ Skipping protected files from this commit: `<list of affected protected paths>`. Please handle these manually.

If **all** changed files are protected (nothing left to commit), then skip the commit entirely and notify:

> Skipping git-commit-workflow: All changed files are in protected paths (docs myspec AGENTS.md CLAUDE.md .utcp_config.json, ralphy.sh .github .opencode .pi opencode.json agent-config). Please handle these manually.
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
3. If protected files have changes → exclude them from staging, warn the user which files were skipped
4. If no non-protected changes remain → skip commit entirely and notify the user
5. Stage only non-protected relevant files (`git add <files>`)
6. Create the commit using Conventional Commits
7. Confirm the commit was created successfully