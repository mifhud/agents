---
name: git-squash-workflow
description: Squashes git commits using interactive rebase. Use when the user explicitly asks to squash commits, clean up commit history, combine commits, or condense recent commits into one. Do not use automatically after tasks.
---

# Squash Workflow

## When to Run

Trigger **only when the user explicitly requests** a squash:

- User says "squash commits", "squash the last N commits", "combine commits"
- User asks to "clean up commit history" or "condense commits"
- User wants to merge multiple commits into a single commit

**Do NOT trigger automatically** after completing tasks.

## Pre-Squash Safety Checks

Before squashing, verify the current branch state:

```bash
# Check for uncommitted changes
git status --porcelain 2>/dev/null
```

### If there are uncommitted changes

Do **not** proceed with the squash.

Instead, notify the user with this exact message:

> Skipping git-squash-workflow: Found uncommitted changes in the working tree. Please commit or stash them before squashing.

### If on a protected branch

Check if the current branch is `main`, `master`, or `develop`:

```bash
git branch --show-current 2>/dev/null
```

If on a protected branch, notify the user:

> Skipping git-squash-workflow: You are on `<branch>`. Squashing rewrites history and should not be done on shared/protected branches. Please switch to a feature branch first.

### If commits have already been pushed

Check whether the commits to squash exist on the remote:

```bash
git log --oneline origin/<branch>..<branch> 2>/dev/null
```

If some or all target commits have already been pushed, **warn the user**:

> Warning: Some of these commits have already been pushed to the remote. Squashing will require a force push (`git push --force-with-lease`). Proceed only if you are the sole contributor on this branch.

Wait for explicit confirmation before continuing.

## Squash Rules

### Determining Commit Count

- If the user specifies a number (e.g., "squash last 3 commits"), use that count
- If the user says "squash all commits on this branch", calculate the count:
  ```bash
  git rev-list --count HEAD ^$(git merge-base HEAD main) 2>/dev/null
  ```
  Fall back to `master` if `main` does not exist
- If ambiguous, ask the user how many commits to squash

### Squash Commit Message Format

Follow **Conventional Commits** strictly, consistent with the commit-workflow.

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

- Determine the type from the **overall intent** of the combined commits
- Description must be:
  - Imperative mood
  - Under 72 characters
  - Concise and specific
  - Use backticks for code references
- Optional body:
  - Summarize the key changes from all squashed commits
  - Use bullet points (*)
  - Omit trivial or redundant entries (e.g., multiple "fix typo" commits)
  - Explain *why* or *what changed*, not obvious details

### Examples

Squashing 4 commits that added a user dashboard:

```
feat: add user dashboard with analytics widgets

* Implement dashboard layout and routing
* Add real-time analytics chart components
* Integrate data fetching from `/api/metrics`
* Add unit tests for dashboard components
```

Squashing 3 fix commits:

```
fix: resolve race condition in `WebSocketManager`

* Add mutex lock around connection pool access
* Fix reconnection logic on timeout
```

Squashing cleanup commits:

```
chore: clean up legacy authentication module

* Remove deprecated `v1` auth endpoints
* Update imports to use new `AuthService`
```

## Squash Workflow

1. Wait for explicit user request to squash
2. Run pre-squash safety checks (uncommitted changes, protected branch, pushed commits)
3. If any check fails → skip squash and notify the user
4. Determine the number of commits to squash
5. Review the commits to be squashed:
   ```bash
   git log --oneline -n <count>
   ```
6. Present the commits to the user and confirm before proceeding
7. Perform the squash using non-interactive rebase:
   ```bash
   git reset --soft HEAD~<count>
   git commit -m "<conventional commit message>"
   ```
8. Confirm the squash was completed successfully:
   ```bash
   git log --oneline -n 3
   ```
9. If the user previously received a force-push warning and confirms, offer:
   ```bash
   git push --force-with-lease
   ```