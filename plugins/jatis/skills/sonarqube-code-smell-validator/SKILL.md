---
name: sonarqube-code-smell-fixer
description: >-
  Remediates SonarQube code smells automatically with severity-first priority.
  Orchestrates fetching, fixing, validating, and committing in batches.
  Use when the user provides a SonarQube URL, mentions SonarQube code smells,
  asks to clean up code quality issues, or invokes /sonar-fix.
---

# SonarQube Code Smell Remediation Orchestrator

Delegates work to three subagents: `sonar-fetcher`, `sonar-fixer`, and
`sonar-validator`. Loads the `git-workflow` skill when committing fixes.

## Core principle: severity-first

Complete ONE severity fully before moving to the next. Never mix severities.

```
BLOCKER → Fix all → Validate → Commit → Verify count = 0
  ↓ only then
CRITICAL → Fix all → Validate → Commit → Verify count = 0
  ↓ only then
MAJOR → … → MINOR → … → INFO
```

## Input

The user provides a SonarQube URL. Extract it exactly as given.

```
/sonar-fix https://sonarqube.company.com/project/issues?id=MY-PROJECT&types=CODE_SMELL
```

## Workflow

### Phase 1: Fetch issues

Delegate to `sonar-fetcher` with the user-provided URL. The fetcher returns
severity counts and issue details. Start with the highest non-zero severity.

### Phase 2: Process one severity completely

Work in batches. See [batch-sizes.md](batch-sizes.md) for sizing guidelines.

**For each batch:**

1. **Fix** — Delegate to `sonar-fixer` with issue keys, file paths, line
   numbers, rule keys, and messages.
2. **Validate** — Delegate to `sonar-validator`.
3. **Handle result:**
   - **APPROVED** — Load `git-workflow` skill and commit. BLOCKER/CRITICAL get
     individual commits; MAJOR and below can be grouped.
   - **REJECTED** — Revert changes, document failed issues, continue to next
     batch.
4. **Report progress** — e.g. `BLOCKER Progress: 5/8 fixed (batch 1/2 complete)`

**After all batches for this severity:**

5. **Verify completion** — Re-fetch with `&severities=<SEVERITY>`. If count > 0,
   document remaining issues as manual review and ask whether to continue.

### Phase 3: Repeat for all severities

Progress through BLOCKER → CRITICAL → MAJOR → MINOR → INFO.

### Phase 4: Final summary

```
══════════════════════════════════════════
SonarQube Remediation Complete
══════════════════════════════════════════

BLOCKER:  8 fixed, 0 remaining, 0 manual
CRITICAL: 23 fixed, 0 remaining, 2 manual
MAJOR:    15 fixed, 0 remaining, 0 manual
MINOR:    2 fixed, 0 remaining, 0 manual
INFO:     0 fixed, 0 remaining, 0 manual

Total Fixed: 48 | Manual Review: 2 | Success Rate: 96%

Manual Review Issues:
1. AXY134 [CRITICAL] Complex auth logic — needs architect review
2. AXY145 [CRITICAL] DB transaction pattern — needs team discussion

Git branch: fix/sonar-cleanup-YYYYMMDD
Commits: 18

Next steps: git push origin fix/sonar-cleanup-YYYYMMDD → Create PR
══════════════════════════════════════════
```

## Human approval rules

**Before applying ANY fix that changes control flow, business logic, or data
processing, stop and ask the user for approval.**

For the full approval policy, see [human-approval.md](human-approval.md).

## Communication guidelines

- Report progress after every batch and severity transition.
- Use clear status lines: `BLOCKER Progress: 5/8 (63%)`.
- Do not ask for approval on each individual safe fix or standard validation.
