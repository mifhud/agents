# Coverage Batch & Commit Guidelines

## File processing order

Process files from lowest coverage to highest. This maximizes coverage gain
per iteration.

| Current coverage | Priority | Rationale                                   |
|------------------|----------|---------------------------------------------|
| 0–25%            | Highest  | Largest gap, highest risk of hidden bugs     |
| 25–50%           | High     | Significant gaps, likely missing error paths |
| 50–75%           | Medium   | Partial coverage, focus on branches          |
| 75–target        | Low      | Near target, usually edge cases only         |

## Iteration limits

- **Max 3 iterations per file.** If coverage is still below target after 3
  rounds, document it as manual review and move on.
- **Max 15 test methods per iteration.** Larger batches make failures harder
  to diagnose.

## Commit granularity

- **One commit per file** when the file gets significant new tests (5+).
- **Group closely related files** (e.g. a service and its DAO) into one
  commit when they share test fixtures.
- **Never mix unrelated files** in a single commit.

## When to skip a file

- Generated code (Lombok, protobuf, OpenAPI stubs)
- Configuration classes with no logic
- Files excluded via `sonar.coverage.exclusions`
- Files where the only uncovered lines are trivial (logging, toString)

Document all skipped files in the final summary.