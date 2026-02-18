---
name: sonarqube-coverage-fixer
description: >-
  Writes or improves unit tests to cover uncovered and partially covered code
  identified by SonarQube coverage reports. Works file-by-file, prioritizing
  the lowest-coverage files first. Iterates in a write-test → run → measure
  feedback loop until coverage targets are met or all coverable lines are
  addressed. Use when the user wants to increase code coverage, fix coverage
  gaps, write missing tests, or reach a SonarQube coverage quality gate.
  Invoke with /sonarqube-coverage-fixer <url>.
---

# SonarQube Coverage Improving

Writes or improves unit tests to close coverage gaps reported by SonarQube.
Delegates to `sonarqube-fetcher` for coverage data, generates tests internally,
and delegates to `sonarqube-validator` for verification. Loads `git-commit-workflow`
when committing.

## Core principle: lowest-coverage-first

Process files from lowest coverage to highest. Within a file, prioritize
uncovered lines in critical paths (error handling, branching logic) over
trivial getters/setters.

```
Fetch coverage data → Rank files by coverage % ascending
  ↓
File A (12%) → Analyze → Write tests → Run → Measure → Commit
  ↓ only when file target met or exhausted
File B (34%) → Analyze → Write tests → Run → Measure → Commit
  ↓ …
File N (87%) → …
  ↓
Final summary
```

## Input

The user provides a SonarQube project URL and optionally a target coverage %.

```
/sonarqube-coverage-fixer https://sonarqube.company.com/project/overview?id=MY-PROJECT
/sonarqube-coverage-fixer https://sonar.internal.com/project/issues?id=APP --target 80
```

Default target: **80% line coverage** (adjustable per user request).

## Workflow

### Phase 1: Fetch coverage data

Delegate to `sonarqube-fetcher`:

```
Fetch coverage measures for: <url>
Metrics: coverage, line_coverage, branch_coverage, uncovered_lines, lines_to_cover
```

Build a ranked file list sorted by coverage % ascending. Report the starting
state:

```
Coverage Baseline: 62% overall (target: 80%)
Files to process: 23 (below target)
Lowest: UserService.java (12%), AuthController.java (28%), …
```

### Phase 2: Process one file at a time

For each file, follow the feedback loop. See [test-strategy.md](test-strategy.md)
for test writing guidelines and [batch-sizes.md](batch-sizes.md) for grouping rules.

**Feedback loop (repeat until file target met or max 3 iterations):**

1. **Analyze** — Read the source file and its existing tests. Identify
   uncovered lines and branches using SonarQube data + local coverage reports.
2. **Write tests** — Generate test cases for uncovered code. Follow the
   project's existing test conventions (framework, naming, structure).
3. **Run & measure** — Execute tests and collect coverage. Use the build
   tool's coverage plugin (JaCoCo, Istanbul, coverage.py, etc.).
4. **Evaluate:**
   - Coverage target met for this file → commit and move to next file.
   - Coverage improved but below target → iterate (go to step 1 with
     remaining gaps).
   - Coverage unchanged after iteration → document as manual review,
     move to next file.
5. **Commit** — Load `git-commit-workflow` skill. One commit per file or per
   logical group of closely related files.

**Report progress after each file:**

```
UserService.java: 12% → 85% ✓ (+73%, 14 tests added)
AuthController.java: 28% → 82% ✓ (+54%, 9 tests added)
Overall: 62% → 68% (target: 80%) — 21 files remaining
```

### Phase 3: Final verification

After all files are processed:

1. Run the full test suite to confirm no regressions.
2. If `SONAR_TOKEN` is set, trigger a SonarQube analysis and verify the
   overall coverage metric.
3. Check quality gate status.

### Phase 4: Final summary

```
══════════════════════════════════════════
SonarQube Coverage Improvement Complete
══════════════════════════════════════════

Coverage: 62% → 83% (+21%)
Target:   80% ✓ ACHIEVED

Files improved: 23
Tests added:    147
Tests modified: 12

Breakdown:
  ≥ target:     19 files
  < target:      3 files (manual review)
  Skipped:       1 file  (generated code)

Manual Review Files:
1. PaymentGateway.java — 68% (external API mocking needed)
2. LegacyParser.java — 55% (complex state machine)
3. CryptoUtil.java — 72% (native method calls)

Quality gate: PASSED ✓
Git branch: feat/coverage-improvement-YYYYMMDD
Commits: 25

Next steps: git push → Create PR for team review
══════════════════════════════════════════
```

## Human approval rules

**Before writing tests that require any of the following, stop and ask:**

- Mocking authentication or security services
- Creating test fixtures that connect to real databases or external APIs
- Modifying existing test infrastructure (base classes, test utilities)
- Adding new test dependencies to the build file
- Deleting or significantly rewriting existing tests

Safe to proceed without asking: adding new test files, new test methods in
existing test classes, and standard mocking of internal dependencies.

For the full policy, see the orchestrator's [human-approval.md](../sonarqube-code-smell-fixer/human-approval.md).

## Communication guidelines

- Report progress after every file and every iteration within a file.
- Use clear status: `UserService.java: 12% → 45% (iteration 1/3)`.
- Show overall progress: `Overall: 62% → 68% (target: 80%)`.
- Do not ask for approval on each individual test method.