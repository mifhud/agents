# Code Documentation for Non-Programmers

## Objective

First studying and reading the logic of all any function calls and their nested inner code until there are no remaining unread nested function calls.
$ARGUMENTS

Then,
Convert code into plain-language flowchart descriptions that explain WHAT the system does (not HOW). Output saves to: `$(pwd)/myspec/debug/codeflow-non-programmers/`

## Core Principles

- **Simple language** - No jargon, everyday terms only
- **Business focus** - User/business perspective, not technical implementation
- **Show examples** - Include sample data for all database/API/queue interactions
- **Use analogies** - Compare complex processes to familiar concepts
- **Include logs** - Show important business event logs with plain explanations

---

## File Structure

```
myspec/debug/codeflow-non-programmers/{feature_name}/
├── 00-OVERVIEW.md
├── 01-{process-name}.md
├── 02-{process-name}.md
└── ...
```

---

## Template: `00-OVERVIEW.md`

```
# {Feature Name} - Overview

## What This Does
{2-3 sentences explaining business value in plain English}

## Who Uses This
- **{User Type}**: {Purpose}

## Process Files
| File | What It Does | Who Uses It |
|------|--------------|-------------|
| \`01-{name}.md\` | {Description} | {Users} |

## System Flow
1. **Start**: {Initial process}
2. **Main**: {Core processes}
3. **End**: {Completion}

## Key Business Rules
- {Important cross-cutting rules}

## Common Journeys
**Happy Path**: {Step-by-step success scenario}
**Error Recovery**: {What happens when things go wrong}
```

---

## Template: `{XX}-{process-name}.md`

```
# {User-Friendly Process Title}

## Metadata
- **Purpose**: {One-line plain language explanation}
- **Who uses**: {User types}
- **Connects to**: [{Next processes}]
- **Started from**: [{Previous processes}]

## What This Does
{2-3 sentences a non-programmer can understand}

## Configuration (if applicable)
| Setting | Source | Description |
|---------|--------|-------------|
| {Setting 1} -> (plain config if applicable) | {Where it comes from} | {Short explanation} |
| {Setting 2} -> (plain config if applicable) | {Where it comes from} | {Short explanation} |

## Flow Steps

### Start
- **Start**: \`{Process name}\`
- Begins when {trigger in simple terms}
- **Log**: \`{original log message}\` → {Plain explanation}

### 1. {Step Title}
- **Process/Decision/Database/Subprocess**: \`{What happens}\`
- {Simple explanation, real-world analogy}
- **If decision**: YES → Step 2, NO → Step 3
- **Log**: \`{original log}\` → {What it means}

### 2. {Data Interaction Step}
- **Database/Subprocess**: \`{Action}\`
- {What data moves where and why}
- **Destination**: {Business-friendly system name}
- **Input Data**:
\`\`\`
{Realistic sample in programmer format}
\`\`\`
- **Output/Response**:
\`\`\`
{Sample response in programmer format}
\`\`\`
- **Log**: \`{original log}\` → {Plain explanation}

### End
- **Stop**: \`{Process completion}\`
- {What user sees or what happens next}
- **Log**: \`{original log}\` → {What it means}

## Cross-References
- **Triggers**: Step X → [\`02-next.md\`] - {Why}
- **Triggered by**: [\`01-prev.md\`] - {When}

## Common Scenarios
**Typical Use**: {Normal flow}
**When Wrong**: {Error handling}
```

---

## Content Guidelines

### ❌ REMOVE

- Technical implementation (arrays, loops, APIs)
- Code terminology (methods, classes, functions)
- Performance details, error codes, stack traces
- Database schemas, programming patterns
- Technical log details (thread IDs, timestamps, debug info)

### ✅ INCLUDE

- What users can do
- What information moves where
- Business rules and logic
- User-visible outcomes
- Common use cases and error scenarios
- Important business event logs (simplified)

---

## Data Interaction Requirements

For EVERY database/API/queue/external system interaction, include:

1. **Destination**: Where data goes (use business names: "Customer Database" not "PostgreSQL users table")
2. **Sample Input**: Realistic data being sent (programmer format, no real personal info)
3. **Sample Output**: What comes back, with plain-language status
4. **Log Message**: Original log + plain explanation

### Example Pattern

```
### 3. Save Customer Info
- **Database**: \`Store customer profile\`
- Customer data saved permanently
- **Destination**: Customer Database
- **Input**:
\`\`\`
Customer Name: John Doe
Email: john@example.com
Phone: 555-0123
\`\`\`
- **Output**:
\`\`\`
Status: Saved
Customer ID: CUST-001
\`\`\`
- **Log**: \`INFO: Customer profile saved - ID: CUST-001\`
  → Customer information successfully stored
```

---

## Log Message Guidelines

**Only include business-relevant logs:**

- INFO = Normal activity recorded
- WARN = Unusual but system continues
- ERROR = Problem needs attention

**Simplify logs:**

- ❌ Before: `2025-11-24 10:15:23.456 [pool-1-thread-3] INFO c.j.d.ProcessorService - TX-12345 processed. Status: COMPLETED. Duration: 1234ms`
- ✅ After: `INFO: Order #12345 processed successfully` → Order completed without issues

---

## File Naming

Use descriptive, non-technical names:

- ✅ `01-user-login-process.md`
- ✅ `02-customer-data-entry.md`
- ❌ `01-auth-middleware.md`
- ❌ `02-crud-operations.md`