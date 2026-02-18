# Test Writing Strategy

## Contents

- [Priority order for uncovered code](#priority-order-for-uncovered-code)
- [Test quality principles](#test-quality-principles)
- [Framework detection](#framework-detection)
- [Handling difficult-to-test code](#handling-difficult-to-test-code)
- [Anti-patterns to avoid](#anti-patterns-to-avoid)

---

## Priority order for uncovered code

Within each file, cover code in this order:

1. **Error handling paths** — catch blocks, error callbacks, fallback logic.
   These are the most likely to hide production bugs.
2. **Branch conditions** — if/else, switch cases, guard clauses, ternary
   expressions. Each boolean expression needs both true and false evaluation.
3. **Edge cases in business logic** — null inputs, empty collections, boundary
   values, overflow conditions.
4. **Happy-path gaps** — standard flows that happen to be uncovered.
5. **Trivial accessors** — getters/setters, toString, equals/hashCode. Only
   cover these if needed to reach the target; they rarely hide bugs.

## Test quality principles

Tests must be meaningful, not just line-hitting stubs.

- **Assert behavior, not implementation.** Test what the code does, not how.
- **One logical concept per test method.** Name it after the scenario.
- **Use descriptive names:** `shouldRejectExpiredToken` not `test1`.
- **Arrange-Act-Assert** (or Given-When-Then) structure in every test.
- **No test interdependence.** Each test must pass in isolation.
- **Prefer real objects over mocks** when feasible. Mock external boundaries
  (databases, APIs, filesystem), not internal collaborators.

## Framework detection

Match the project's existing test setup. Detect by examining:

| Signal                          | Framework                    |
|---------------------------------|------------------------------|
| `src/test/java` + JUnit imports | JUnit 4 or 5 (check imports) |
| `@SpringBootTest`              | Spring Boot Test             |
| `*.test.ts` / `*.spec.ts`     | Jest or Vitest               |
| `*.test.js` / `*.spec.js`     | Jest, Mocha, or Vitest       |
| `test_*.py` / `*_test.py`     | pytest                       |
| `*_test.go`                    | Go testing                   |
| `*Spec.scala`                  | ScalaTest                    |
| `*.test.rs`                    | Rust #[test]                 |

If multiple frameworks coexist, follow the convention in the same module or
package as the file under test.

## Handling difficult-to-test code

Some code patterns require special approaches:

### External API calls

Create a test double (mock/stub) for the HTTP client or API wrapper. Verify
the request was constructed correctly and test both success and error
responses.

### Database interactions

- If the project uses an in-memory DB for tests (H2, SQLite), follow that
  pattern.
- If not, mock the repository/DAO layer.
- Never connect to a real database in unit tests.

### Static methods and singletons

- If the project uses a mocking library that supports statics (Mockito 5+,
  PowerMock, `unittest.mock.patch`), use it.
- Otherwise, consider wrapping the static call in an injectable dependency
  and note the refactoring as a suggestion in the commit message.

### Concurrency and async code

- Test the logic, not the threading. Extract pure functions where possible.
- For async code, use the framework's async test utilities (e.g.
  `@Test` with `CompletableFuture`, `await` in Jest, `asyncio` in pytest).

### Generated or framework code

Skip files that are clearly generated (e.g. Lombok-generated, protobuf
stubs, OpenAPI clients). Document them as "skipped — generated code" in
the progress report.

## Anti-patterns to avoid

| Anti-pattern                  | Why it's bad                              |
|-------------------------------|-------------------------------------------|
| Tests with no assertions      | Inflate coverage without verifying behavior |
| Catching and ignoring exceptions in tests | Hides real failures            |
| Copy-pasting test bodies      | Maintenance nightmare; use parameterized tests |
| Testing private methods directly | Couples tests to implementation         |
| Overly broad `@SuppressWarnings` | Hides compiler warnings in test code    |
| `Thread.sleep` for async waits | Flaky; use latches, futures, or polling  |