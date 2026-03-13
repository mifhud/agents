---
name: sonarqube-remediate
description: Team-lead skill for coordinating SonarQube issue remediation and test coverage improvement using parallel agent teams.
---

# SonarQube Remediate

Team-lead skill for coordinating SonarQube issue remediation (BUG, VULNERABILITY, CODE_SMELL) and test coverage improvement using parallel agent teams. This skill is executed directly by the main Claude Code session (not a sub-agent).

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
│  ├─ Phase 2b: Fixers + Validator — parallel
│  ├─ Phase 3: Monitor issues
│  └─ Phase 4: Report issues
│
├─ [mode includes 'hotspots']
│  ├─ Phase 2c: Fetcher (hotspots) — sequential
│  ├─ Phase 2d: Hotspot Fixers + Validator — parallel
│  ├─ Phase 3b: Monitor hotspots
│  └─ Phase 4b: Report hotspots
│
├─ [mode includes 'coverage']
│  └─ Phase 5: Coverage loop (max 3 iterations)
│     ├─ 5a: Fetcher (coverage) — sequential
│     ├─ 5b: Coverage-writers + Validator — parallel
│     ├─ 5c: Monitor coverage tasks
│     └─ 5d: Check target → loop or stop
│
└─ Phase 6: Final combined report
```

Issues run before hotspots, and both run before coverage.
Issue/hotspot fixes may change code that coverage tests exercise, so coverage runs last.

### Phase 1: Parse and Setup

1. Extract project key and SonarQube URL from the provided URL
2. Confirm environment variables are set
3. Create a task list to track batches (the task tool manages this automatically)
4. Resolve `OUTPUT_DIR`:
   - If user provides `output_dir` argument: use that value
   - Otherwise: `/tmp/{PROJECT_KEY}_sonar`
5. Ensure `OUTPUT_DIR` exists: pass it to the spawned fetcher agent which will run `mkdir -p`

### Phase 2: Two-Phase Spawn

**Phase 2a: Spawn Fetcher (Sequential)**

Spawn the fetcher first and wait for completion:

```
subagent_type: sonarqube-fetcher
prompt: "Fetch SonarQube issues from {PROJECT_KEY} at {SONARQUBE_URL}. Types: {types}. Severities: {severities}. Create batch tasks by type+severity. OUTPUT_DIR={OUTPUT_DIR}. Write combos to {OUTPUT_DIR}/combos.json."
```

Wait for fetcher to complete. This ensures we know exactly which type+severity combinations have issues before spawning fixers.

**Phase 2b: Read Combos and Spawn Fixers (Parallel)**

After fetcher completes:
1. Read `{OUTPUT_DIR}/combos.json`
2. Extract active type+severity combinations
3. Spawn one fixer per active combo (in parallel)
4. Spawn one validator (in parallel with fixers)

```
subagent_type: sonarqube-fixer
prompt: "Fix {TYPE} {SEVERITY} SonarQube issues for project {PROJECT_KEY}. Poll the shared task list for ready_to_fix tasks matching type={TYPE} and severity={SEVERITY}. Apply fixes according to approval policy. Mark tasks ready_to_validate when done."
```

Example: If combos.json shows:
- BUG: BLOCKER (2 batches), CRITICAL (1 batch)
- VULNERABILITY: CRITICAL (1 batch)
- CODE_SMELL: MAJOR (4 batches), MINOR (2 batches)

Then spawn:
- 1 fixer for BUG/BLOCKER
- 1 fixer for BUG/CRITICAL
- 1 fixer for VULNERABILITY/CRITICAL
- 1 fixer for CODE_SMELL/MAJOR
- 1 fixer for CODE_SMELL/MINOR
- 1 validator

Total: 5 fixers + 1 validator = 6 agents (instead of up to 15)

### Phase 3: Monitor Progress

Poll the task list periodically to track status:
- `pending` - Awaiting fetch
- `fetching` - Fetcher retrieving details
- `ready_to_fix` - Ready for fixer
- `fixing` - Fixer working
- `ready_to_validate` - Ready for validator
- `validating` - Validator running checks
- `done` - Successfully committed
- `failed` - Validation failed

Report progress grouped by type → severity:
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

When all issue tasks are `done` or `failed`:
1. Gather results from task list
2. Present interim summary with type+severity breakdown
3. If mode is `issues` only, complete. Otherwise continue to next phase.

### Phase 2c: Spawn Fetcher for Hotspots (when mode includes 'hotspots')

**Only run this phase when all issue tasks (Phase 2b–4) are complete, or when mode is `hotspots`.**

Spawn the fetcher in hotspot mode and wait for completion:

```
subagent_type: sonarqube-fetcher
prompt: "Fetch SECURITY_HOTSPOT issues from project {PROJECT_KEY} at {SONARQUBE_URL}.
MODE=hotspots. Query api/hotspots/search for status=TO_REVIEW hotspots.
Group by vulnerabilityProbability (HIGH/MEDIUM/LOW). Create batch tasks.
OUTPUT_DIR={OUTPUT_DIR}. Write hotspot section to {OUTPUT_DIR}/combos.json."
```

Wait for fetcher to complete before spawning hotspot fixers.

### Phase 2d: Spawn Hotspot Fixers + Validator (when mode includes 'hotspots')

After fetcher completes:
1. Read `{OUTPUT_DIR}/combos.json`
2. Extract `hotspots.by_priority` from the hotspots section
3. Spawn one fixer per active priority level (up to 3 fixers: HIGH, MEDIUM, LOW)
4. Spawn one validator (in parallel with fixers)

```
subagent_type: sonarqube-fixer
prompt: "Fix SECURITY_HOTSPOT {HIGH|MEDIUM|LOW} issues for project {PROJECT_KEY}.
TYPE=SECURITY_HOTSPOT, SEVERITY={HIGH|MEDIUM|LOW}.
Poll shared task list for ready_to_fix tasks matching type=SECURITY_HOTSPOT and severity={HIGH|MEDIUM|LOW}.
Apply fixes per approval policy. Mark tasks ready_to_validate when done."
```

Example: If combos.json hotspots section shows:
- HIGH: 5 hotspots (1 batch)
- MEDIUM: 12 hotspots (2 batches)
- LOW: 8 hotspots (1 batch)

Then spawn:
- 1 fixer for SECURITY_HOTSPOT/HIGH
- 1 fixer for SECURITY_HOTSPOT/MEDIUM
- 1 fixer for SECURITY_HOTSPOT/LOW
- 1 validator

Total: 3 fixers + 1 validator = 4 agents

### Phase 3b: Monitor Hotspot Progress

Poll the task list for SECURITY_HOTSPOT tasks:

```
Hotspot Progress Update:

SECURITY_HOTSPOT:
  HIGH:   1/1 batches done
  MEDIUM: 1/2 batches done
  LOW:    0/1 batches done
```

### Phase 4b: Hotspot Report (when mode includes 'hotspots')

When all hotspot tasks are `done` or `failed`:
1. Gather results from task list (filter by type=SECURITY_HOTSPOT)
2. Present interim hotspot summary
3. If mode is `hotspots` only, complete. Otherwise continue to Phase 5.

### Phase 5: Coverage Improvement (when mode includes 'coverage')

**Phase 5a: Fetch Coverage Data (Sequential)**

Spawn fetcher in coverage mode:
```
subagent_type: sonarqube-fetcher
prompt: "Fetch coverage data for project {PROJECT_KEY}. MODE=coverage. COVERAGE_TARGET={coverage_target}. OUTPUT_DIR={OUTPUT_DIR}. Query coverage API, create coverage batch tasks for files below target, write to {OUTPUT_DIR}/combos.json."
```

Wait for fetcher to complete.

**Phase 5b: Spawn Coverage Writers and Validator (Parallel)**

After fetcher completes:
1. Read `{OUTPUT_DIR}/combos.json`
2. Extract coverage batches
3. Spawn one coverage-writer per batch (up to 10 parallel)
4. Spawn one validator (parallel with writers)

```
subagent_type: sonarqube-coverage-writer
prompt: "Process coverage batch for project {PROJECT_KEY}. Poll shared task list for ready_to_fix tasks matching type=COVERAGE. Analyze source files, write tests for uncovered lines, mark tasks ready_to_validate when done."
```

**Phase 5c: Monitor Coverage Tasks**

Poll the task list to track coverage task status:
- Report progress: `{done}/{total} coverage batches complete`
- Note coverage improvements per batch

**Phase 5d: Check Target and Iterate**

When all coverage tasks complete:
1. Query project coverage from SonarQube API
2. Compare against target:
   - If coverage >= target: **DONE** → Phase 6
   - If coverage < target AND improved by > 2%: Loop to Phase 5a (next iteration)
   - If coverage < target AND improved by <= 2%: **STOP** (plateau detected) → Phase 6

**Max 3 iterations to prevent infinite loops.**

### Phase 6: Final Report

When all phases complete:
1. Gather results from all tasks (issues and coverage)
2. Present combined final summary
3. Clean up (teammate sessions end automatically)

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

Note: This workflow commits to the current branch. It does NOT create a new branch automatically.

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

Note: This workflow commits to the current branch. It does NOT create a new branch automatically.

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

Note: This workflow commits to the current branch. It does NOT create a new branch automatically.

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

Note: This workflow commits to the current branch. It does NOT create a new branch automatically.

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

Note: This workflow commits to the current branch. It does NOT create a new branch automatically.

Next steps: git push origin <current-branch>
══════════════════════════════════════════
```

## Error Handling

**General:**
- If fetcher fails: Report error, suggest checking SonarQube URL/token
- If combos.json missing: Fall back to spawning all type+severity combinations specified
- If fixer needs human input: They use AskUser directly
- If validator fails: Note the batch as failed, continue with others
- If teammate stops unexpectedly: Spawn a replacement

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
2. Spawn fetcher → creates batches for all types+severities with issues
3. Read combos.json → identify active combinations
4. Spawn fixers for each active type+severity → process batches
5. Spawn validator → validates and commits
6. Monitor → report progress
7. Complete → present final report
```

**Fix only security issues (BUG + VULNERABILITY):**
```
User: "Fix SonarQube bugs and vulnerabilities for https://sonarcloud.io/project/issues?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with types=BUG,VULNERABILITY
3. Read combos.json
4. Spawn fixers for BUG/VULNERABILITY combinations only
5. Spawn validator
6. Complete
```

**Fix only BLOCKER and CRITICAL severities:**
```
User: "Fix BLOCKER and CRITICAL SonarQube issues for https://sonarcloud.io/project/issues?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with severities=BLOCKER,CRITICAL
3. Read combos.json
4. Spawn fixers for BLOCKER/CRITICAL across all types
5. Spawn validator
6. Complete
```

**Combined filter:**
```
User: "Fix VULNERABILITY issues with BLOCKER or CRITICAL severity"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with types=VULNERABILITY, severities=BLOCKER,CRITICAL
3. Read combos.json
4. Spawn at most 2 fixers (VULNERABILITY/BLOCKER, VULNERABILITY/CRITICAL)
5. Spawn validator
6. Complete
```

**Improve test coverage only:**
```
User: "Improve test coverage for https://sonarcloud.io/project/overview?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with mode=coverage, coverage_target=91
   → Query coverage API, creates coverage batches for files below target
3. Read combos.json → identify coverage batches
4. Spawn coverage-writers per batch (up to 10 parallel)
5. Spawn validator (parallel with writers)
6. Monitor coverage tasks → report progress
7. Check coverage → if improved but below target, iterate (max 3 times)
8. Complete → present coverage report
```

**Combined: Fix issues AND improve coverage:**
```
User: "Fix SonarQube issues and improve coverage for https://sonarcloud.io/project/overview?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with mode=both, coverage_target=91
   → Creates issue batches AND coverage batches
3. Read combos.json → identify all combinations
4. Phase 2: Spawn fixers for issue types → process all issue batches
5. Phase 4: Report issue completion
6. Phase 5: Coverage iteration loop
   5a: Spawn fetcher for coverage data (current metrics)
   5b: Spawn coverage-writers per batch
   5c: Monitor and validate coverage tasks
   5d: Check target → loop or stop
7. Phase 6: Present combined final report
```

**Custom coverage target:**
```
User: "Improve coverage to 85% for https://sonarcloud.io/project/overview?id=myproject"

Execution:
1. Parse URL → project_key=myproject
2. Spawn fetcher with mode=coverage, coverage_target=85
3. Process coverage batches until 85% target reached or plateau
4. Complete → present coverage report
```

**Fix security hotspots only:**
```
User: "Fix security hotspots for https://sonarqubev8.jatismobile.com/dashboard?id=JNS-6.5-DR-Mitracomm-Checker"

Execution:
1. Parse URL → project_key=JNS-6.5-DR-Mitracomm-Checker, mode=hotspots
2. Spawn fetcher with types=SECURITY_HOTSPOT
   → Query api/hotspots/search?status=TO_REVIEW
   → Create batches by vulnerabilityProbability (HIGH/MEDIUM/LOW)
3. Read combos.json → identify HIGH/MEDIUM/LOW priority buckets
4. Spawn up to 3 fixers (one per priority level)
5. Spawn validator → validates, commits, and marks REVIEWED/FIXED in SonarQube
6. Monitor → report progress
7. Complete → present hotspot report
```

**Fix everything: issues + hotspots + coverage:**
```
User: "Fix all SonarQube issues, hotspots, and improve coverage for https://sonarcloud.io/project/overview?id=myproject"

Execution:
1. Parse URL → project_key=myproject, mode=all
2. Phase 2a: Spawn fetcher (issues) → issue batches
3. Phase 2b: Spawn issue fixers + validator → process issue batches
4. Phase 4: Report issue completion
5. Phase 2c: Spawn fetcher (hotspots) → hotspot batches
6. Phase 2d: Spawn hotspot fixers + validator → process hotspot batches
7. Phase 4b: Report hotspot completion
8. Phase 5: Coverage loop
   5a: Spawn fetcher (coverage)
   5b: Spawn coverage-writers + validator
   5c: Monitor and validate
   5d: Check target → loop or stop (max 3 iterations)
9. Phase 6: Present combined full report
```
