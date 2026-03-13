# {Feature Name}

## Overview

### What This Does
{2-3 sentences explaining business value in plain English}

### Who Uses This
- **{User Type}**: {Purpose}
- **{User Type}**: {Purpose}

### System Flow Summary
1. **Start**: {Initial process}
2. **Main**: {Core processes}
3. **End**: {Completion}

### Key Business Rules
- {Important cross-cutting rule 1}
- {Important cross-cutting rule 2}

---

## How Processes Connect
```plaintext
[Process 1] → [Process 2] → [Process 3]
     ↓                ↓
[Process 4]      [Process 5]
```

**Connection Details**:
- Process 1 triggers Process 2 when {condition}
- Process 2 can trigger Process 3 or Process 4 depending on {decision}
- Process 5 runs independently when {condition}

---

## Process 1: {User-Friendly Process Title}

### Purpose
{One-line plain language explanation}

### Details
- **Who uses**: {User types}
- **Connects to**: [Process 2, Process 3]
- **Started from**: [Initial trigger or previous process]

### What This Does
{2-3 sentences a non-programmer can understand}

### Configuration (if applicable)
| Name | Source | Description |
|------|--------|-------------|
| {Setting 1} -> (plain config if applicable) | {Where it comes from} | {Short explanation} |
| {Setting 2} -> (plain config if applicable) | {Where it comes from} | {Short explanation} |

### Flow Steps

#### Start
- **Trigger**: {What starts this process in simple terms}
- **Log**: `{original log message}` → {Plain explanation}

#### Step 1: {Step Title}
- **Type**: Process/Decision/Database/Subprocess
- **What happens**: {Simple explanation, real-world analogy}
- **If decision**: YES → Step 2, NO → Step 3
- **Log**: `{original log}` → {What it means}

#### Step 2: {Data Interaction Step}
- **Type**: Database/API/Queue
- **Action**: {What data moves where and why}
- **Destination**: {Business-friendly system name}
- **Input Data**:
  ```
  {Realistic sample in programmer format}
  ```
- **Output/Response**:
  ```
  {Sample response in programmer format}
  ```
- **Log**: `{original log}` → {Plain explanation}

#### End
- **Result**: {What user sees or what happens next}
- **Next step**: {Link to next process if applicable}
- **Log**: `{original log}` → {What it means}

### Common Scenarios
- **Typical Use**: {Normal flow description}
- **When Wrong**: {Error handling description}

---

## Process 2: {User-Friendly Process Title}

{Repeat the same structure as Process 1}

---

## Data Interaction Requirements

For EVERY database/API/queue/external system interaction, include:

1. **Destination**: Where data goes (use business names: "Customer Database" not "PostgreSQL users table")
2. **Sample Input**: Realistic data being sent (programmer format, no real personal info)
3. **Sample Output**: What comes back, with plain-language status
4. **Log Message**: Original log + plain explanation

### Example Pattern

#### Step 3: Save Customer Info
- **Type**: Database
- **Action**: Customer data saved permanently
- **Destination**: Customer Database
- **Input**:
  ```
  Customer Name: John Doe
  Email: john@example.com
  Phone: 555-0123
  ```
- **Output**:
  ```
  Status: Saved
  Customer ID: CUST-001
  ```
- **Log**: `INFO: Customer profile saved - ID: CUST-001`
  → Customer information successfully stored

---

## Log Message Guidelines

**Only include business-relevant logs:**
- INFO = Normal activity recorded
- WARN = Unusual but system continues
- ERROR = Problem needs attention

**Simplify logs:**
- ❌ Before: `2025-11-24 10:15:23.456 [pool-1-thread-3] INFO c.j.d.ProcessorService - TX-12345 processed. Status: COMPLETED. Duration: 1234ms`
- ✅ After: `INFO: Order #12345 processed successfully` → Order completed without issues
