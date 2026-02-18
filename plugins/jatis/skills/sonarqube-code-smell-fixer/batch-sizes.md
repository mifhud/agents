# Batch Size Guidelines

Adjust batch size based on severity to balance safety with throughput.

| Severity | Batch Size | Commit Granularity |
|----------|-----------|-------------------|
| BLOCKER  | 3–5       | One commit per issue (or per 2–3 tightly related issues) |
| CRITICAL | 5–10      | One commit per issue or small group |
| MAJOR    | 10–15     | Group by file or SonarQube rule |
| MINOR    | 15–20     | Bulk commit per batch |
| INFO     | 20+       | Bulk commit per batch |

## When to reduce batch size

- Issues span many unrelated files
- Fixes are high-risk (logic changes, API modifications)
- Previous batches had validation failures
- Codebase has low test coverage

## When to increase batch size

- All issues share the same rule (e.g. all "unused imports")
- Fixes are trivially safe (formatting, naming)
- Strong test coverage and previous batches passed cleanly