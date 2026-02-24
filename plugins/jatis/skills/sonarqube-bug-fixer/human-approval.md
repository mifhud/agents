# Human Approval Policy for Bug Fixes

## ALL bug fixes REQUIRE approval

Unlike code smells, **every bug fix requires explicit human approval** before application.
Bugs represent actual runtime issues that could change program behavior.

## Information to present for approval

For each bug fix, present:

1. **Issue identification**
   - SonarQube issue key and rule
   - Severity level
   - File path and line number(s)

2. **Current code** (with syntax highlighting)
   ```java
   // Line 42
   String result = data.getValue().toString();  // NPE risk
   ```

3. **Proposed fix** (with clear diff)
   ```java
   // Line 42
   String value = data.getValue();
   String result = value != null ? value.toString() : "default";
   ```

4. **Risk assessment**
   - What could break: "May change behavior when data.getValue() returns null"
   - Confidence level: High/Medium/Low
   - Test impact: "Existing tests may need updates if they rely on NPE being thrown"

5. **Question**
   Use the question tool to ask:
   - "Approve this fix for BUG-123?"
   - "Request changes?"
   - "Skip this bug?"

## Approval question format

Use the question tool with multiple options:

```
Approve fix for BUG-123 [CRITICAL - Null pointer dereference]?

Current code (line 42):
  String result = data.getValue().toString();

Proposed fix:
  String value = data.getValue();
  String result = value != null ? value.toString() : "default";

Risk: May change null handling behavior (returns "default" instead of throwing NPE)
Confidence: High

Options:
- [Approve] - Apply the fix
- [Request Changes] - Need modification before approval
- [Skip] - Skip this bug for now
```

## Common bug types and typical fixes

| Rule | Issue | Typical Fix | Risk Level |
|------|-------|-------------|------------|
| java:S2259 | Null pointer dereference | Add null check | Medium |
| java:S2095 | Resource not closed | Try-with-resources | Low |
| java:S3516 | Method always returns same value | Review logic | High |
| java:S2583 | Condition always true/false | Simplify or fix logic | High |
| java:S3067 | Non-thread-safe field | Synchronize or use atomic | High |
| java:S1217 | Thread.run() instead of start() | Fix method call | Medium |
| javascript:S2259 | Null pointer dereference | Optional chaining (?.) | Low |
| python:S2259 | None attribute access | Add None check | Medium |
| go:S2259 | Nil dereference | Add nil check | Medium |

## When to recommend skipping

Recommend skipping (and marking as manual review) when:
- Fix would require significant refactoring
- Risk of breaking existing behavior is too high
- Bug is in generated code or third-party library
- Team wants to address via different approach
- The fix could introduce new bugs of equal or greater severity

## Fixes that ALWAYS require extra scrutiny

These bug types need additional analysis before approval:
- Concurrency/threading bugs (race conditions, deadlocks)
- Security-related bugs (authentication, authorization, input validation)
- Data integrity bugs (database transactions, file I/O)
- Memory management bugs ( leaks, corruption)
- Business logic errors

For these, add to your presentation:
- Analysis of all code paths affected
- Whether existing tests cover the scenario
- Whether the fix maintains thread-safety
- Any potential side effects

## Safe fixes that can be approved quickly

Some bugs have low-risk, high-confidence fixes:
- Adding null checks where the value can legitimately be null
- Using try-with-resources for resource management
- Adding defensive copies for immutable objects
- Fixing obvious typos in error messages
- Adding missing default cases in switches

For these, you can present in a more concise format while still getting approval.
