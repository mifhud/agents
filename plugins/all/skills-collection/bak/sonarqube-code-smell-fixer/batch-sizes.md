# Batch Size Guidelines

Adjust batch size based on severity to balance safety with throughput.

| Severity | Batch Size | Rationale |
|----------|-----------|-----------|
| BLOCKER  | 3–5       | Most critical. Small batches, careful review, individual commits. |
| CRITICAL | 5–10      | Important. Medium batches, can group related issues. |
| MAJOR    | 10–15     | Standard code smells. Larger batches, group by pattern or module. |
| MINOR    | 15–20     | Low priority. Large batches for efficiency. |
| INFO     | 20+       | Informational. Very large batches, quick processing. |

## Commit Granularity by Severity

- **BLOCKER / CRITICAL** — One commit per issue (or per 2–3 tightly related
  issues). These need clear traceability in git history.
- **MAJOR** — Group by file or by SonarQube rule. One commit per group.
- **MINOR / INFO** — Bulk commit per batch is acceptable.

## When to Reduce Batch Size

- The issues span many unrelated files.
- The fixes are high-risk (logic changes, API modifications).
- Previous batches had validation failures.
- The codebase has low test coverage.

## When to Increase Batch Size

- The issues are all the same rule (e.g., all "unused imports").
- The fixes are trivially safe (formatting, naming).
- The codebase has strong test coverage.
- Previous batches passed validation cleanly.