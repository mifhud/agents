---
name: sonarqube-parallel/code-smell
description: >-
  Fixes SonarQube code smells in force parallel using multiple sonarqube subagents.
  Processes severities sequentially (BLOCKER → CRITICAL → MAJOR → MINOR → INFO)
  with parallel batch processing within each severity level.
  Use when you need to fix code smells quickly with parallel execution.
---

# SonarQube Parallel Code Smell Fixer

$ARGUMENTS

## Mission

Fix SonarQube code smells with maximum efficiency by processing issues in parallel batches.
This skill orchestrates force multiple sonarqube subagents to work simultaneously on different batches
of code smell issues within each severity level.

## Workflow Overview

```
BLOCKER → Split into batches → Spawn parallel subagents → Collect results → Validate → Commit
  ↓ only when BLOCKER = 0
CRITICAL → Split into batches → Spawn parallel subagents → Collect results → Validate → Commit
  ↓ only when CRITICAL = 0
MAJOR → … → MINOR → … → INFO
```

## Phase 1: Fetch Issues

1. Extract the SonarQube URL from arguments: `$ARGUMENTS`
2. Use `sonarqube-fetcher` skill to query issues with `types: ["CODE_SMELL"]`
3. Get severity counts for: BLOCKER, CRITICAL, MAJOR, MINOR, INFO
4. Start with the highest non-zero severity

## Phase 2: Parallel Batch Processing

For each severity level (BLOCKER → CRITICAL → MAJOR → MINOR → INFO):

### 2.1 Determine Batch Configuration

| Severity | Batch Size | Max Parallel Subagents |
|----------|-----------|----------------------|
| BLOCKER  | 3-5       | 3                    |
| CRITICAL | 5-10      | 4                    |
| MAJOR    | 10-15     | 5                    |
| MINOR    | 15-20     | 5                    |
| INFO     | 20+       | 5                    |

### 2.2 Split Issues into Batches

- Group issues by batch size
- Ensure batches don't overlap on same files (to avoid conflicts)
- If issues share files, keep them in the same batch

### 2.3 Spawn Parallel Subagents

Use parallel subagent sonarqube to spawn subagents:

```
For each batch:
  parallel subagent "sonarqube", prompt="Fix these code smell issues: [batch details]"
```

**Each subagent receives:**
- List of issue keys to fix
- File paths and line numbers
- Rule keys and messages
- Severity level

### 2.4 Collect Results

Wait for all subagents to complete:
- **Success**: Issues fixed, files modified
- **Partial**: Some issues fixed, some failed
- **Failed**: Batch failed entirely

### 2.5 Validation

After all batches complete for this severity:

1. **Build check** — Compile the project
2. **Test suite** — Run all tests
3. **SonarQube re-analysis** — Verify issue counts decreased
4. **Quality gate check** — Confirm gate passes

Use `sonarqube-code-smell-validator` patterns for validation.

### 2.6 Commit

If validation passes:

1. Load `git-commit-workflow` skill
2. Create commit(s):
   - BLOCKER/CRITICAL: Individual commits per batch
   - MAJOR and below: Group commits by severity
3. Report progress

### 2.7 Handle Failures

If any batch fails validation:
1. Identify failing batch and issues
2. Revert changes for that batch
3. Document failed issues for manual review
4. Continue with next severity

### 2.8 Verify Severity Completion

Re-fetch issues with `&types=CODE_SMELL&severities=<CURRENT_SEVERITY>`:
- If count = 0 → proceed to next severity
- If count > 0 → document remaining issues, ask whether to continue

## Phase 3: Progress Through All Severities

Continue the parallel batch workflow for:
1. BLOCKER (highest priority)
2. CRITICAL
3. MAJOR
4. MINOR
5. INFO (lowest priority)

## Phase 4: Final Summary

```
══════════════════════════════════════════
SonarQube Parallel Remediation Complete
══════════════════════════════════════════

BLOCKER:  8 fixed, 0 remaining (2 batches, 3 parallel)
CRITICAL: 23 fixed, 0 remaining (3 batches, 4 parallel)
MAJOR:    15 fixed, 0 remaining (2 batches, 3 parallel)
MINOR:    2 fixed, 0 remaining (1 batch)
INFO:     0 fixed, 0 remaining

Total Fixed: 48
Batches Processed: 8
Parallel Subagents Used: 15
Manual Review Required: 0

Git branch: fix/sonar-parallel-YYYYMMDD
Commits: 8

Quality gate: PASSED ✓
══════════════════════════════════════════
```

## Human Approval Rules

**Before applying ANY fix that changes control flow, business logic, or data
processing, stop and ask the user for approval.**

For safe fixes (formatting, naming, unused imports, etc.), proceed automatically.

## Communication Guidelines

- Report progress after every severity level completion
- Show batch progress: `BLOCKER Batch 2/3 complete (67%)`
- Report parallel subagent status: `3 subagents running, 1 completed`
- Do not ask for approval on each individual safe fix

## Error Handling

### Subagent Timeout
- If a subagent doesn't respond within 5 minutes, mark as failed
- Retry once with smaller batch size
- If still failing, document for manual review

### File Conflicts
- If multiple batches try to edit the same file, merge changes
- If merge conflicts occur, revert and reprocess sequentially

### Validation Failures
- Build failures: Revert all batches for this severity
- Test failures: Identify which batch caused failure, revert only that batch
- New SonarQube issues: Document and continue

## Validation Requirements

Build: SUCCESS
Tests: All passed
Code Smells: All severities at 0
Quality gate: PASSED
