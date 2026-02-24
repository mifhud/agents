---
name: sonarqube-bug-validator
description: >-
  Validates bug fixes by running builds, tests, and SonarQube analysis.
  Verifies that fixes don't introduce regressions and that SonarQube BUG issue counts
  actually decreased. Use after applying bug fixes to ensure quality.
---

# SonarQube Bug Validator

Runs validation checks after bug fixes to ensure quality and correctness.

## Validation Sequence

1. **Build check** — Compile the project, fail fast on errors
2. **Test suite** — Run all tests, capture failures
3. **SonarQube analysis** — Re-analyze to verify issue resolution (if SONAR_TOKEN available)
4. **Quality gate check** — Confirm gate passes

## Output Format

See [output-templates.md](output-templates.md) for APPROVE, REJECT, and REVIEW templates.

## Validation Steps

### Step 1: Build

Compile the project to verify the fix doesn't break compilation.

```bash
# Java/Maven
mvn compile -q

# Java/Gradle  
./gradlew compileJava --quiet

# Node.js
npm run build

# Python
python -m py_compile .  # or python setup.py build

# Go
go build ./...

# Rust
cargo build

# C# / .NET
dotnet build
```

Exit code ≠ 0 → REJECT with build error details.

### Step 2: Run Tests

Run the test suite to verify the fix doesn't break existing functionality.

```bash
# Java/Maven
mvn test -q

# Java/Gradle
./gradlew test --quiet

# Node.js
npm test

# Python
pytest  # or python -m pytest

# Go
go test ./...

# Rust
cargo test

# C# / .NET
dotnet test
```

Capture test count, passed, failed, skipped. Any failures → REJECT with failure details.

### Step 3: SonarQube Analysis (if SONAR_TOKEN available)

Trigger a new SonarQube analysis to verify the bug was actually fixed.

```bash
# Java/Maven
mvn sonar:sonar -Dsonar.token=$SONAR_TOKEN

# Java/Gradle
./gradlew sonar --quiet

# Node.js
npm run sonar  # or sonar-scanner

# Go
sonar-scanner -Dsonar.token=$SONAR_TOKEN

# Docker (if using dockerized Sonar Scanner)
docker run --rm \
  -v "$(pwd):/usr/src" \
  -v "$HOME/.sonar/cache:/opt/sonar-scanner/.sonar/cache" \
  -v "$(pwd)/sonar.properties:/opt/sonar-scanner/conf/sonar-scanner.properties" \
  -e SONAR_TOKEN=$SONAR_TOKEN \
  sonarsource/sonar-scanner-cli
```

Query SonarQube MCP to verify:
- BUG issue count decreased as expected
- No new BUG issues introduced
- Quality gate status

### Step 4: Report Results

Use templates from [output-templates.md](output-templates.md):
- **APPROVE** — All checks passed, safe to commit
- **APPROVE (partial)** — Build/tests pass, no SonarQube verification
- **REJECT** — Build or tests failed, revert changes
- **REVIEW** — Passed but with warnings (new issues, coverage drop)

## Handling Failures

On REJECT:
1. Identify which fix caused the failure
2. Document the failing issue key
3. Recommend: revert or manual review
4. Continue with next bug

## Integration with Bug Fixer

The validator is called by `sonarqube-bug-fixer` after each bug fix:
- Fixer passes: issue key fixed, file modified
- Validator returns: APPROVED / REJECTED / REVIEW
- Fixer commits on APPROVED, reverts on REJECTED

## Prerequisites

| Variable | Required | Description |
|----------|----------|-------------|
| SONAR_TOKEN | No | Token for SonarQube analysis. If not set, validation skips SonarQube analysis. |
| SONARQUBE_URL | No | SonarQube URL (defaults to sonarcloud.io) |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Validation passed (APPROVE or APPROVE partial) |
| 1 | Validation failed (REJECT or REVIEW) |
