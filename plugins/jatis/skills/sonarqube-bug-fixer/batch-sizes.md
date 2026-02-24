# Batch Size Guidelines for Bug Fixes

Bug fixes require smaller batches than code smells due to higher risk of behavioral changes.

| Severity | Batch Size | Approval Required | Commit Granularity |
|----------|-----------|-------------------|-------------------|
| BLOCKER  | 1–3       | Yes (every fix)   | One commit per bug |
| CRITICAL | 1–5       | Yes (every fix)   | One commit per bug |
| MAJOR    | 3–7       | Yes (every fix)   | One commit per bug |
| MINOR    | 5–10      | Yes (every fix)   | One commit per bug |
| INFO     | 5–10      | Yes (every fix)   | One commit per bug |

## Why smaller batches for bugs?

- **Higher risk**: Bug fixes change runtime behavior, not just style
- **Behavioral changes**: May alter program output or state
- **Test impact**: May require test updates
- **Rollback safety**: Easier to revert individual commits

## When to reduce batch size further

- Bugs span critical business logic
- Fixes involve threading, concurrency, or async code
- Previous fixes had validation failures
- Codebase has low test coverage
- Bugs are in security-sensitive code (auth, crypto, input validation)

## When to increase batch size (rare)

- All bugs are the same rule type (e.g., all "null pointer dereference")
- Fixes are purely additive (adding null checks)
- Strong test coverage and all previous fixes passed cleanly
