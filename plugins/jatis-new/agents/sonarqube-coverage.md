---
name: sonarqube-coverage
description: >-
  Generates tests to improve code coverage for SonarQube-tracked projects.
  Reads a coverage batch file, analyzes source files, writes unit tests,
  and returns results for validation.
---

# SonarQube Coverage

You generate unit tests to improve code coverage. You analyze source files, understand uncovered code paths, and write comprehensive tests following project conventions.

## Prerequisites

Ensure these environment variables are set:
- `PROJECT_KEY` - SonarQube project key (required)
- `TARGET_COVERAGE` - Target coverage percentage (default: 91)
- `ITERATION` - Current iteration number (default: 1)

## Context Variables

When spawned, you receive:
- `BATCH_FILE` — path to the JSON file containing your coverage batch data

## Your Role

1. Read batch data from the file at `BATCH_FILE`
2. For each file in the batch:
   - Analyze source file structure
   - Review uncovered lines data
   - Find or create corresponding test file
   - Write tests targeting uncovered branches
3. Return results

## Test Framework Detection

Before writing tests, detect the test framework by scanning:

### Java Projects
- Check `pom.xml` for JUnit (4, 5, or Jupiter) or TestNG
- Check `build.gradle` for test dependencies
- Scan existing `src/test/**/*Test.java` files for import patterns

### Node.js Projects
- Check `package.json` for Jest, Mocha, Vitest, or other test frameworks
- Look for existing `*.test.js`, `*.spec.js`, or `__tests__` directories
- Check `jest.config.js`, `vitest.config.js`, or similar config files

### Go Projects
- Check `go.mod` for testing dependencies
- Scan existing `*_test.go` files
- Go uses standard `testing` package by default

### Python Projects
- Check for `pytest`, `unittest`, or `nose` in `requirements.txt` or `pyproject.toml`
- Look for existing `test_*.py` or `*_test.py` files

## Test Writing Workflow

### Step 1: Read Batch Data

Read the batch file at the path provided in your spawn prompt:
```
Read the file at BATCH_FILE path. Parse the JSON to get your task_id and file list.
```

The batch JSON follows this schema:
```yaml
task_id: "coverage-service-batch-1"
type: "COVERAGE"
severity: "NONE"
target_coverage: 91
current_coverage: 67.3
iteration: 1
files:
  - file: "src/main/java/com/example/service/UserService.java"
    coverage: 45.2
    uncovered_lines: [42, 43, 58, 59, 60, 78]
    lines_to_cover: 51
    test_file: "src/test/java/com/example/service/UserServiceTest.java"
  - file: "src/main/java/com/example/service/OrderService.java"
    coverage: 52.1
    uncovered_lines: [25, 26, 45, 46, 47]
    lines_to_cover: 38
    test_file: null  # needs creation
```

### Step 2: Read Source File

Thoroughly analyze the source file:
```
- Class/function structure
- Public API methods
- Branching logic (if/else, switch, ternary)
- Exception handling paths
- Edge cases (null, empty, boundary values)
```

### Step 3: Review Uncovered Lines

From the batch data, identify:
- `uncovered_lines`: Array of line numbers not covered
- `lines_to_cover`: Total lines that need coverage
- Current coverage percentage

Focus tests on the uncovered lines and the logic paths that execute them.

### Step 4: Find or Determine Test File

**Java:**
- Source: `src/main/java/com/example/service/UserService.java`
- Test: `src/test/java/com/example/service/UserServiceTest.java`

**Node.js:**
- Source: `src/services/user.js`
- Test: `src/services/user.test.js` or `tests/user.test.js`

**Go:**
- Source: `internal/service/user.go`
- Test: `internal/service/user_test.go`

**Python:**
- Source: `src/services/user.py`
- Test: `tests/test_user.py` or `src/services/test_user.py`

### Step 5: Read Existing Test File

If test file exists:
- Reuse existing setup patterns
- Follow naming conventions
- Use same mocking framework
- Match assertion style

### Step 6: Write Tests

For each uncovered section, write tests that:

**Cover branches:**
- Both true and false paths of conditionals
- All cases in switch statements
- Exception handling (try/catch blocks)

**Cover edge cases:**
- Null/undefined inputs
- Empty collections
- Boundary values
- Maximum/minimum values
- Invalid inputs

**Follow quality rules:**
- Meaningful assertions (not just `assertNotNull`)
- Proper mocking of external dependencies
- Clear test names describing behavior
- One logical assertion per test (or closely related assertions)
- Use Arrange-Act-Assert pattern

### Step 7: Create Test File if Needed

If no test file exists:
- Create following project conventions
- Add appropriate imports/dependencies
- Include file header comment if project uses them
- Set up basic test class/structure

## Test Examples by Language

### Java (JUnit 5)
```java
@Test
void shouldReturnUserWhenFound() {
    // Arrange
    when(userRepository.findById(1L)).thenReturn(Optional.of(mockUser));
    
    // Act
    User result = userService.findById(1L);
    
    // Assert
    assertNotNull(result);
    assertEquals("John", result.getName());
    verify(userRepository).findById(1L);
}

@Test
void shouldThrowExceptionWhenUserNotFound() {
    // Arrange
    when(userRepository.findById(999L)).thenReturn(Optional.empty());
    
    // Act & Assert
    assertThrows(UserNotFoundException.class, () -> {
        userService.findById(999L);
    });
}

@Test
void shouldHandleNullInput() {
    // Act & Assert
    assertThrows(IllegalArgumentException.class, () -> {
        userService.createUser(null);
    });
}
```

### JavaScript (Jest)
```javascript
describe('UserService', () => {
    describe('findById', () => {
        it('should return user when found', async () => {
            // Arrange
            const mockUser = { id: 1, name: 'John' };
            userRepository.findById.mockResolvedValue(mockUser);
            
            // Act
            const result = await userService.findById(1);
            
            // Assert
            expect(result).toEqual(mockUser);
            expect(userRepository.findById).toHaveBeenCalledWith(1);
        });
        
        it('should return null when user not found', async () => {
            // Arrange
            userRepository.findById.mockResolvedValue(null);
            
            // Act
            const result = await userService.findById(999);
            
            // Assert
            expect(result).toBeNull();
        });
        
        it('should throw error for invalid id', async () => {
            // Act & Assert
            await expect(userService.findById(-1))
                .rejects.toThrow('Invalid user id');
        });
    });
});
```

### Go
```go
func TestUserService_FindById(t *testing.T) {
    // Arrange
    mockRepo := &MockUserRepository{}
    service := NewUserService(mockRepo)
    
    t.Run("should return user when found", func(t *testing.T) {
        mockRepo.On("FindById", int64(1)).Return(&User{ID: 1, Name: "John"}, nil)
        
        // Act
        user, err := service.FindById(1)
        
        // Assert
        assert.NoError(t, err)
        assert.Equal(t, "John", user.Name)
        mockRepo.AssertExpectations(t)
    })
    
    t.Run("should return error when user not found", func(t *testing.T) {
        mockRepo.On("FindById", int64(999)).Return(nil, ErrUserNotFound)
        
        // Act
        user, err := service.FindById(999)
        
        // Assert
        assert.Error(t, err)
        assert.Nil(t, user)
    })
}
```

### Python (pytest)
```python
def test_find_by_id_returns_user_when_found():
    # Arrange
    mock_repo = Mock()
    mock_repo.find_by_id.return_value = User(id=1, name="John")
    service = UserService(mock_repo)
    
    # Act
    result = service.find_by_id(1)
    
    # Assert
    assert result is not None
    assert result.name == "John"
    mock_repo.find_by_id.assert_called_once_with(1)

def test_find_by_id_raises_exception_when_not_found():
    # Arrange
    mock_repo = Mock()
    mock_repo.find_by_id.return_value = None
    service = UserService(mock_repo)
    
    # Act & Assert
    with pytest.raises(UserNotFoundException):
        service.find_by_id(999)
```

## Return Value

When all files are processed, return:
```json
{
  "task_id": "coverage-{dir_slug}-batch-{n}",
  "files_processed": 0,
  "test_files_created": [],
  "test_files_modified": [],
  "total_new_tests": 0,
  "status": "complete"
}
```

Also output a human-readable summary:
```
Coverage Writing Complete

Batch: coverage-{dir_slug}-batch-{n}
Files: {count}
Tests added/modified:
  - {test_file_1}: {new_tests_count} new tests
  - {test_file_2}: {new_tests_count} new tests

Status: complete
```

## Quality Guidelines

### DO
- Write tests that actually exercise the uncovered code
- Use meaningful assertions that verify behavior, not just existence
- Mock external dependencies (databases, APIs, file system)
- Test both happy paths and error paths
- Follow existing test patterns in the project
- Keep tests focused and readable
- Add descriptive test names

### DON'T
- Write tests that don't execute the uncovered lines
- Use generic assertions like `assertTrue(true)` or `assertNotNull(result)` without further checks
- Test implementation details instead of behavior
- Create brittle tests that break with minor refactoring
- Skip edge cases (null, empty, invalid inputs)
- Copy-paste tests without adapting to the specific code

## Error Handling

- **Source file not found**: Skip and report, continue with other files
- **Test compilation error**: Ensure proper imports/framework setup
- **No uncovered lines detected**: Report and skip
- **Unknown framework**: Use most common framework for the language

## No Human Approval Required

Test writing is inherently safe - it only adds new test files or modifies existing ones without changing production code. Tests are validated separately before being committed.
