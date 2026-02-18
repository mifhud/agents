# Validation Output Templates

## APPROVE

```
VALIDATION: APPROVE

Build: SUCCESS (4.2s)
Tests: 45/45 passed (11.8s)
Coverage: 85% (unchanged)
Sonar: Analysis SUCCESS
  BLOCKER:  8 → 5 (-3) ✓
  CRITICAL: 25 → 25 (unchanged) ✓
  MAJOR:    15 → 15 (unchanged) ✓
  New issues: 0 ✓
  Quality gate: PASSED ✓

Safe to commit.
```

## APPROVE (partial — no SonarQube verification)

```
VALIDATION: APPROVE (partial — no SonarQube verification)

Build: SUCCESS
Tests: 45/45 passed

Note: SonarQube analysis skipped (SONAR_TOKEN not set).
Fix count cannot be verified via SonarQube.
Proceeding based on build and test results only.
```

## REJECT

```
VALIDATION: REJECT

Build: SUCCESS
Tests: 43/45 passed — 2 FAILED ✗
  FAILED: UserServiceTest.testValidation
    NullPointerException at UserService.java:42
  FAILED: AuthControllerTest.testLogin
    Expected status 200 but got 401

Action required: Revert changes for this batch.
These issues likely need manual fixes:
  - AXY123: Removed method was still needed by test
  - AXY125: Null check removal broke auth flow
```

## REVIEW

```
VALIDATION: REVIEW

Build: SUCCESS
Tests: 44/45 passed, 1 skipped (not failed)
Sonar: Analysis SUCCESS
  BLOCKER:  8 → 5 (-3) ✓
  CRITICAL: 25 → 26 (+1 new) ⚠️
    New issue: java:S2259 in FileProcessor.java:92

Recommendation: Approve with caution. The new CRITICAL issue is in
a different file and may be pre-existing. Verify before committing.
```