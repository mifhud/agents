# Severity-Specific Bug Handling

## Overview

Bugs are prioritized by severity. Process BLOCKER bugs first, then CRITICAL, MAJOR, MINOR, and INFO.
Never mix severities within a batch.

---

## BLOCKER Bugs

**Definition**: Bugs that will certainly cause application crashes, data corruption, or security breaches.

**Examples**:
- Null pointer dereference in critical path (main entry points, service startup)
- Division by zero in calculation code
- Array index out of bounds with user input
- SQL injection vulnerabilities
- Authentication bypass bugs

**Approach**:
- Fix immediately after approval
- Highest priority - stop all other work
- Individual commits per bug
- Extensive validation (run full test suite)
- May need additional regression testing

**Communication**:
- Report immediately to user
- These bugs should not wait for batch processing

---

## CRITICAL Bugs

**Definition**: Bugs that could cause crashes or significant incorrect behavior in production.

**Examples**:
- Resource leaks in long-running processes (connections, memory, files)
- Incorrect exception handling that swallows errors
- Logic errors in critical business rules (pricing, permissions, calculations)
- Race conditions in concurrent code
- Data validation bypass

**Approach**:
- Fix after BLOCKER bugs are complete
- May require architectural review for complex fixes
- Individual commits per bug
- Thorough validation including edge cases
- Document any behavioral changes

**Communication**:
- Present with full risk assessment
- Ask about potential impact on existing systems

---

## MAJOR Bugs

**Definition**: Bugs that may cause problems in edge cases or reduce application reliability.

**Examples**:
- Ignored return values (even if non-null)
- Incorrect string comparisons (locale, case sensitivity)
- Potential infinite loops or recursion
- Missing error handling in non-critical paths
- Performance issues that could degrade over time

**Approach**:
- Fix after CRITICAL bugs are complete
- Batch size can be slightly larger (3-7)
- Still individual commits per bug
- Standard validation sufficient
- Review behavioral compatibility

**Communication**:
- Standard presentation format
- Note any edge cases that might be affected

---

## MINOR Bugs

**Definition**: Low-impact issues that don't affect core functionality but should be addressed.

**Examples**:
- Dead stores (unused variable assignments)
- Unused local variables
- Redundant null checks
- Suboptimal code that doesn't cause issues
- Style issues that could mask future bugs

**Approach**:
- Fix after MAJOR bugs are complete
- Can be batched (5-10 per batch)
- Group commits by file or rule type
- Standard validation
- Lower scrutiny for obvious improvements

**Communication**:
- Concise presentation
- Focus on code quality improvement

---

## INFO Bugs

**Definition**: Informational issues, typically about code maintainability or minor concerns.

**Examples**:
- Commented-out code
- TODO/FIXME comments
- Poorly named variables (when not misleading)
- Minor code duplication

**Approach**:
- Fix last, after all other severities
- Can be bulk processed
- Bulk commits acceptable
- Minimal validation needed
- Skip if time constraints

**Communication**:
- Brief summary
- Note if skipping these

---

## Severity Transition

When moving from one severity to the next:

1. Verify the current severity count is 0 (or user-approved to continue)
2. Report completion summary for the completed severity
3. Announce transition to the next severity
4. Begin fetching and processing the new severity

Example transition message:
```
══════════════════════════════════════════
BLOCKER Complete: 3 fixed, 0 remaining
Starting CRITICAL bugs (8 issues)
══════════════════════════════════════════
```

---

## Manual Review Criteria

Escalate to manual review when:
- Bug requires architectural changes
- Fix might break backward compatibility
- Bug is in third-party or generated code
- Uncertainty about the correct fix
- Bug has security implications
- Team wants to discuss approach

Document in final summary with:
- Issue key
- Severity
- Reason for manual review
- Suggested next steps
