# Validation Output Templates for Bug Fixes

## APPROVE

All checks passed. The bug fix is verified and safe to commit.

```
VALIDATION: APPROVE

Build: SUCCESS (4.2s)
Tests: 45/45 passed (11.8s)
Coverage: 85% (unchanged)
Sonar: Analysis SUCCESS
  BLOCKER BUGS:  3 → 2 (-1) ✓
  CRITICAL BUGS: 8 → 8 (unchanged) ✓
  MAJOR BUGS:    12 → 10 (-2) ✓
  MINOR BUGS:    5 → 5 (unchanged) ✓
  INFO BUGS:     2 → 2 (unchanged) ✓
  New BUG issues: 0 ✓
  Quality gate: PASSED ✓

Safe to commit.
```

---

## APPROVE (partial — no SonarQube verification)

Build and tests passed, but SonarQube analysis was skipped (no SONAR_TOKEN).

```
VALIDATION: APPROVE (partial — no SonarQube verification)

Build: SUCCESS (3.1s)
Tests: 45/45 passed (11.8s)

Note: SonarQube analysis skipped (SONAR_TOKEN not set).
BUG fix count cannot be verified via SonarQube.
Proceeding based on build and test results only.
```

---

## REJECT

Build or tests failed. The fix must be reverted.

```
VALIDATION: REJECT

Build: SUCCESS (3.1s)
Tests: 43/45 passed — 2 FAILED ✗
  FAILED: UserServiceTest.testValidation
    NullPointerException at UserService.java:42
  FAILED: AuthControllerTest.testLogin
    Expected status 200 but got 401

Action required: Revert changes for this bug.
This issue likely needs manual fix:
  - BUG-123: Null check change broke existing test expectations

Recommendation: Review the failing tests, determine if test needs
updating or if the fix approach needs reconsideration.
```

---

## REVIEW

Passed but with warnings. Human judgment required.

```
VALIDATION: REVIEW

Build: SUCCESS (3.5s)
Tests: 44/45 passed, 1 skipped (not failed)
Coverage: 85% → 84% (-1%)
Sonar: Analysis SUCCESS
  BLOCKER BUGS:  3 → 2 (-1) ✓
  CRITICAL BUGS: 8 → 9 (+1 new) ⚠️
    New BUG issue: java:S2259 in FileProcessor.java:92
  MAJOR BUGS:    12 → 10 (-2) ✓
  MINOR BUGS:    5 → 5 (unchanged) ✓
  INFO BUGS:     2 → 2 (unchanged) ✓

Warning: New CRITICAL BUG introduced in FileProcessor.java:92

Recommendation: Approve with caution. The new CRITICAL BUG issue is in
a different file and may be pre-existing. Verify before committing.
```

---

## Additional Scenarios

### Coverage Drop Warning

```
VALIDATION: REVIEW

Build: SUCCESS
Tests: 50/50 passed
Coverage: 80% → 75% (-5%) ⚠️
  This fix reduced coverage by 5%

Recommendation: The coverage drop may indicate the fix needs
additional test coverage. Consider adding tests before committing.
```

### Multiple Fixes in Batch

```
VALIDATION: APPROVE

Build: SUCCESS
Tests: 47/47 passed
Sonar: Analysis SUCCESS
  Fixed 3 bugs in batch:
    - BUG-101 [BLOCKER] Null pointer at UserService.java:42
    - BUG-102 [BLOCKER] Null pointer at UserService.java:55
    - BUG-103 [CRITICAL] Resource leak at FileUtil.java:78
  New issues: 0 ✓

Safe to commit.
```

### Fix Not Reflected in SonarQube

```
VALIDATION: REVIEW

Build: SUCCESS
Tests: 45/45 passed
Sonar: Analysis SUCCESS
  BUG-123 still showing as OPEN in SonarQube

Note: The issue may still appear in SonarQube if:
- The analysis hasn't completed yet
- The issue was on a different branch
- Caching delay (SonarQube can take 5-15 minutes)

Recommendation: Verify the fix was applied correctly. If issue
persists after re-analysis, it may be a false positive or
require manual resolution in SonarQube.
```
