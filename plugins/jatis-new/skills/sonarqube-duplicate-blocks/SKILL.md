---
name: sonarqube-duplicate-blocks
description: Skill for identifying, planning, and fixing duplicate code blocks from SonarQube.
---


# SonarQube Duplicate Blocks

Skill for identifying, planning, and fixing duplicate code blocks from SonarQube.
Orchestrates `sonarqube-duplicate-analyzer` (analyze + plan + fix) and `sonarqube-validator` (build + test + commit).

This skill runs in the **main Claude Code session** as the orchestrator.

## When to Use

When asked to analyze, plan, or fix duplicate code blocks in a SonarQube project.

## Prerequisites

- `SONARQUBE_URL` — SonarQube server URL (e.g., `https://sonarqubev8.jatismobile.com`)
- `SONARQUBE_TOKEN` — API token for authentication

## Arguments

`$ARGUMENTS` should be the SonarQube project URL. Examples:
- `https://sonarqubev8.jatismobile.com/dashboard?id=JNS-6.5-DR-Mitracomm-Checker`
- `https://sonarcloud.io/project/overview?id=my-project`

Optional arguments (append after URL):
- `output_dir=/path/to/dir` — Override default output directory (default: `/tmp/{PROJECT_KEY}_sonar`)

## Orchestration Flow

```
/sonarqube-duplicate-blocks <url>
│
├─ Phase 1: Parse URL → PROJECT_KEY, SONAR_URL
│
├─ Phase 2: Spawn sonarqube-duplicate-analyzer (sequential)
│   → Query SonarQube API for duplicate blocks
│   → Read source code at duplicate locations
│   → Generate fix plan file
│   → Apply fixes (auto for LOW risk, AskUser for MEDIUM/HIGH)
│   → Report: plan path, files modified/created, groups fixed/skipped
│
├─ Phase 3: Spawn sonarqube-validator (if files were modified)
│   → Build check
│   → Test suite
│   → Commit via git-commit-workflow
│
└─ Phase 4: Final report to user
```

---

## Phase 1: Parse and Setup

Extract from `$ARGUMENTS`:

1. **PROJECT_KEY**: the value of `id=` query parameter in the URL
   - Example: `https://sonarqubev8.jatismobile.com/dashboard?id=JNS-6.5-DR-Mitracomm-Checker`
   - → `PROJECT_KEY=JNS-6.5-DR-Mitracomm-Checker`

2. **SONAR_URL**: scheme + host (everything before `/dashboard` or `/project`)
   - → `SONAR_URL=https://sonarqubev8.jatismobile.com`

3. **OUTPUT_DIR**: use `output_dir` argument if provided, otherwise `/tmp/{PROJECT_KEY}_sonar`

4. Confirm `SONARQUBE_TOKEN` is set in the environment. If not set, check `SONAR_LOGIN_V8` as fallback. If neither is set, report:
   ```
   Error: SONARQUBE_TOKEN environment variable is not set.
   Please set it and retry.
   ```

---

## Phase 2: Spawn Duplicate Analyzer

Spawn `sonarqube-duplicate-analyzer` and **wait for it to complete**:

```
subagent_type: sonarqube-duplicate-analyzer
prompt: "Analyze duplicate code blocks for project {PROJECT_KEY} at {SONAR_URL}.
SONARQUBE_TOKEN is available in environment as $SONARQUBE_TOKEN.
OUTPUT_DIR={OUTPUT_DIR}.

Your workflow:
1. Query SonarQube API for files with duplicated blocks
2. Fetch duplication details per file (api/duplications/show)
3. Read source code at each duplicate location
4. Generate fix approach for each duplication group
5. Write plan file to {OUTPUT_DIR}/duplicate-blocks-{date}.md
6. Apply fixes: LOW risk automatically, MEDIUM/HIGH risk ask human via AskUser
7. Update plan file with final status of each group

When complete, report:
- Plan file path
- Duplication groups found (count)
- Groups fixed (auto + approved)
- Groups skipped (rejected + error)
- Files modified (list)
- Files created (list)
- Status: ready_to_validate OR no_changes_made"
```

### Parse Analyzer Result

From the analyzer's completion report, extract:
- `plan_file_path` — path to generated plan file
- `files_modified` — list of files changed
- `files_created` — list of new files
- `groups_fixed` — count
- `groups_skipped` — count
- `status` — `ready_to_validate` or `no_changes_made`

---

## Phase 3: Spawn Validator (only if files were modified)

**Skip this phase** if analyzer reported `status: no_changes_made`.

Spawn `sonarqube-validator` and wait for it to complete:

```
subagent_type: sonarqube-validator
prompt: "Validate duplicate block fixes for project {PROJECT_KEY}.

Modified files: {files_modified}
Created files: {files_created}

Run the standard validation sequence:
1. Build check (compile)
2. Test suite
3. If both pass, commit using git-commit-workflow skill

Commit message:
  refactor: fix duplicate code blocks

  * Reduce code duplication across {count} file(s)
  * Fix duplication groups: {list of fixed group numbers}
  * Plan: {plan_file_path}

Report: build status, test status, commit hash (or failure reason)."
```

---

## Phase 4: Final Report

Present a summary to the user:

```
══════════════════════════════════════════
SonarQube Duplicate Blocks — Complete
══════════════════════════════════════════

Project:  {PROJECT_KEY}
Plan:     {plan_file_path}

Duplication Groups:
  Found:   {total}
  Fixed:   {fixed_auto} auto + {fixed_approved} approved = {total_fixed}
  Skipped: {skipped_rejected} rejected + {skipped_error} error = {total_skipped}

Files Modified: {count}
  {file1}
  {file2}
  ...

Files Created: {count}
  {new_file1}
  ...

──────────────────────────────────────────
Validation:
  Build: {SUCCESS|FAILED|SKIPPED}
  Tests: {SUCCESS|FAILED|SKIPPED}
  Commit: {hash or N/A}
──────────────────────────────────────────

Next steps: git push origin <branch>
══════════════════════════════════════════
```

If no changes were made:
```
══════════════════════════════════════════
SonarQube Duplicate Blocks — Complete
══════════════════════════════════════════

Project: {PROJECT_KEY}
Plan:    {plan_file_path}

Result: No changes applied.
  - {count} duplication groups found
  - All groups were skipped (human rejected or error)

Review the plan file for details:
  {plan_file_path}
══════════════════════════════════════════
```

If no duplications found:
```
══════════════════════════════════════════
SonarQube Duplicate Blocks — Complete
══════════════════════════════════════════

Project: {PROJECT_KEY}

Result: No duplicate blocks found.
The project has no files with duplicated code blocks in SonarQube.
══════════════════════════════════════════
```

---

## Error Handling

- **Analyzer fails to start**: Report error, suggest checking SONARQUBE_TOKEN and SONAR_URL
- **Analyzer reports API error**: Show error detail, suggest checking token permissions
- **Validator fails (build error)**: Report build failure details from validator, suggest reviewing changes in plan file
- **Validator fails (test failure)**: Report test failure summary, suggest reviewing plan file for which files were changed
- **SONARQUBE_TOKEN not set**: Fail fast with clear message before spawning any agents

---

## Example Invocations

```
/sonarqube-duplicate-blocks https://sonarqubev8.jatismobile.com/dashboard?id=JNS-6.5-DR-Mitracomm-Checker

/sonarqube-duplicate-blocks https://sonarcloud.io/project/overview?id=my-project

/sonarqube-duplicate-blocks https://sonarqubev8.jatismobile.com/dashboard?id=MY-PROJECT output_dir=/home/user/myspec/plan/sonar
```
