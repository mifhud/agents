---
name: sonarqube-fetcher
description: >-
  Queries SonarQube or SonarCloud for code quality metrics, issues, security
  hotspots, and quality gates. Use when asked to analyze code quality, find
  bugs, review security issues, check project health via SonarQube, or when
  another skill needs SonarQube data.
---

# SonarQube Fetcher

Queries and manages SonarQube/SonarCloud projects, issues, metrics, quality
gates, security hotspots, and source code.

## Prerequisites

| Variable                 | Required | Default                   |
|--------------------------|----------|---------------------------|
| `SONARQUBE_URL`          | No       | `https://sonarcloud.io`   |
| `SONARQUBE_TOKEN`        | Yes      | —                         |
| `SONARQUBE_ORGANIZATION` | No       | — (required for SonarCloud) |

## Fetcher Methods
- Try curl first (primary method)
- If curl fails, fallback to MCP SonarQube (secondary method)
- If both fail, report the error clearly
- When using curl, save the temporary response to /tmp with a filename prefixed by PROJECT_KEY

## Tools reference

For complete parameter details on all tools, see [tools-reference.md](tools-reference.md).

### Quick summary

| Category            | Tools                                                    |
|---------------------|----------------------------------------------------------|
| Project management  | `projects`                                               |
| Metrics & measures  | `metrics`, `measures_component`, `measures_components`, `measures_history` |
| Issue management    | `issues`, `markIssueFalsePositive`, `markIssueWontFix`, `markIssuesFalsePositive`, `markIssuesWontFix`, `addCommentToIssue`, `assignIssue`, `confirmIssue`, `unconfirmIssue`, `resolveIssue`, `reopenIssue` |
| Quality gates       | `quality_gates`, `quality_gate`, `quality_gate_status`   |
| Source code         | `source_code`, `scm_blame`                               |
| Security hotspots   | `hotspots`, `hotspot`, `update_hotspot_status`           |
| System monitoring   | `system_health`, `system_status`, `system_ping`          |

## Common workflows

### Project health check

1. `projects` → list available projects
2. `quality_gate_status` → check gate status
3. `measures_component` with `["bugs", "vulnerabilities", "code_smells", "coverage", "duplicated_lines_density"]`
4. `issues` with `severities: ["CRITICAL", "BLOCKER"]`

### Security audit

1. `issues` with `types: ["VULNERABILITY"]` and `severities: ["CRITICAL", "BLOCKER"]`
2. `hotspots` with `status: "TO_REVIEW"`
3. `hotspot` for details → `source_code` for affected code
4. `update_hotspot_status` to mark reviewed

### PR quality review

1. `quality_gate_status` with `pull_request` parameter
2. `issues` with `pull_request` to find new issues
3. `measures_component` with `pull_request` to check coverage delta

### Issue triage

1. `issues` with `facets: ["severities", "types", "assignees"]` for dashboard
2. `assignIssue` to distribute work
3. `markIssueFalsePositive` / `markIssueWontFix` for non-actionable issues

### Metrics trend analysis

1. `metrics` to discover available keys
2. `measures_history` with `from`/`to` dates
3. Compare across branches using the `branch` parameter
