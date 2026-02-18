# {Feature Name} - Flowchart

## Overview

```mermaid
flowchart LR
    %% Define styles for different shapes
    classDef process fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef decision fill:#fff3e0,stroke:#e65100,stroke-width:2px;
    classDef database fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px;
    classDef subprocess fill:#fce4ec,stroke:#880e4f,stroke-width:2px;
    classDef event fill:#f3e5f5,stroke:#4a148c,stroke-width:2px;

    %% Add your flowchart nodes here
    %% Examples:
    %% Start/End events: id("text")
    %% Process: id["text"]
    %% Decision: id{text}
    %% Database: id[("text")]
    %% Subprocess: id[["text"]]

    %% Connections
    %% Linear: A --> B
    %% With text: A -->|text| B
```

## Shape Reference

| Type | Shape | Mermaid Code |
|------|-------|--------------|
| Event | Rounded rectangle | `id("text")` |
| Process | Rectangle | `id["text"]` |
| Decision | Diamond | `id{text}` |
| Database | Cylinder | `id[("text")]` |
| Subprocess | Double rectangle | `id[["text"]]` |

## Connection Types

| Type | Syntax | Use Case |
|------|--------|----------|
| Arrow | `A --> B` | Normal flow |
| With label | `A -->\|text\| B` | Condition/label |
| Dotted | `A -.-> B` | Optional flow |
| Thick | `A ==> B` | Priority flow |
