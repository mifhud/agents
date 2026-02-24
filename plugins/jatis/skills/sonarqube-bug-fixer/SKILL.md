---
name: sonarqube-bug-fixer
description: >-
  Remediates SonarQube BUG type issues with mandatory human approval for every fix.
  Organizes fixes by severity (BLOCKER → CRITICAL → MAJOR → MINOR → INFO).
  Delegates validation to sonarqube-bug-validator.
  Use when the user provides a SonarQube URL with types=BUG, mentions fixing bugs,
  or invokes /sonarqube-bug-fixer.
---

# SonarQube Bug Remediation

Fixes SonarQube BUG type issues which represent actual runtime errors,
logic flaws, and potential crashes. **Every bug fix requires explicit human approval**
due to risk of behavioral changes.

## Core principle: severity-first with mandatory approval

Complete ONE severity fully before moving to the next. Never mix severities.
Every bug fix requires explicit approval before application.

```
BLOCKER → Fetch → Present → Approve → Apply → Validate → Commit → Verify = 0
  ↓ only then
CRITICAL → Fetch → Present → Approve → Apply → Validate → Commit → Verify = 0
  ↓ only then
MAJOR → … → MINOR → INFO
```

## Input

The user provides a SonarQube URL. Extract it exactly as given.

```
/sonarqube-bug-fixer https://sonarqube.company.com/project/issues?id=MY-PROJECT&types=BUG
```

## Workflow

### Phase 1: Fetch issues

Delegate to `sonarqube-fetcher` with the user-provided URL and `types: ["BUG"]`.
The fetcher returns severity counts and issue details. Start with the highest non-zero severity.

### Phase 2: Process one severity completely

Work in small batches. See [batch-sizes.md](batch-sizes.md) for sizing guidelines.

**For each bug:**

1. **Analyze** — Read the source file to understand the code context and root cause
2. **Present** — Show the user:
   - Issue key, rule, and severity
   - File path and line number(s)
   - Current code snippet
   - Proposed fix with clear diff
   - Risk assessment (what could break)
   - Confidence level (High/Medium/Low)
3. **Get approval** — Use question tool to ask for explicit approval
4. **Apply fix** — Only after explicit approval
5. **Validate** — Delegate to `sonarqube-bug-validator`
6. **Handle result:**
   - **APPROVED** — Load `git-commit-workflow` skill and commit. Each bug gets individual commit
   - **REJECTED** — Revert changes, document failed issue, continue to next
7. **Report progress** — e.g. `BLOCKER Progress: 2/5 (40%)`

**After all batches for this severity:**

8. **Verify completion** — Re-fetch with `&types=BUG&severities=<SEVERITY>`. If count > 0,
   document remaining issues as manual review and ask whether to continue.

### Phase 3: Repeat for all severities

Progress through BLOCKER → CRITICAL → MAJOR → MINOR → INFO.

### Phase 4: Final summary

```
══════════════════════════════════════════
SonarQube Bug Remediation Complete
══════════════════════════════════════════

BLOCKER:  3 fixed, 0 remaining, 0 manual
CRITICAL: 8 fixed, 1 remaining, 2 manual
MAJOR:    12 fixed, 0 remaining, 1 manual
MINOR:    5 fixed, 0 remaining, 0 manual
INFO:     0 fixed, 0 remaining, 0 manual

Total Fixed: 28 | Manual Review: 3 | Success Rate: 90%

Manual Review Issues:
1. BUG-134 [CRITICAL] Race condition in concurrent access — needs threading expert
2. BUG-145 [CRITICAL] Complex null pointer chain — needs refactoring
3. BUG-201 [MAJOR] Resource leak in external library — vendor issue

Git branch: fix/sonar-bugs-YYYYMMDD
Commits: 28

Next steps: git push origin fix/sonar-bugs-YYYYMMDD → Create PR
══════════════════════════════════════════
```

## Human approval rules

**ALL bug fixes require explicit human approval before application.**

See [human-approval.md](human-approval.md) for the full approval workflow and question format.

## Bug fix examples

For multi-language bug fix patterns, see [example-fixes.md](example-fixes.md).

## Severity guidelines

See [severity-guidelines.md](severity-guidelines.md) for severity-specific handling.

## Communication guidelines

- Report progress after every bug fix and severity transition
- Use clear status lines: `BLOCKER Progress: 2/5 (40%) - awaiting approval`
- Always present fixes with context, diff, and risk assessment
- Never apply fixes without explicit user confirmation
