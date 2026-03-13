---
name: sonarqube-remediate
description: Orchestrator skill for coordinating SonarQube issue remediation and test coverage improvement using parallel sub-agents.
---

# SonarQube Remediate

Orchestrator skill for coordinating SonarQube issue remediation (BUG, VULNERABILITY, CODE_SMELL) and test coverage improvement using parallel sub-agents. This skill is executed directly by the main Claude Code session (not a sub-agent).

## When to Use

When asked to fix SonarQube issues, improve test coverage, or both. This skill coordinates fetchers, fixers, validators, and coverage writers to remediate issues by type and severity, and/or generate tests to reach coverage targets.

## Prerequisites

- `SONARQUBE_URL` - SonarQube server URL (default: https://sonarcloud.io)
- `SONARQUBE_TOKEN` - API token for authentication
- `SONARQUBE_ORGANIZATION` - Organization key (required for SonarCloud)

## Arguments

- `url` - SonarQube project URL (e.g., https://sonarcloud.io/project/issues?id=myproject)
- `types` - Optional: comma-separated list of issue types to fix (default: BUG,VULNERABILITY,CODE_SMELL)
- `severities` - Optional: comma-separated list of severities to fix (default: BLOCKER,CRITICAL,MAJOR,MINOR,INFO)
- `coverage_target` - Optional: target coverage percentage (default: 91)
- `mode` - Optional: operation mode (default: `both`)
  - `issues` — fix BUG, VULNERABILITY, CODE_SMELL only
  - `hotspots` — fix SECURITY_HOTSPOT only
  - `coverage` — improve test coverage only
  - `both` — fix issues + improve coverage (default; hotspots excluded)
  - `all` — fix issues + fix hotspots + improve coverage
- `output_dir` - Optional: directory path for storing temporary files (default: `/tmp/{PROJECT_KEY}_sonar`)

## Workflow

### Complete Orchestration Flow

```
/sonarqube-remediate skill
│
├─ [mode includes 'issues']
│  ├─ Phase 2a: Fetcher (issues) — sequential
│  ├─ Phase 2b: Fixers (parallel) → each fixer spawns validator with its result
│  ├─ Phase 3: Collect issue results
│  └─ Phase 4: Report issues
│
├─ [mode includes 'hotspots']
│  ├─ Phase 2c: Fetcher (hotspots) — sequential
│  ├─ Phase 2d: Hotspot Fixers (parallel) → each spawns validator
│  ├─ Phase 3b: Collect hotspot results
│  └─ Phase 4b: Report hotspots
│
├─ [mode includes 'coverage']
│  └─ Phase 5: Coverage loop (max 3 iterations)
│     ├─ 5a: Fetcher (coverage) — sequential
│     ├─ 5b: Coverage-writers (parallel) → each spawns validator
│     ├─ 5c: Collect coverage results
│     └─ 5d: Check target → loop or stop
│
└─ Phase 6: Final combined report
```

Issues run before hotspots, and both run before coverage.
Issue/hotspot fixes may change code that coverage tests exercise, so coverage runs last.

### Phase 1: Parse and Setup

1. Extract project key and SonarQube URL from the provided URL
2. Confirm environment variables are set
3. Resolve `OUTPUT_DIR`:
   - If user provides `output_dir` argument: use that value
   - Otherwise: `/tmp/{PROJECT_KEY}_sonar`
4. Ensure `OUTPUT_DIR` exists: pass it to the spawned fetcher agent which will run `mkdir -p`

### Phase 2: Two-Phase Spawn

**Phase 2a: Spawn Fetcher (Sequential)**

Spawn the fetcher first and wait for completion:

```
subagent_type: sonarqube-fetcher
prompt: "Fetch SonarQube issues from {PROJECT_KEY} at {SONARQUBE_URL}. Types: {types}. Severities: {severities}. Create batch files by type+severity. OUTPUT_DIR={OUTPUT_DIR}. Write batch files to {OUTPUT_DIR}/batches/ and combos to {OUTPUT_DIR}/combos.json."
```

Wait for fetcher to complete. This ensures we know exactly which type+severity combinations have issues before spawning fixers.

**Phase 2b: Read Combos and Spawn Fixers (Parallel)**

After fetcher completes:
1. Read `{OUTPUT_DIR}/combos.json`
2. Extract active type+severity combinations with their `task_ids`
3. For each active combo, spawn one fixer **per batch** in parallel (background sub-agents)
4. As each fixer returns its result, immediately spawn a validator with the fixer's result in the spawn prompt

```
subagent_type: sonarqube-fixer
prompt: "Fix {TYPE} {SEVERITY} SonarQube issues for project {PROJECT_KEY}. Read your batch from {OUTPUT_DIR}/batches/{task_id}.json. Apply fixes according to approval policy. Return your results when done."
```

```
subagent_type: sonarqube-validator
prompt: "Validate the following batch result for project {PROJECT_KEY}:
BATCH_RESULT={fixer_result_json}
Run build, tests, and SonarQube analysis. Commit on success using git-commit-workflow skill. Return your validation result."
```

Example: If combos.json shows:
- BUG: BLOCKER (2 batches: `bug-blocker-batch-1`, `bug-blocker-batch-2`), CRITICAL (1 batch)
- VULNERABILITY: CRITICAL (1 batch)
- CODE_SMELL: MAJOR (4 batches), MINOR (2 batches)

Then spawn:
- 2 fixers for BUG/BLOCKER (one per batch)
- 1 fixer for BUG/CRITICAL
- 1 fixer for VULNERABILITY/CRITICAL
- 4 fixers for CODE_SMELL/MAJOR
- 2 fixers for CODE_SMELL/MINOR
- As each fixer returns → spawn 1 validator per fixer result

Total: 10 fixers, up to 10 validators running in parallel

### Phase 3: Collect Issue Results

Collect the return values from all fixer and validator sub-agents as they complete.
Report progress as results come in:

```
Progress Update:

VULNERABILITY:
  CRITICAL: 1/1 batches done

BUG:
  BLOCKER:  1/2 batches done
  CRITICAL: 0/1 batches done

CODE_SMELL:
  MAJOR: 2/4 batches done
  MINOR: 1/2 batches done
```

### Phase 4: Issue Report (when mode includes 'issues')

When all issue fixer and validator sub-agents have returned results:
1. Aggregate results from all validator return values
2. Present interim summary with type+severity breakdown
3. If mode is `issues` only, complete. Otherwise continue to next phase.

### Phase 2c: Spawn Fetcher for Hotspots (when mode includes 'hotspots')

**Only run this phase when all issue tasks (Phase 2b–4) are complete, or when mode is `hotspots`.**

Spawn the fetcher in hotspot mode and wait for completion:

```
subagent_type: sonarqube-fetcher
prompt: "Fetch SECURITY_HOTSPOT issues from project {PROJECT_KEY} at {SONARQUBE_URL}.
MODE=hotspots. Query api/hotspots/search for status=TO_REVIEW hotspots.
Group by vulnerabilityProbability (HIGH/MEDIUM/LOW). Write batch files to {OUTPUT_DIR}/batches/.
OUTPUT_DIR={OUTPUT_DIR}. Write hotspot section to {OUTPUT_DIR}/combos.json."
```

Wait for fetcher to complete before spawning hotspot fixers.

### Phase 2d: Spawn Hotspot Fixers + Validators (when mode includes 'hotspots')

After fetcher completes:
1. Read `{OUTPUT_DIR}/combos.json`
2. Extract `hotspots.by_priority` with `task_ids`
3. For each priority level, spawn one fixer per batch in parallel (background sub-agents)
4. As each fixer returns, immediately spawn a validator with the fixer's result

```
subagent_type: sonarqube-fixer
prompt: "Fix SECURITY_HOTSPOT {HIGH|MEDIUM|LOW} issues for project {PROJECT_KEY}.
Read your batch from {OUTPUT_DIR}/batches/{task_id}.json.
Apply fixes per approval policy. Return your results when done."
```

```
subagent_type: sonarqube-validator
prompt: "Validate the following batch result for project {PROJECT_KEY}:
BATCH_RESULT={fixer_result_json}
Run build, tests, and SonarQube analysis. For SECURITY_HOTSPOT tasks, call api/hotspots/changeStatus for each hotspot_key. Commit on success. Return your validation result."
```

Example: If combos.json hotspots section shows:
- HIGH: 5 hotspots (1 batch: `hotspot-high-batch-1`)
- MEDIUM: 12 hotspots (2 batches)
- LOW: 8 hotspots (1 batch)

Then spawn:
- 1 fixer for SECURITY_HOTSPOT/HIGH
- 2 fixers for SECURITY_HOTSPOT/MEDIUM
- 1 fixer for SECURITY_HOTSPOT/LOW
- As each fixer returns → spawn 1 validator per fixer result

### Phase 3b: Collect Hotspot Results

Collect the return values from all hotspot fixer and validator sub-agents as they complete:

```
Hotspot Progress Update:

SECURITY_HOTSPOT:
  HIGH:   1/1 batches done
  MEDIUM: 1/2 batches done
  LOW:    0/1 batches done
```

### Phase 4b: Hotspot Report (when mode includes 'hotspots')

When all hotspot fixer and validator sub-agents have returned results:
1. Aggregate results from all validator return values
2. Present interim hotspot summary
3. If mode is `hotspots` only, complete. Otherwise continue to Phase 5.

### Phase 5: Coverage Improvement (when mode includes 'coverage')

**Phase 5a: Fetch Coverage Data (Sequential)**

Spawn fetcher in coverage mode:
```
subagent_type: sonarqube-fetcher
prompt: "Fetch coverage data for project {PROJECT_KEY}. MODE=coverage. COVERAGE_TARGET={coverage_target}. OUTPUT_DIR={OUTPUT_DIR}. Query coverage API, create coverage batch files for files below target, write to {OUTPUT_DIR}/batches/ and {OUTPUT_DIR}/combos.json."
```

Wait for fetcher to complete.

**Phase 5b: Spawn Coverage Writers and Validators (Parallel)**

After fetcher completes:
1. Read `{OUTPUT_DIR}/combos.json`
2. Extract coverage batches with `task_ids`
3. Spawn one coverage-writer per batch in parallel (up to 10 parallel)
4. As each coverage-writer returns its result, immediately spawn a validator with the result

```
subagent_type: sonarqube-coverage-writer
prompt: "Process coverage batch for project {PROJECT_KEY}. Read your batch from {OUTPUT_DIR}/batches/{task_id}.json. Analyze source files, write tests for uncovered lines. Return your results when done."
```

```
subagent_type: sonarqube-validator
prompt: "Validate the following coverage batch result for project {PROJECT_KEY}:
BATCH_RESULT={writer_result_json}
Run build, tests, and coverage verification. Commit on success. Return your validation result."
```

**Phase 5c: Collect Coverage Results**

Collect return values from all coverage-writer and validator sub-agents as they complete.
Report progress: `{done}/{total} coverage batches complete`

**Phase 5d: Check Target and Iterate**

When all coverage sub-agents have returned results:
1. Query project coverage from SonarQube API
2. Compare against target:
   - If coverage >= target: **DONE** → Phase 6
   - If coverage < target AND improved by > 2%: Loop to Phase 5a (next iteration)
   - If coverage < target AND improved by <= 2%: **STOP** (plateau detected) → Phase 6

**Max 3 iterations to prevent infinite loops.**

### Phase 6: Final Report

When all phases complete:
1. Aggregate results from all validator return values (issues and coverage)
2. Present combined final summary

## Final Report Format

**When mode is 'issues':**
```
══════════════════════════════════════════
SonarQube Remediation Complete
══════════════════════════════════════════

VULNERABILITY:
  BLOCKER:  {fixed} fixed, {manual} manual review, {failed} failed
  CRITICAL: {fixed} fixed, {manual} manual review, {failed} failed

BUG:
  BLOCKER:  {fixed} fixed, {manual} manual review, {failed} failed
  CRITICAL: {fixed} fixed, {manual} manual review, {failed} failed
  MAJOR:    {fixed} fixed, {manual} manual review, {failed} failed

CODE_SMELL:
  BLOCKER:  {fixed} fixed, {manual} manual review, {failed} failed
  CRITICAL: {fixed} fixed, {manual} manual review, {failed} failed
  MAJOR:    {fixed} fixed, {manual} manual review, {failed} failed
  MINOR:    {fixed} fixed, {manual} manual review, {failed} failed
  INFO:     {fixed} fixed, {manual} manual review, {failed} failed

──────────────────────────────────────────
Totals:
  Fixed: {total_fixed}
  Manual Review Required: {total_manual}
  Failed: {total_failed}
  Success Rate: {rate}%
──────────────────────────────────────────

Commits: {count}

Failed Batches:
{batch_id}: {reason}

Note: This workflow commits to the current branch. It does NOT create a new branch automatically. If you want to create a branch, do so manually before running this workflow.

Next steps: git push origin <current-branch>
══════════════════════════════════════════
```

**When mode is 'coverage':**
```
══════════════════════════════════════════
SonarQube Coverage Improvement Complete
══════════════════════════════════════════

Coverage Improvement:
  Before: {start_coverage}%
  After:  {end_coverage}%
  Target: {target}%
  Status: ACHIEVED | IMPROVED | PLATEAU
  Iterations: {n}
  Files processed: {count}
  Batches: {successful}/{total} successful

Test Files:
  Created: {count}
  Modified: {count}
  Total new tests: {count}

──────────────────────────────────────────
Totals:
  Files covered: {total_files}
  Coverage improvement: +{improvement}%
  Success Rate: {rate}%
──────────────────────────────────────────

Commits: {count}

Failed Batches:
{batch_id}: {reason}

Note: This workflow commits to the current branch. It does NOT create a new branch automatically. If you want to create a branch, do so manually before running this workflow.

Next steps: git push origin <current-branch>
══════════════════════════════════════════
```

**When mode is 'hotspots':**
```
══════════════════════════════════════════
SonarQube Security Hotspot Fix Complete
══════════════════════════════════════════

SECURITY_HOTSPOT:
  HIGH:   {fixed} fixed, {manual} manual review, {failed} failed
  MEDIUM: {fixed} fixed, {manual} manual review, {failed} failed
  LOW:    {fixed} fixed, {manual} manual review, {failed} failed

Hotspot Status Updates in SonarQube:
  Marked REVIEWED/FIXED: {count}
  Skipped (API error):   {count}

──────────────────────────────────────────
Totals:
  Fixed: {total_fixed}
  Manual Review Required: {total_manual}
  Failed: {total_failed}
  Success Rate: {rate}%
──────────────────────────────────────────

Commits: {count}

Failed Batches:
{batch_id}: {reason}

Note: This workflow commits to the current branch. It does NOT create a new branch automatically. If you want to create a branch, do so manually before running this workflow.

Next steps: git push origin <current-branch>
══════════════════════════════════════════
```

**When mode is 'both':**
```
══════════════════════════════════════════
SonarQube Remediation & Coverage Complete
══════════════════════════════════════════

[Issues]
VULNERABILITY:
  BLOCKER:  {fixed} fixed, {failed} failed
  CRITICAL: {fixed} fixed, {failed} failed

BUG:
  BLOCKER:  {fixed} fixed, {failed} failed
  CRITICAL: {fixed} fixed, {failed} failed
  MAJOR:    {fixed} fixed, {failed} failed

CODE_SMELL:
  BLOCKER:  {fixed} fixed, {failed} failed
  CRITICAL: {fixed} fixed, {failed} failed
  MAJOR:    {fixed} fixed, {failed} failed
  MINOR:    {fixed} fixed, {failed} failed

[Coverage]
Coverage Improvement:
  Before: {start}%
  After:  {end}%
  Target: {target}%
  Status: ACHIEVED | IMPROVED | PLATEAU
  Iterations: {n}
  Test files created: {count}
  Test files modified: {count}

──────────────────────────────────────────
Totals:
  Issues fixed: {total_fixed}
  Files covered: {total_files}
  Commits: {count}
  Success Rate: {rate}%
──────────────────────────────────────────

Note: This workflow commits to the current branch. It does NOT create a new branch automatically. If you want to create a branch, do so manually before running this workflow.

Next steps: git push origin <current-branch>
══════════════════════════════════════════
```

**When mode is 'all':**
```
══════════════════════════════════════════
SonarQube Full Remediation Complete
══════════════════════════════════════════

[Issues]
VULNERABILITY:
  BLOCKER:  {fixed} fixed, {failed} failed
  CRITICAL: {fixed} fixed, {failed} failed

BUG:
  BLOCKER:  {fixed} fixed, {failed} failed
  CRITICAL: {fixed} fixed, {failed} failed
  MAJOR:    {fixed} fixed, {failed} failed

CODE_SMELL:
  BLOCKER:  {fixed} fixed, {failed} failed
  CRITICAL: {fixed} fixed, {failed} failed
  MAJOR:    {fixed} fixed, {failed} failed
  MINOR:    {fixed} fixed, {failed} failed

[Hotspots]
SECURITY_HOTSPOT:
  HIGH:   {fixed} fixed, {manual} manual review, {failed} failed
  MEDIUM: {fixed} fixed, {manual} manual review, {failed} failed
  LOW:    {fixed} fixed, {manual} manual review, {failed} failed

Hotspot Status Updates: {updated} marked REVIEWED/FIXED in SonarQube

[Coverage]
Coverage Improvement:
  Before: {start}%
  After:  {end}%
  Target: {target}%
  Status: ACHIEVED | IMPROVED | PLATEAU
  Iterations: {n}
  Test files created: {count}
  Test files modified: {count}

──────────────────────────────────────────
Totals:
  Issues fixed: {total_issues_fixed}
  Hotspots fixed: {total_hotspots_fixed}
  Files covered: {total_files_covered}
  Commits: {count}
  Success Rate: {rate}%
──────────────────────────────────────────

Note: This workflow commits to the current branch. It does NOT create a new branch automatically. If you want to create a branch, do so manually before running this workflow.

Next steps: git push origin <current-branch>
══════════════════════════════════════════
```

## Error Handling

**General:**
- If fetcher fails: Report error, suggest checking SonarQube URL/token
- If combos.json missing: Fall back to spawning all type+severity combinations specified
- If fixer needs human input: They use AskUser directly
- If validator fails: Note the batch as failed, continue with others

**Coverage-specific:**
- If no coverage data available: Report "Project has no coverage data in SonarQube"
- If all files already meet target: Report "All files already meet coverage target of X%"
- If coverage plateaus after 3 iterations: Report "Coverage improvement plateau detected after 3 iterations"
- If coverage-writer fails: Note the batch as failed, validator will skip it
- If coverage unchanged after tests pass: Diagnostic in validator report

**Hotspot-specific:**
- If fetcher gets 403 on hotspots API: Report "Insufficient permissions to list security hotspots"
- If no TO_REVIEW hotspots found: Report "No unreviewed security hotspots found for project"
- If combos.json has no hotspots section: Report warning, skip hotspot phase
- If validator gets 403 on changeStatus: Log warning per hotspot, commit code fix anyway (partial approve)

## Example Usage

**Fix all issue types and severities:**
```
User: "Fix SonarQube issues for https://sonarcloud.io/project/issues?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher → writes batch files + combos.json
3. Read combos.json → identify active combinations + task_ids
4. Spawn one fixer per batch (parallel) → fixers read batch files, return results
5. As each fixer returns → spawn validator with fixer's result
6. Collect all validator results → report progress
7. Complete → present final report
```

**Fix only security issues (BUG + VULNERABILITY):**
```
User: "Fix SonarQube bugs and vulnerabilities for https://sonarcloud.io/project/issues?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with types=BUG,VULNERABILITY
3. Read combos.json + batch files
4. Spawn fixers for BUG/VULNERABILITY batches only
5. As each fixer returns → spawn validator
6. Complete
```

**Fix only BLOCKER and CRITICAL severities:**
```
User: "Fix BLOCKER and CRITICAL SonarQube issues for https://sonarcloud.io/project/issues?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with severities=BLOCKER,CRITICAL
3. Read combos.json + batch files
4. Spawn fixers for BLOCKER/CRITICAL batches across all types
5. As each fixer returns → spawn validator
6. Complete
```

**Combined filter:**
```
User: "Fix VULNERABILITY issues with BLOCKER or CRITICAL severity"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with types=VULNERABILITY, severities=BLOCKER,CRITICAL
3. Read combos.json
4. Spawn fixers for VULNERABILITY/BLOCKER and VULNERABILITY/CRITICAL batches
5. As each fixer returns → spawn validator
6. Complete
```

**Improve test coverage only:**
```
User: "Improve test coverage for https://sonarcloud.io/project/overview?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with mode=coverage, coverage_target=91
   → Writes coverage batch files + combos.json
3. Read combos.json → identify coverage batches
4. Spawn coverage-writers per batch (up to 10 parallel)
5. As each writer returns → spawn validator with result
6. Collect results → check coverage → if improved but below target, iterate (max 3 times)
7. Complete → present coverage report
```

**Combined: Fix issues AND improve coverage:**
```
User: "Fix SonarQube issues and improve coverage for https://sonarcloud.io/project/overview?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Phase 2a: Spawn fetcher with mode=both, coverage_target=91
3. Phase 2b: Read combos.json → spawn issue fixers per batch → as each returns spawn validator
4. Phase 4: Wait for all issue validators → report issue completion
5. Phase 5: Coverage iteration loop
   5a: Spawn fetcher for coverage data
   5b: Spawn coverage-writers per batch → as each returns spawn validator
   5c: Collect results
   5d: Check target → loop or stop
6. Phase 6: Present combined final report
```

**Custom coverage target:**
```
User: "Improve coverage to 85% for https://sonarcloud.io/project/overview?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with mode=coverage, coverage_target=85
3. Spawn coverage-writers per batch → as each returns spawn validator
4. Iterate until 85% reached or plateau
5. Complete → present coverage report
```

**Fix security hotspots only:**
```
User: "Fix security hotspots for https://sonarqubev8.jatismobile.com/dashboard?id=JNS-6.5-DR-Mitracomm-Checker"

Execution:
1. Parse URL → project_key=JNS-6.5-DR-Mitracomm-Checker, mode=hotspots
2. Spawn fetcher with types=SECURITY_HOTSPOT
   → Query api/hotspots/search?status=TO_REVIEW
   → Write batch files by vulnerabilityProbability (HIGH/MEDIUM/LOW)
3. Read combos.json → identify HIGH/MEDIUM/LOW priority batches
4. Spawn one fixer per batch (parallel)
5. As each fixer returns → spawn validator (with hotspot_keys for changeStatus)
6. Collect results → report progress
7. Complete → present hotspot report
```

**Fix everything: issues + hotspots + coverage:**
```
User: "Fix all SonarQube issues, hotspots, and improve coverage for https://sonarcloud.io/project/overview?id=myproject"

Execution:
1. Parse URL → project_key=myproject, mode=all
2. Phase 2a: Spawn fetcher (issues) → batch files written
3. Phase 2b: Spawn issue fixers per batch → as each returns spawn validator
4. Phase 4: Wait for all issue validators → report issue completion
5. Phase 2c: Spawn fetcher (hotspots) → hotspot batch files written
6. Phase 2d: Spawn hotspot fixers per batch → as each returns spawn validator
7. Phase 4b: Wait for all hotspot validators → report hotspot completion
8. Phase 5: Coverage loop
   5a: Spawn fetcher (coverage)
   5b: Spawn coverage-writers per batch → as each returns spawn validator
   5c: Collect results
   5d: Check target → loop or stop (max 3 iterations)
9. Phase 6: Present combined full report
```
