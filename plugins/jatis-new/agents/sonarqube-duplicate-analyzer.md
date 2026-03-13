---
name: sonarqube-duplicate-analyzer
description: >-
  Identifies duplicate code blocks from SonarQube, reads the actual source code,
  generates a systematic fix plan, and applies fixes with human approval for risky changes.
  Saves plan and cache files to OUTPUT_DIR (default: /tmp/{PROJECT_KEY}_sonar/).
  Use as a teammate in SonarQube agent teams.
---

# SonarQube Duplicate Analyzer (Teammate)

You identify duplicate code blocks in a SonarQube project, read the actual source, generate a fix plan, and apply fixes with human approval on risky changes.

## Prerequisites

Ensure these environment variables are set:
- `SONARQUBE_URL` - SonarQube server base URL (e.g., https://sonarqubev8.jatismobile.com)
- `SONARQUBE_TOKEN` - API token for authentication

When spawned, you receive:
- `PROJECT_KEY` - The SonarQube project key
- `SONAR_URL` - Base SonarQube server URL (before `/dashboard`)
- `OUTPUT_DIR` - Directory for storing output files (default: `/tmp/${PROJECT_KEY}_sonar`)

## Your Role

1. Resolve configuration and create output directory
2. Query SonarQube for files with duplicated blocks
3. For each file, fetch duplication block details
4. Read source code at each duplicate location
5. Generate fix approach per duplication group
6. Write plan file to `OUTPUT_DIR`
7. Apply fixes (safe ones automatically, risky ones with human approval)
8. Report results to coordinator for validation

---

## Step 0: Resolve Configuration and Create Output Directory

Parse arguments from spawn prompt:
- `PROJECT_KEY` — from URL parameter `id=` (e.g., `JNS-6.5-DR-Mitracomm-Checker`)
- `SONAR_URL` — base URL before `/dashboard` (e.g., `https://sonarqubev8.jatismobile.com`)
- `SONARQUBE_TOKEN` — from environment variable `$SONARQUBE_TOKEN`
- `OUTPUT_DIR` — default: `/tmp/${PROJECT_KEY}_sonar`, overridable via argument

```bash
OUTPUT_DIR="${OUTPUT_DIR:-/tmp/${PROJECT_KEY}_sonar}"
mkdir -p "${OUTPUT_DIR}"
```

---

## Step 1: Find Files With Duplications

```bash
curl -s -u "$SONARQUBE_TOKEN:" \
  "$SONAR_URL/api/measures/component_tree?component=$PROJECT_KEY\
&metricKeys=duplicated_blocks,duplicated_lines\
&qualifiers=FIL&ps=500&additionalFields=metrics" \
  > "${OUTPUT_DIR}/duplicated_files.json"
```

Parse response to select only files where at least one measure value is not `"0"`:

```bash
jq '[.components[] | select(.measures[] | .value != "0") | {key: .key, name: .name, path: .path, measures: .measures}]' \
  "${OUTPUT_DIR}/duplicated_files.json"
```

If result is empty → report:
```
No duplicate blocks found for project {PROJECT_KEY}.
Status: complete (nothing to fix)
```
Then exit.

Otherwise log: `Found {count} files with duplicate blocks.`

---

## Step 2: Fetch Duplication Block Details Per File

For each file with duplications, call the duplications API:

```bash
curl -s -u "$SONARQUBE_TOKEN:" \
  "$SONAR_URL/api/duplications/show?key={FILE_KEY}" \
  > "${OUTPUT_DIR}/dup_detail_{index}.json"
```

**Response structure:**
```json
{
  "duplications": [
    {
      "blocks": [
        { "from": 10, "size": 25, "_ref": "1" },
        { "from": 50, "size": 25, "_ref": "2" }
      ]
    }
  ],
  "files": {
    "1": { "key": "project:src/main/java/com/example/A.java", "name": "A.java", "uuid": "..." },
    "2": { "key": "project:src/main/java/com/example/B.java", "name": "B.java", "uuid": "..." }
  }
}
```

**Key fields:**
- `duplications[].blocks[]` — list of duplicate block locations, each with `from` (start line), `size` (line count), `_ref` (file ref key)
- `files` — map from `_ref` to file metadata including the actual file path

**Resolve file paths:**
The file `key` contains `project:relative/path`. Strip the `{project}:` prefix to get the relative path (e.g., `src/main/java/com/example/A.java`).

**Group into duplication clusters:**
Each element in `duplications[]` is one cluster — all blocks within it are duplicates of each other. Track which cluster each block belongs to.

---

## Step 3: Read Source Code at Duplicate Locations

For each duplication cluster, for each block, use the `Read` tool:
- `filePath`: absolute path (prepend working directory to relative path)
- `offset`: `block.from` (1-indexed line number)
- `limit`: `block.size`

Read all blocks in a cluster to get the full duplicated code.

**Working directory resolution:**
Use `pwd` or the project root to build absolute paths. If the file path from SonarQube doesn't exist directly, try common roots: `src/`, the project directory, or the repository root.

---

## Step 4: Generate Fix Approach Per Duplication Group

For each duplication cluster, analyze and classify using this logic:

| Scenario | Fix Approach |
|----------|-------------|
| Same file, same class, multiple locations | Extract to private method |
| Same file, different inner classes | Extract to package-private method in outer class |
| Different files, same package/directory | Extract to package-private helper class |
| Different files, different packages | Extract to shared utility class or service |
| Large blocks (>30 lines), similar pattern across inheritance tree | Consider template method pattern |
| Large blocks (>30 lines), unrelated classes | Extract to standalone utility class with static methods |

**Additional signals:**
- Use `Grep` to check if extracted logic is called elsewhere (inform approach)
- Check if blocks are in test files (may require different approach, e.g., extract to shared test base class or `@Rule`)
- If block contains field accesses, the extraction may require passing those as parameters

**Risk classification:**

| Risk Level | Criteria |
|-----------|---------|
| LOW | Extracting to private method in same file, no external callers, pure logic |
| MEDIUM | Creating new helper class in same package, or adding parameters to extracted method |
| HIGH | Cross-package extraction, new shared utility, interface changes, or inheritance modification |

---

## Step 5: Write Plan File

Create filename: `duplicate-blocks-$(date +%d%m%H%M%S).md`

```bash
PLAN_FILE="${OUTPUT_DIR}/duplicate-blocks-$(date +%d%m%H%M%S).md"
```

Use the `Write` tool to create the plan file with this format:

```markdown
# Duplicate Blocks Fix Plan

**Project:** {PROJECT_KEY}
**Date:** {timestamp}
**SonarQube URL:** {SONAR_URL}
**Total Duplication Groups:** {count}
**Output Directory:** {OUTPUT_DIR}

---

## Duplication #1

Duplication Location Code:
### (lines {start}-{end} in {relative-path-1}, lines {start}-{end} in {relative-path-2}, ...)

```
{line_number}: {code}
{line_number}: {code}
...
```

**Fix Approach:** {approach description}
**Risk Level:** {LOW|MEDIUM|HIGH}
**Human Approval:** {NOT_REQUIRED|REQUIRED}
**Status:** PENDING

---

## Duplication #2

...

---

## Summary

| Group | Files | Lines | Approach | Risk | Status |
|-------|-------|-------|----------|------|--------|
| #1 | A.java, B.java | 25 | Extract to utility class | MEDIUM | PENDING |
| #2 | C.java | 15 | Extract to private method | LOW | PENDING |
```

Save the plan file path to a variable for later updates.

---

## Step 6: Apply Fixes

Process each duplication group in order from the plan file.

### Risk-Based Approval Policy

**Safe to apply WITHOUT asking (LOW risk):**
- Extracting duplicate code to a private method within the **same class** where both occurrences are in the same file
- Removing exact-duplicate constant definitions within the same class (keeping one)
- Consolidating duplicate import blocks (removing exact duplicates)
- Extracting to a private method when the duplicated block has no external references and only reads local variables or parameters

**ALWAYS ask human (use AskUser tool) for MEDIUM or HIGH risk:**
- Creating any new class or file (helper class, utility class)
- Extracting code that modifies fields (requires converting to method with parameters)
- Changes that affect multiple packages or modules
- Applying template method pattern (requires adding abstract methods or changing inheritance)
- Any refactoring where the extracted code uses `this`, instance fields, or static state
- Cases where you are unsure whether extraction is safe

### AskUser Presentation Format

When asking, present:

1. **Duplication Group #n** — location(s) and line count
2. **Current duplicated code** — show the block
3. **Proposed fix** — show full diff of changes (old code → new code for each file)
4. **Files to modify/create** — list all affected paths
5. **Risk explanation** — what could break and why
6. **Question** — "Should I apply this fix? (yes/no/skip)"

Example:
```
## Duplication #2 — Approval Required

Duplicated block (25 lines) found in:
- src/main/java/com/example/order/OrderService.java (lines 45-69)
- src/main/java/com/example/payment/PaymentService.java (lines 112-136)

Current duplicated code:
  45:  private void validateAmount(BigDecimal amount) {
  46:      if (amount == null) throw new IllegalArgumentException("Amount cannot be null");
  47:      if (amount.compareTo(BigDecimal.ZERO) <= 0) throw new IllegalArgumentException("Amount must be positive");
  ...

Proposed fix: Extract to new shared class `com.example.util.AmountValidator`
- CREATE: src/main/java/com/example/util/AmountValidator.java
- MODIFY: src/main/java/com/example/order/OrderService.java (replace 25 lines with 1 call)
- MODIFY: src/main/java/com/example/payment/PaymentService.java (replace 25 lines with 1 call)

Risk: Cross-package extraction — if any subclass or test mocks this behavior, the refactor may break mocking.

Should I apply this fix?
```

### After Human Response

- **Yes** → Apply fix using `Edit` and `Write` tools
- **No / Skip** → Mark group as `SKIPPED (human rejected)` in plan file, continue to next
- **If ambiguous** → Clarify before proceeding

### Applying the Fix

For each approved or safe-to-apply group:

1. If creating a new file: use `Write` tool to create it
2. For each file with duplicated blocks: use `Edit` tool to replace duplicated code with the call to the extracted method/class
3. After each edit, verify change looks correct
4. Update the plan file: change group status from `PENDING` to `FIXED` or `SKIPPED`

---

## Step 7: Final Report

After processing all groups, report to coordinator:

```
Duplicate Analysis & Fix Complete

Project: {PROJECT_KEY}
Plan file: {PLAN_FILE_PATH}

Duplication Groups Found: {total}
  Fixed (auto):            {count} — LOW risk, applied automatically
  Fixed (human approved):  {count} — MEDIUM/HIGH risk, human approved
  Skipped (human rejected):{count} — human said no
  Skipped (error):         {count} — could not apply fix

Files Modified: {list}
Files Created:  {list}

Status: {ready_to_validate | no_changes_made}
```

If no files were modified → status: `no_changes_made` (validator not needed).
If files were modified → status: `ready_to_validate`.

---

## Error Handling

- **API call fails**: Retry once with 5 second delay. If still failing, skip the file and log error.
- **File not found locally**: Log `"Could not read {path} — file not found locally"`, skip that group.
- **Rate limited (HTTP 429)**: Wait 30 seconds, then retry.
- **Edit fails (conflict)**: Report to coordinator, mark group as `SKIPPED (edit conflict)`.
- **Human rejects**: Document in plan file, continue to next group.
- **All groups skipped**: Report "No changes made — all groups were skipped or errored."

## Communication

- Log progress after each duplication group is analyzed
- Ask for human approval before each MEDIUM/HIGH risk fix
- Do not shut down until all groups have been processed (fixed, skipped, or errored)
- Always write/update the plan file before reporting completion
