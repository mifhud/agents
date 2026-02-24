# Bug Fix Examples by Language

This file contains common bug fix patterns for different programming languages.
Use these as reference when presenting fixes to users.

---

## Java

### Null Pointer Dereference (java:S2259)

**Rule**: "A null pointer dereference occurs when an application dereferences an object reference that is null."

**Before**:
```java
String result = data.getValue().toString();
```

**After**:
```java
String value = data.getValue();
String result = value != null ? value.toString() : "default";
```

**Risk**: Low - changes exception to default value

---

### Resource Not Closed (java:S2095)

**Rule**: "Resources should be closed."

**Before**:
```java
InputStream is = new FileInputStream(file);
return process(is);
```

**After**:
```java
try (InputStream is = new FileInputStream(file)) {
    return process(is);
}
```

**Risk**: Low - proper resource management

---

### Method Always Returns Same Value (java:S3516)

**Rule**: "Methods should not always return the same value."

**Before**:
```java
public boolean isValid(String input) {
    return true;
}
```

**After**:
```java
public boolean isValid(String input) {
    return input != null && !input.isEmpty();
}
```

**Risk**: Medium - changes method behavior

---

### Condition Always True/False (java:S2583)

**Rule**: "Condition should not be invariant."

**Before**:
```java
if (items != null && items.isEmpty()) {
    // This branch is unreachable if items is null
}
```

**After**:
```java
if (items != null && !items.isEmpty()) {
    // Process items
}
```

**Risk**: Medium - fixes logic error

---

### Non-Thread-Safe Field (java:S3067)

**Rule**: "Non-thread-safe types should not be used for shared fields."

**Before**:
```java
private Map<String, String> cache = new HashMap<>();
```

**After**:
```java
private Map<String, String> cache = new ConcurrentHashMap<>();
```

**Risk**: Medium - changes concurrency behavior

---

### Thread.run() Instead of start() (java:S1217)

**Rule**: "Thread.run() should not be called directly."

**Before**:
```java
Thread t = new Thread(() -> doWork());
t.run();
```

**After**:
```java
Thread t = new Thread(() -> doWork());
t.start();
```

**Risk**: Medium - changes from synchronous to asynchronous execution

---

## JavaScript / TypeScript

### Null Pointer Dereference (S2259)

**Before**:
```javascript
const name = user.profile.name;
```

**After**:
```javascript
const name = user?.profile?.name ?? 'Anonymous';
```

**Risk**: Low - optional chaining is safe

---

### Undefined Assignment (Sxxxx)

**Before**:
```javascript
function process(data) {
    return data.items.map(x => x.value);
}
```

**After**:
```javascript
function process(data) {
    return (data?.items ?? []).map(x => x.value);
}
```

**Risk**: Low - defensive coding

---

### Missing Error Handling

**Before**:
```javascript
async function fetchData() {
    const response = await fetch(url);
    return response.json();
}
```

**After**:
```javascript
async function fetchData() {
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
}
```

**Risk**: Medium - adds error handling

---

## Python

### None Attribute Access (S2259)

**Before**:
```python
result = data['key'].upper()
```

**After**:
```python
value = data.get('key')
result = value.upper() if value else ''
```

**Risk**: Low - defensive coding

---

### Index Error Risk

**Before**:
```python
def get_first(items):
    return items[0]
```

**After**:
```python
def get_first(items):
    return items[0] if items else None
```

**Risk**: Low - prevents IndexError

---

### Unclosed Resource

**Before**:
```python
f = open('file.txt')
content = f.read()
```

**After**:
```python
with open('file.txt') as f:
    content = f.read()
```

**Risk**: Low - proper resource management

---

## Go

### Nil Dereference (S2259)

**Before**:
```go
result := data.Value.String()
```

**After**:
```go
var result string
if data.Value != nil {
    result = data.Value.String()
} else {
    result = "default"
}
```

**Risk**: Low - explicit nil check

---

### Nil Map Assignment

**Before**:
```go
var config map[string]string
config["key"] = "value"
```

**After**:
```makefile
config := make(map[string]string)
config["key"] = "value"
```

**Risk**: Low - initialize map before use

---

### Unchecked Error

**Before**:
```go
data, _ := json.Unmarshal(body, &obj)
```

**After**:
```go
data, err := json.Unmarshal(body, &obj)
if err != nil {
    return fmt.Errorf("unmarshal failed: %w", err)
}
```

**Risk**: Medium - adds error handling

---

## C#

### Null Reference (S2259)

**Before**:
```csharp
var name = user.Profile.Name;
```

**After**:
```csharp
var name = user?.Profile?.Name ?? "Anonymous";
```

**Risk**: Low - null-conditional operator

---

### Resource Not Disposed (S2953)

**Before**:
```csharp
var stream = new FileStream(path, FileMode.Open);
var content = Read(stream);
```

**After**:
```csharp
using (var stream = new FileStream(path, FileMode.Open))
{
    var content = Read(stream);
}
```

**Risk**: Low - proper disposal

---

## Rust

### Potential None Unwrap

**Before**:
```rust
let value = map.get("key").unwrap();
```

**After**:
```rust
let value = map.get("key").unwrap_or(&default_value);
```

**Risk**: Low - avoids panic

---

### Result Unwrap

**Before**:
```rust
let data = parse(input).unwrap();
```

**After**:
```rust
let data = match parse(input) {
    Ok(d) => d,
    Err(e) => return Err(e.into()),
};
```

**Risk**: Low - proper error handling

---

## Summary Table

| Language | Common Bug | Common Fix Pattern | Risk |
|----------|-----------|-------------------|------|
| Java | NPE | Null check / Optional | Low |
| Java | Resource leak | Try-with-resources | Low |
| Java | Logic error | Fix condition | Medium |
| JS/TS | Undefined | Optional chaining | Low |
| Python | None access | Defensive get() | Low |
| Go | Nil dereference | Explicit nil check | Low |
| C# | Null reference | Null-conditional | Low |
| Rust | None unwrap | unwrap_or / match | Low |
