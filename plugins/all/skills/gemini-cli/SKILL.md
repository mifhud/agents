---
name: gemini-cli
description: "Run Gemini CLI in non-interactive headless mode using -p/--prompt flag. Use when delegating coding tasks to Gemini. Output: stdout with Gemini's responses and code changes."
---

# Gemini CLI Skill

Gemini is an AI coding agent run via CLI. Use non-interactive (headless) mode with the `-p` / `--prompt` flag. No tmux or session management required.

## Agent Type

Every task must declare an **agent type**. The default is `build`.

| Type    | Default | Description                                                                 |
|---------|---------|-----------------------------------------------------------------------------|
| `build` | ✅ Yes  | Execute coding tasks directly — write, edit, and ship code.                |
| `plan`  | No      | Explore the codebase and design implementation plans only. **No file modifications allowed during research phase.** |

### `build` (default)

When agent type is `build`, proceed normally with the workflow below.

### `plan`

When agent type is `plan`, you **must** follow the `agent/plan.md` rules:

#### PHASE 1 — READ-ONLY EXPLORATION (strictly no file modifications)

- No creating, editing, deleting, moving, or copying files
- No redirect operators (`>`, `>>`, `|`) or heredocs
- No state-changing commands
- Allowed: `ls`, `git status`, `git log`, `git diff`, `find`, `cat`, `head`, `tail`, `grep`, `glob`, `read`

#### PHASE 2 — SAVE PLAN

After research and clarification, write the final plan to `docs/plans/`:

1. **Understand Requirements** — Focus on the requirements provided and apply the assigned perspective throughout design.
2. **Explore Thoroughly** —
   - Read any files provided in the initial prompt
   - Find existing patterns and conventions using: glob, grep, and read
   - Understand the current architecture
   - Identify similar features as reference
   - Trace through relevant code paths
   - Use bash tool ONLY for read-only operations
3. **Design Solution** —
   - Create implementation approach based on the assigned perspective
   - Consider trade-offs and architectural decisions
   - Follow existing patterns where appropriate
4. **Ask Clarifying Questions** — Before writing any files, ask any remaining clarifying questions.
5. **Save the Plan** —
   - Create the directory if needed: `mkdir -p docs/plans`
   - Write the plan as: `docs/plans/<feature-name>.md`
   - Include: overview, architecture decisions, step-by-step implementation, file changes, dependencies, risks
   - Confirm to the user where the plan was saved

## Binary Path

```bash
/root/.nvm/versions/node/v22.22.0/bin/gemini
```

## Non-Interactive Mode

Run Gemini in headless mode using the `-p` / `--prompt` flag. The prompt is passed directly and Gemini executes the task, prints output to stdout, and exits.

### Basic Usage

```bash
/root/.nvm/versions/node/v22.22.0/bin/gemini -p 'Your prompt here'
```

### Piping stdin

You can pipe content into Gemini and append the prompt:

```bash
cat some-file.txt | /root/.nvm/versions/node/v22.22.0/bin/gemini -p 'Refactor this code'
```

```bash
git diff HEAD~1 | /root/.nvm/versions/node/v22.22.0/bin/gemini -p 'Review this diff and suggest improvements'
```

## Workflow Examples

### Simple Task

```bash
/root/.nvm/versions/node/v22.22.0/bin/gemini -p 'List all files and explain what this project does'
```

### Build Task with Context

```bash
/root/.nvm/versions/node/v22.22.0/bin/gemini -p 'Add a new REST endpoint for user profiles with validation and tests'
```

### Plan Task (read-only exploration + save plan)

```bash
/root/.nvm/versions/node/v22.22.0/bin/gemini -p 'Explore the codebase and create an implementation plan for adding authentication. Save the plan to docs/plans/authentication.md. During exploration, only read files — do not modify anything until writing the plan.'
```

### Piping File Content

```bash
cat src/api/routes.ts | /root/.nvm/versions/node/v22.22.0/bin/gemini -p 'Add error handling to all route handlers'
```

### Piping Git Diff

```bash
git diff | /root/.nvm/versions/node/v22.22.0/bin/gemini -p 'Review these changes and fix any issues'
```

## Important Tips

- **Always use `-p` flag** for non-interactive headless execution
- **Pipe stdin** when you need to pass file content or diffs as context along with the prompt
- **Agent type `plan`** requires strict read-only exploration before saving plans — do NOT use `agent/plan.md` rules for `build` type
- **No session cleanup** — each `-p` invocation is a single run with no persistent session

You must running using gemini CLI:
$ARGUMENTS
