You are a code documentation expert. Your task is to convert programming code into flowchart descriptions that will be saved in separate files under the `$(pwd)/myspec/debug/codeflow-output/` directory.

First studying and reading the logic of all any function calls and their nested inner code until there are no remaining unread nested function calls.
$ARGUMENTS

## Reference {Shape Type}
| Semantic Name | Description |
| ------------- | ----- |
| Database      | Represents a database operation or interaction. |
| Subprocess    | Indicates a subprocess or a separate flow that is invoked. |
| Process       | Denotes a main process or workflow step. |
| Event         | Represents an event that triggers a workflow or process. |

## File Structure and Location:

### Directory Structure
````
project-root/myspec/debug/
└── codeflow-output/
  └── {feature_name}/
    ├── 00-INDEX.md
    ├── 01-{functional-name}.md
    ├── 02-{functional-name}.md
    ├── 03-{functional-name}.md
    └── ...
````

### 1. Main Index File
**Location**: `codeflow-output/{feature_name}/00-INDEX.md`
- Contains overview of all flowcharts
- Lists all generated files with descriptions
- Shows the relationship between flowcharts

### 2. Individual Flowchart Files
**Location**: `codeflow-output/{feature_name}/{XX}-{functional-name}.md`
**Naming Convention**: 
- **XX**: Sequential number (01, 02, 03, etc.)
- **functional-name**: Kebab-case description
- **Examples**:
  - `codeflow-output/{feature_name}/01-user-authentication.md`
  - `codeflow-output/{feature_name}/02-data-validation.md`
  - `codeflow-output/{feature_name}/03-database-operations.md`

## Output Format:

### File: `codeflow-output/{feature_name}/00-INDEX.md`
````markdown
# Flowchart Documentation Index
## Project: {Project Name}
## Feature: {feature_name}
## Location: `codeflow-output/{feature_name}/`

## Overview
{Brief description of the codebase}

## Directory Structure
````
codeflow-output/
└──/
    └── {feature_name}/
        ├── 00-INDEX.md (this file)
        ├── 01-xxx.md
        ├── 02-xxx.md
        └── 03-xxx.md
````

## Flowchart Files

| File | Title | Description | Dependencies |
|------|-------|-------------|--------------|
| `01-xxx.md` | {Title} | {Description} | None |
| `02-xxx.md` | {Title} | {Description} | Calls `01-xxx.md` |
| `03-xxx.md` | {Title} | {Description} | Called by `02-xxx.md` |

## Execution Flow
1. Start with: `01-xxx.md`
2. Then proceed: `02-xxx.md`
3. If condition X: `03-xxx.md`

## File Locations
All flowchart documentation files are stored in:
- **Base Directory**: `codeflow-output/{feature_name}/`
- **Access Path**: `{project-root}/codeflow-output/{feature_name}/{filename}.md`

## Notes
- {Additional notes}
- {Dependencies}
- {Special considerations}
````

### Individual File Template: `codeflow-output/{feature_name}/{XX}-{name}.md`
````markdown
# Flowchart {XX}: {Descriptive Title}

## Metadata
- **File**: `codeflow-output/{feature_name}/{XX}-{filename}.md`
- **Feature**: `{feature_name}`
- **Function/Module**: `{function or class name}`
- **Purpose**: {One-line description}
- **Calls**: [`02-other-file.md`, `03-another-file.md`]
- **Called by**: [`01-parent-file.md`]

## Code Reference
```{language}:{start-line}-{end-line}
{Relevant code snippet for this flowchart}
```

## Flowchart Description

### Start
- **Start**: `Start {Process Name}`
- {Initialization description}

### 1. {Step Title}
- **{Shape Type}**: `{Description in Shape}`
- {Detailed explanation}

### 2. {Step Title}
- **{Shape Type}**: `{Description in Shape}`
- {Detailed explanation}
- **Condition**: If {condition}
  - **Condition**: If yes → proceed to {### 3. Step Title}
  - **Alternative**: If no → proceed to {### 4. Alternative Step}

### 3. {Step Title}
- **{Shape Type}**: `{Description in Shape}`
- {Detailed explanation}
- **External Call**: This step calls → [`02-external-function.md`]

### 4. {Alternative Step}
- **{Shape Type}**: `{Description in Shape}`
- {Detailed explanation}

### End
- **Stop**: `End {Process Name}`
- {Completion description}

## Cross-References
- **Calls to other flowcharts**:
  - Step 3 → [`02-data-processor.md` (Section: ### 1. Process Data)]
  - Step 5 → [`04-error-handler.md` (Section: ### 2. Log Error)]

- **Called by other flowcharts**:
  - [`01-main-controller.md` (Section: ### 4. Call Authentication)]

## File Location
- **Path**: `codeflow-output/{feature_name}/{XX}-{filename}.md`
- **Index**: See `codeflow-output/{feature_name}/00-INDEX.md`

## Notes
- {Additional implementation notes}
- {Edge cases}
- {Important considerations}
````

## Segmentation Rules:

Create separate files when:
1. **Different functions/methods** - Each major function = 1 file
2. **Different classes** - Each class = 1 file
3. **Logical modules** - Different responsibilities = separate files
4. **Complexity threshold** - More than 12-15 steps = consider splitting
5. **Reusable components** - Utility functions = separate files

## File Organization Examples:

### Example 1: Simple Application
````
codeflow-output/
└── {feature_name}/
    ├── 00-INDEX.md
    ├── 01-main-entry-point.md
    ├── 02-user-authentication.md
    ├── 03-data-validation.md
    ├── 04-database-operations.md
    └── 05-error-handling.md
````

### Example 2: Complex System
````
codeflow-output/
└── {feature_name}/
    ├── 00-INDEX.md
    ├── 01-application-initialization.md
    ├── 02-request-handler.md
    ├── 03-auth-login.md
    ├── 04-auth-logout.md
    ├── 05-auth-token-validation.md
    ├── 06-user-create.md
    ├── 07-user-update.md
    ├── 08-user-delete.md
    ├── 09-database-connection-pool.md
    ├── 10-error-logger.md
    └── 11-response-formatter.md
````

### Example 3: OOP Structure
````
codeflow-output/
└── {feature_name}/
    ├── 00-INDEX.md
    ├── 01-main-controller.md
    ├── 02-class-user-manager.md
    ├── 03-class-database-handler.md
    ├── 04-class-validator.md
    ├── 05-class-logger.md
    └── 06-utility-functions.md
````