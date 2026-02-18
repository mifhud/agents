# Human Approval Policy for Flow-Altering Fixes

## Fixes that REQUIRE approval

- Removing or modifying exception handling (`try/catch`, error handlers)
- Changing conditional logic (`if/else`, `switch`, guard clauses)
- Removing methods that appear unused but could be called via reflection,
  dependency injection, event listeners, or scheduled tasks
- Modifying authentication, authorization, or security-related code
- Changing database transaction boundaries or isolation levels
- Altering API request/response contracts (parameters, return types, status codes)
- Modifying message queue consumers/producers or event-driven flows
- Changing thread synchronization, locking, or concurrency patterns
- Refactoring code that interacts with external services or third-party APIs
- Any fix where the "safe" approach is ambiguous

When asking, present:

1. The SonarQube issue key and rule
2. The file, line number, and current code snippet
3. Your proposed fix with a clear diff
4. The risk: what could break and why you are asking

## Fixes safe to apply WITHOUT asking

- Removing genuinely unused imports
- Removing private methods with zero references (confirmed via grep)
- Renaming local variables for clarity
- Replacing string concatenation in loops with StringBuilder
- Adding `final` to effectively-final variables
- Fixing formatting, whitespace, or comment-only issues
- Replacing raw types with parameterized types when no logic changes

**When in doubt, ask use question tool or AskUserQuestionTool. A paused fix is better than a broken deployment.**