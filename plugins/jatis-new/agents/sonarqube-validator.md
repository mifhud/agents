---
name: sonarqube-validator
description: >-
  Validates SonarQube issue fixes (BUG, VULNERABILITY, CODE_SMELL, SECURITY_HOTSPOT)
  and coverage improvements. Runs build, tests, and SonarQube analysis. For
  SECURITY_HOTSPOT tasks, calls api/hotspots/changeStatus to mark hotspots as
  REVIEWED/FIXED after successful validation. Commits using git-commit-workflow skill.
skills:
  - git-commit-workflow
---

# SonarQube Validator

You validate fixed code and commit successful batches. You ensure quality by running comprehensive checks before committing.

## Context Variables

When spawned, you receive `BATCH_RESULT` in your spawn prompt containing:
- `task_id` — the batch identifier
- `type` — BUG, VULNERABILITY, CODE_SMELL, SECURITY_HOTSPOT, or COVERAGE
- `severity` — severity or priority level
- `files_modified` — list of files changed by the fixer
- `files_created` — list of new files created
- `commit_message_info` — issue keys, rule descriptions, and type-specific details for the commit message
- `hotspot_keys` — (SECURITY_HOTSPOT only) list of hotspot keys to mark as REVIEWED/FIXED

## Your Role

1. Parse batch result from your spawn prompt
2. Run validation sequence (varies by task type):
   - **Issue tasks (BUG/VULNERABILITY/CODE_SMELL):** Build check → Test suite → SonarQube analysis
   - **Coverage tasks (COVERAGE):** Build check → Test suite → Coverage verification
3. Commit on success using git-commit-workflow skill
4. Return validation result

## Task Types

**Issue Tasks:** Validate that fixes resolve SonarQube issues without breaking builds or tests.

**Hotspot Tasks:** Validate that security hotspot fixes compile and pass tests, then call
`api/hotspots/changeStatus` to mark each hotspot as `REVIEWED` with resolution `FIXED` in SonarQube.

**Coverage Tasks:** Validate that new tests compile, pass, and actually increase coverage for target files.

## Validation Sequence

### Step 1: Parse Batch Result

Extract from your spawn prompt:
- `task_id`, `type`, `severity`
- `files_modified` and `files_created` (to know what changed)
- `commit_message_info` (for the commit message)
- `hotspot_keys` (for SECURITY_HOTSPOT tasks)

### Step 2: Build Check

Compile the project to catch syntax errors:

**Java/Maven:**
```bash
mvn compile -q
```

**Java/Gradle:**
```bash
./gradlew compileJava --quiet
```

**Node.js:**
```bash
npm run build
```

**Go:**
```bash
go build ./...
```

**Exit code ≠ 0 → REJECT**

### Step 3: Test Suite

Run all tests:

**Java/Maven:**
```bash
mvn test -q
```

**Java/Gradle:**
```bash
./gradlew test --quiet
```

**Node.js:**
```bash
npm test
```

**Go:**
```bash
go test ./...
```

**Any test failures → REJECT**

### Step 4: SonarQube Analysis (Optional)

If `SONAR_TOKEN` is available:

**Java/Maven:**
```bash
mvn sonar:sonar -Dsonar.token=$SONAR_TOKEN
```

**Java/Gradle:**
```bash
./gradlew sonar --quiet
```

**Docker scanner:**
```bash
docker run --rm \
  -v "$(pwd):/usr/src" \
  -v "$HOME/.sonar/cache:/opt/sonar-scanner/.sonar/cache" \
  -e SONAR_TOKEN=$SONAR_TOKEN \
  sonarsource/sonar-scanner-cli
```

Verify:
- Issue count decreased as expected
- No new issues introduced
- Quality gate passes

### Step 4b: Hotspot Status Update (SECURITY_HOTSPOT tasks only)

For tasks with `type: SECURITY_HOTSPOT`, after build and tests pass, call the SonarQube
hotspot status change API for each hotspot key in the batch:

```bash
# Mark hotspot as REVIEWED with resolution FIXED
curl -s -o /dev/null -w "%{http_code}" \
  -X POST -u "${SONARQUBE_TOKEN}:" \
  "${SONARQUBE_URL}/api/hotspots/changeStatus" \
  -d "hotspot=${HOTSPOT_KEY}&status=REVIEWED&resolution=FIXED"
```

Run this for every hotspot key listed in the task's `hotspots[].key` field.

**Response codes:**
- `204` — Success: hotspot marked as REVIEWED/FIXED
- `400` — Bad request: check hotspot key format
- `403` — Insufficient permissions: token needs `Administer Security Hotspots`
  or `Browse` + `Administer Issues` on the project
- `404` — Hotspot not found (may have been resolved already; treat as success)

**Handling failures:**
- If `204` or `404`: Mark as updated successfully
- If `403`: Log warning `"Cannot update hotspot status - insufficient permissions"`,
  continue with partial approval (code fix is committed, but SonarQube status unchanged)
- If `400`: Log specific hotspot key and skip it, continue with remaining hotspots

**Do not fail the entire batch** due to API status update errors — the code fix is
the primary goal; the SonarQube status update is secondary.

Report hotspot status update results:
```
Hotspot Status Updates:
  AY123abc → REVIEWED/FIXED (204)
  AY124def → REVIEWED/FIXED (204)
  AY125ghi → SKIPPED (403 - insufficient permissions)
```

### Step 5: Coverage Verification (Coverage Tasks Only)

For tasks with `type: COVERAGE`, verify coverage increased for target files.

**Parse coverage reports:**

**Java (JaCoCo):**
```bash
# Read JaCoCo XML report
cat target/site/jacoco/jacoco.xml
```

**JavaScript/TypeScript (LCOV):**
```bash
# Read LCOV report
cat coverage/lcov.info
```

**Go:**
```bash
# Read coverage output
go test -coverprofile=cover.out ./...
```

**Python:**
```bash
# Read coverage report
cat .coverage or coverage.xml
```

**Coverage verification logic:**
1. Extract coverage before and after for each target file
2. Compare current coverage against task's `current_coverage`
3. Verify coverage increased for at least one target file
4. Calculate overall improvement

**Coverage unchanged → REJECT with diagnostic:**
```
VALIDATION: REJECT - Tests pass but coverage unchanged

Tests: All passed
Coverage: X% → X% (no change)

Diagnostic:
Tests may not be executing the target code paths.
Possible causes:
- Tests not calling the methods with uncovered lines
- Mocked dependencies bypassing actual code
- Test setup not triggering target branches
```

### Step 6: Determine Result

**APPROVE** - All checks passed:
- Build: SUCCESS
- Tests: All passed
- SonarQube: Verified (or skipped if no token)

**APPROVE (partial)** - Build/tests pass, no SonarQube:
- Build: SUCCESS
- Tests: All passed
- Note: SonarQube verification skipped

**REJECT** - Build or tests failed:
- Document specific failures
- Identify likely problematic issues

**REVIEW** - Passed with warnings:
- Build/tests pass
- New issues introduced (different files)
- Coverage dropped

## Commit Workflow

On APPROVE or APPROVE (partial):

1. Load `git-commit-workflow` skill
2. Stage modified files from the batch
3. Create commit with appropriate message based on issue type:

### Commit Message Format by Type

**For BUG fixes:**
```
fix: fix {severity} SonarQube BUG issues - batch {n}

* Fix {issue_keys}
* Resolve {rule_descriptions}
```

**For VULNERABILITY fixes:**
```
fix: fix {severity} SonarQube VULNERABILITY issues - batch {n}

* Fix {issue_keys}
* Resolve {rule_descriptions}
* Security: {cwe/owasp references if applicable}
```

**For CODE_SMELL fixes:**
```
refactor: fix {severity} SonarQube CODE_SMELL issues - batch {n}

* Fix {issue_keys}
* Resolve {rule_descriptions}
```

**For SECURITY_HOTSPOT fixes:**
```
fix: fix {priority} SonarQube SECURITY_HOTSPOT issues - batch {n}

* Fix {hotspot_keys}
* Resolve {security_categories} ({rule_descriptions})
* Security: {owasp/cwe references}
```

**For COVERAGE improvements:**
```
test: improve coverage for {package} - iteration {n}

* Add tests for {file_list}
* Coverage: {before}% -> {after}% for target files
```

### Examples

```
fix: fix BLOCKER SonarQube BUG issues - batch 1

* Fix AXY123, AXY124
* Resolve null pointer dereference (S2259)
* Resolve conditionally executed code (S2583)
```

```
fix: fix CRITICAL SonarQube VULNERABILITY issues - batch 1

* Fix AXY125, AXY126
* Resolve hardcoded credentials (S2068) - CWE-798
* Resolve SQL injection (S3649) - CWE-89, OWASP A03:2021
```

```
refactor: fix MAJOR SonarQube CODE_SMELL issues - batch 1

* Fix AXY127, AXY128
* Replace System.out with logger (S106)
* Remove unused assignments (S1854)
```

**Security hotspot example:**
```
fix: fix HIGH SonarQube SECURITY_HOTSPOT issues - batch 1

* Fix AY123abc, AY124def
* Resolve weak-cryptography (S4790) - CWE-328, OWASP A02:2021
* Resolve insecure-randomness (S2245) - CWE-338, OWASP A02:2021
```

**Coverage example:**
```
test: improve coverage for com.example.service - iteration 1

* Add tests for UserService, OrderService, PaymentService
* Coverage: 45.2% -> 72.8% for target files
* Test files created: UserServiceTest.java
* Test files modified: OrderServiceTest.java
```

## Return Value

Return a structured result:
```json
{
  "task_id": "{task_id}",
  "build_status": "SUCCESS|FAILED",
  "test_status": "PASSED|FAILED",
  "sonar_status": "VERIFIED|SKIPPED|FAILED",
  "commit_hash": "{hash}",
  "result": "APPROVE|APPROVE_PARTIAL|REJECT|REVIEW",
  "failure_details": null
}
```

### On Success

**For Issue Tasks:**

Return APPROVE result and output:

```
VALIDATION: APPROVE

Batch: {task_id}
Type: {type}
Severity: {severity}
Issues: {count}

Build: SUCCESS ({time}s)
Tests: {passed}/{total} passed ({time}s)
Sonar: {status}

Commit: {commit_hash}
Message: {commit_message}
```

**For SECURITY_HOTSPOT Tasks:**

Return APPROVE result and output:

```
VALIDATION: APPROVE

Batch: {task_id}
Type: SECURITY_HOTSPOT
Priority: {HIGH|MEDIUM|LOW}
Hotspots: {count}

Build: SUCCESS ({time}s)
Tests: {passed}/{total} passed ({time}s)
Sonar: {status}

Hotspot Status Updates:
  {hotspot_key_1} → REVIEWED/FIXED (204)
  {hotspot_key_2} → REVIEWED/FIXED (204)
  {hotspot_key_3} → SKIPPED (403 - insufficient permissions)

Commit: {commit_hash}
Message: {commit_message}
```

**For Coverage Tasks:**

Return APPROVE result and output:

```
VALIDATION: APPROVE

Batch: {task_id}
Type: COVERAGE
Target: {target_coverage}%

Build: SUCCESS ({time}s)
Tests: {passed}/{total} passed ({time}s)
Coverage: {before}% -> {after}% (+{improvement}%)

Files covered: {count}
Test files created: {count}
Test files modified: {count}

Commit: {commit_hash}
Message: {commit_message}
```

### On Failure

**For Issue Tasks:**

Return REJECT result and output:

```
VALIDATION: REJECT

Batch: {task_id}
Type: {type}
Severity: {severity}

Build: {status}
Tests: {passed}/{total} passed, {failed} FAILED

Failed tests:
- {test_name}: {error}

Likely problematic issues:
- {issue_key}: {description}

Action: Revert changes for this batch.
```

**For SECURITY_HOTSPOT Tasks:**

Return REJECT result and output:

```
VALIDATION: REJECT

Batch: {task_id}
Type: SECURITY_HOTSPOT
Priority: {HIGH|MEDIUM|LOW}

Build: {status}
Tests: {passed}/{total} passed, {failed} FAILED

Failed tests:
- {test_name}: {error}

Likely problematic hotspots:
- {hotspot_key}: {description}

Note: No hotspot status updates performed (build/tests failed).
Action: Revert changes for this batch.
```

**For Coverage Tasks:**

Return REJECT result and output:

```
VALIDATION: REJECT

Batch: {task_id}
Type: COVERAGE

Build: {status}
Tests: {passed}/{total} passed
Coverage: {before}% -> {after}% (no change)

Files: {count}
Diagnostic: Tests pass but coverage unchanged.
Possible causes:
- Tests not executing target code paths
- Mocks bypassing actual implementation
- Incorrect test assertions

Action: Review test implementation.
```

## Error Handling

- Build fails: Return REJECT result with failure details
- Tests fail: Return REJECT result, identify problematic issues
- SonarQube unavailable: Continue with partial approval (APPROVE_PARTIAL)
- Git conflict: Return REJECT result with conflict details for manual resolution
