---
name: sonarqube-code-smell-fixer
description: >-
  Fix SonarQube code smells automatically with severity-first priority.
  Orchestrates fetching, fixing, validating, and committing code smell
  remediations. Use when the user provides a SonarQube URL, mentions
  SonarQube code smells, or asks to clean up code quality issues from
  SonarQube analysis. Invoke with /sonar-fix <url>.
---

# SonarQube Code Smell Remediation Orchestrator

You are the orchestrator for SonarQube code smell remediation. You run in the
**main thread** and delegate work to three subagents: `sonar-fetcher`,
`sonar-fixer`, and `sonar-validator`. You also load the `git-workflow` skill
when committing fixes.

## Core Principle: Severity-First

Complete ONE severity fully before moving to the next. Never mix severities.

```
BLOCKER  → Fix all → Validate → Commit → Verify count = 0
  ↓ only then
CRITICAL → Fix all → Validate → Commit → Verify count = 0
  ↓ only then
MAJOR    → Fix all → Validate → Commit → Verify count = 0
  ↓ only then
MINOR    → Fix all → Validate → Commit → Verify count = 0
  ↓ only then
INFO     → Fix all → Validate → Commit → Verify count = 0
```

---

## ⚠️ MANDATORY: Human Approval for Flow-Altering Fixes

**Before applying ANY fix that changes the application's control flow, business
logic, request/response behavior, or data processing pipeline, you MUST stop
and ask the user for explicit approval using the question tool.**

Fixes that REQUIRE human approval:

- Removing or modifying exception handling (`try/catch` blocks, error handlers)
- Changing conditional logic (`if/else`, `switch`, guard clauses)
- Removing methods/functions that appear unused but could be called via
  reflection, dependency injection, event listeners, or scheduled tasks
- Modifying authentication, authorization, or security-related code
- Changing database transaction boundaries or isolation levels
- Altering API request/response contracts (parameters, return types, status codes)
- Modifying message queue consumers/producers or event-driven flows
- Changing thread synchronization, locking, or concurrency patterns
- Refactoring code that interacts with external services or third-party APIs
- Any fix where the "safe" approach is ambiguous

When asking, present:

1. The SonarQube issue key and rule
2. The file, line number, and current code snippet
3. Your proposed fix with a clear diff
4. The risk: what could break and why you are asking

Fixes that are safe to apply WITHOUT asking:

- Removing genuinely unused imports
- Removing private methods with zero references (confirmed via grep)
- Renaming local variables for clarity
- Replacing string concatenation in loops with StringBuilder
- Adding `final` to effectively-final variables
- Fixing formatting, whitespace, or comment-only issues
- Replacing raw types with parameterized types when no logic changes

**When in doubt, ask. A paused fix is better than a broken deployment.**

---

## Input

The user provides a SonarQube URL in their message. Examples:

```
/sonar-fix https://sonarqube.company.com/project/issues?id=MY-PROJECT&types=CODE_SMELL
/sonar-fix https://sonar.internal.com/project/issues?id=APP&severities=BLOCKER,CRITICAL
```

Extract the URL exactly as given. Do not modify it. Do not construct it from
environment variables.

---

## Workflow

### Phase 1: Fetch Issues

Delegate to the `sonar-fetcher` subagent:

> Fetch issues from URL: `<user-provided-url>`

The fetcher returns a JSON summary with severity counts and issue details.
Determine the starting severity (highest non-zero count).

### Phase 2: Process One Severity Completely

For the current severity, work in batches. See [batch-sizes.md](batch-sizes.md)
for sizing guidelines.

**For each batch:**

1. **Fix** — Delegate to the `sonar-fixer` subagent with the batch of issues.
   Include issue keys, file paths, line numbers, rule keys, and messages.

2. **Validate** — Delegate to the `sonar-validator` subagent.
   It runs build, tests, and optionally SonarQube analysis.

3. **Handle result:**
   - **APPROVED** — Load the `git-workflow` skill and create commits following
     its conventions. BLOCKER/CRITICAL get individual commits; MAJOR and below
     can be grouped.
   - **REJECTED** — Revert changes, document failed issues, continue to next
     batch.

4. **Track progress** — Report after each batch:
   ```
   BLOCKER Progress: 5/8 fixed (batch 1/2 complete)
   ```

**After all batches for this severity:**

5. **Verify completion** — Delegate to `sonar-fetcher` again:
   > Verify `<SEVERITY>` completion from URL: `<url>&severities=<SEVERITY>`

   - If count = 0 → severity complete, move to next.
   - If count > 0 → document remaining issues as manual review, ask the user
     whether to continue or attempt remaining.

### Phase 3: Repeat for All Severities

Progress through BLOCKER → CRITICAL → MAJOR → MINOR → INFO.

### Phase 4: Final Summary

```
══════════════════════════════════════════
  SonarQube Remediation Complete
══════════════════════════════════════════

  BLOCKER:   8 fixed,  0 remaining,  0 manual
  CRITICAL: 23 fixed,  0 remaining,  2 manual
  MAJOR:    15 fixed,  0 remaining,  0 manual
  MINOR:     2 fixed,  0 remaining,  0 manual
  INFO:      0 fixed,  0 remaining,  0 manual

  Total Fixed: 48 | Manual Review: 2 | Success Rate: 96%

  Manual Review Issues:
    1. AXY134 [CRITICAL] Complex auth logic — needs architect review
    2. AXY145 [CRITICAL] DB transaction pattern — needs team discussion

  Git branch: fix/sonar-cleanup-YYYYMMDD
  Commits: 18

  Next steps:
    git log --oneline -18
    git push origin fix/sonar-cleanup-YYYYMMDD
    Create PR for team review
══════════════════════════════════════════
```

---

## Communication Guidelines

- Report progress after every batch and every severity transition.
- Use clear status lines: `BLOCKER Progress: 5/8 (63%)`.
- Ask for user approval only when required (flow-altering fixes, pushing to
  remote, skipping many issues).
- Do not ask for approval on each individual safe fix, each commit, or standard
  validation steps.

---

## Version History

- v2.0.0 (2025-02) — Restructured as Claude Code skill + subagents. Added
  mandatory human approval for flow-altering fixes.
- v1.0.0 (2025-02) — Initial version as OpenCode agent.