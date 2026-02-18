---
name: generate-wikis
description: >
  Generate project wiki documentation (home, feature codeflows, UAT test cases,
  changelogs) into the wikis/ folder using myspec-debug save convention.
  Use when the user asks to generate wikis, project documentation, feature docs,
  codeflow descriptions, UAT test cases, changelogs, release notes, or project
  readme. Supports generating all doc types at once or individually via arguments.
  Do NOT use for code review, bug fixing, or non-documentation tasks.
allowed-tools: Read, Grep, Glob, Write, Bash
---

# Generate Wikis

## Usage
```
/generate-wikis all                          → generate everything
/generate-wikis home                         → project home readme only
/generate-wikis feature <path>               → codeflow doc for target code
/generate-wikis uat <path>                   → UAT test cases for target code
/generate-wikis changelog <version>          → changelog for specific version
```
If no arguments: ask the user what to generate.

## Output Structure
All output saves to `$(pwd)/myspec/debug/wikis/`:
```
wikis/
├── home.md
├── feature/{feature-name}.md
├── uat/{test-name}.md
├── changelog/{version}.md
├── feature.md                    ← index
├── uat.md                        ← index
└── changelog.md                  ← index
```

## Global Rules
- **Language**: All explanations in **Indonesian**. Do NOT translate technical terms.
- **Audience**: Non-programmers. Simple language, no jargon.
- **Save path**: Always `$(pwd)/myspec/debug/wikis/`

## Workflow

### Step 1: Setup
```bash
mkdir -p $(pwd)/myspec/debug/wikis/{feature,uat,changelog}
```

### Step 2: Parse $ARGUMENTS
Determine type and target from `$ARGUMENTS`.
If "all" → run Home → Feature → UAT → Changelog in order.

### Step 3: Generate by type
Branch to the matching section below.

### Step 4: Generate index files
After all docs are produced, create index files by scanning generated files.
Follow the format in [templates/sidebar.md](templates/sidebar.md).

**wikis/feature.md**: list links to each `feature/*.md`
**wikis/uat.md**: list links to each `uat/*.md`
**wikis/changelog.md**: list links to each `changelog/*.md`

### Step 5: Report
List all generated files with their paths.

---

## Type: Home

Read template: [templates/home.md](templates/home.md)

### Process
1. Analyze project structure, config files, package/dependency files, Dockerfiles, existing README
2. Generate `home.md` following the template
3. Save to `wikis/home.md`

---

## Type: Feature

Read template: [templates/feature.md](templates/feature.md)

### Process
1. **Study the code first (CRITICAL)**: Read ALL function calls in the target path
   and their nested inner code recursively until there are no remaining unread
   nested function calls. Follow every code path.
2. Generate documentation following the template exactly
3. If multiple processes exist → create a **separate file per process**
4. Save to `wikis/feature/{feature-name}.md`

### Content Rules

#### ❌ REMOVE
- Technical implementation (arrays, loops, API internals)
- Code terminology (methods, classes, functions)
- Performance details, error codes, stack traces
- Database schemas, programming patterns
- Technical log details (thread IDs, timestamps, debug info)

#### ✅ INCLUDE
- What users can do
- What information moves where
- Business rules and logic
- User-visible outcomes
- Common use cases and error scenarios
- Important business event logs (simplified)
- Sample data for ALL database/API/queue interactions
- Real-world analogies for complex processes

---

## Type: UAT

Read template: [templates/uat.md](templates/uat.md)

### Process
1. **Study the code first (CRITICAL)**: Read all function calls, classes recursively
   until there are no more nested calls to include.
2. Search inside the code to find test data requirements
3. If MCP database configured or use mcp code-mode in `.utcp_config.json` → use **SELECT queries ONLY**
   to retrieve real test data (never INSERT/UPDATE/DELETE)
4. Generate UAT following the template — **exclude edge-cases and performance-cases**
5. Save to `wikis/uat/{test-name}.md`

---

## Type: Changelog

Read template: [templates/changelog.md](templates/changelog.md)

### Process
1. Analyze git log, code changes, or user-provided version info
2. Generate changelog using Changelog format + Semantic Versioning
3. Only include sections that have content (Added, Changed, Deprecated, Removed, Fixed, Security)
4. Keep descriptions simple but with enough detail for non-programmers
5. Only one spesific version to be generated at a time (e.g. `1.2.0.md`)
6. Save to `wikis/changelog/{version}.md`

---

## Type: Flowchart

Read template: [templates/flowchart.md](templates/flowchart.md)

### Process
1. Use this for **visualizing flows** in feature documentation
2. Generate Mermaid flowchart in `wikis/feature/{feature-name}-flowchart.md`
3. Follow the template structure for shape definitions and connections
