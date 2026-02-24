---
name: sonarqube-fetcher
description: >-
  Queries SonarQube or SonarCloud for code quality metrics, issues, security
  hotspots, and quality gates. Use when asked to analyze code quality, find
  bugs, review security issues, check project health via SonarQube, or when
  another agent needs SonarQube data.
model: haiku
permissionMode: bypassPermissions
tools:
  - Bash
  - Read
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

| Category            | Tools                                                    |
|---------------------|----------------------------------------------------------|
| Project management  | `projects`                                               |
| Metrics & measures  | `metrics`, `measures_component`, `measures_components`, `measures_history` |
| Issue management    | `issues`, `markIssueFalsePositive`, `markIssueWontFix`, `markIssuesFalsePositive`, `markIssuesWontFix`, `addCommentToIssue`, `assignIssue`, `confirmIssue`, `unconfirmIssue`, `resolveIssue`, `reopenIssue` |
| Quality gates       | `quality_gates`, `quality_gate`, `quality_gate_status`   |
| Source code         | `source_code`, `scm_blame`                               |
| Security hotspots   | `hotspots`, `hotspot`, `update_hotspot_status`           |
| System monitoring   | `system_health`, `system_status`, `system_ping`          |

---

## Project management

### `projects`

List all SonarQube projects with pagination.

| Parameter   | Type   | Required | Description     |
|-------------|--------|----------|-----------------|
| `page`      | string | No       | Page number     |
| `page_size` | string | No       | Items per page  |

---

## Metrics & measures

### `metrics`

Get available metrics.

| Parameter   | Type   | Required | Description     |
|-------------|--------|----------|-----------------|
| `page`      | string | No       | Page number     |
| `page_size` | string | No       | Items per page  |

### `measures_component`

Get measures for a specific component.

| Parameter           | Type     | Required | Description                          |
|---------------------|----------|----------|--------------------------------------|
| `component`         | string   | **Yes**  | Component key                        |
| `metric_keys`       | string[] | **Yes**  | Metric keys (e.g. `["coverage"]`)    |
| `additional_fields` | string[] | No       | Additional fields to return          |
| `branch`            | string   | No       | Branch name                          |
| `pull_request`      | string   | No       | Pull request key                     |
| `period`            | string   | No       | Period index                         |

### `measures_components`

Get measures for multiple components.

| Parameter           | Type     | Required | Description                     |
|---------------------|----------|----------|---------------------------------|
| `component_keys`    | string[] | **Yes**  | Array of component keys         |
| `metric_keys`       | string[] | **Yes**  | Array of metric keys            |
| `additional_fields` | string[] | No       | Additional fields               |
| `branch`            | string   | No       | Branch name                     |
| `pull_request`      | string   | No       | Pull request key                |
| `period`            | string   | No       | Period index                    |
| `page`              | string   | No       | Page number                     |
| `page_size`         | string   | No       | Items per page                  |

### `measures_history`

Get measures history over time.

| Parameter      | Type     | Required | Description                   |
|----------------|----------|----------|-------------------------------|
| `component`    | string   | **Yes**  | Component key                 |
| `metrics`      | string[] | **Yes**  | Array of metric keys          |
| `from`         | string   | No       | Start date (`YYYY-MM-DD`)     |
| `to`           | string   | No       | End date (`YYYY-MM-DD`)       |
| `branch`       | string   | No       | Branch name                   |
| `pull_request` | string   | No       | Pull request key              |
| `page`         | string   | No       | Page number                   |
| `page_size`    | string   | No       | Items per page                |

---

## Issue management

### `issues`

Search and filter SonarQube issues. Supports extensive filtering.

**Component filters:**

| Parameter            | Type     | Required | Description                              |
|----------------------|----------|----------|------------------------------------------|
| `project_key`        | string   | No       | Single project key                       |
| `projects`           | string[] | No       | Multiple project keys                    |
| `component_keys`     | string[] | No       | Component keys (files, dirs, modules)    |
| `components`         | string[] | No       | Alias for `component_keys`               |
| `on_component_only`  | boolean  | No       | Only issues on specified components      |
| `directories`        | string[] | No       | Directory paths                          |
| `files`              | string[] | No       | File paths                               |
| `scopes`             | string[] | No       | `MAIN`, `TEST`, `OVERALL`                |

**Branch/PR:**

| Parameter        | Type   | Required | Description      |
|------------------|--------|----------|------------------|
| `branch`         | string | No       | Branch name      |
| `pull_request`   | string | No       | Pull request key |

**Issue filters:**

| Parameter     | Type     | Required | Description                                      |
|---------------|----------|----------|--------------------------------------------------|
| `issues`      | string[] | No       | Filter by issue keys                             |
| `severity`    | string   | No       | `INFO`, `MINOR`, `MAJOR`, `CRITICAL`, `BLOCKER`  |
| `severities`  | string[] | No       | Multiple severities                              |
| `statuses`    | string[] | No       | `OPEN`, `CONFIRMED`, `REOPENED`, `RESOLVED`, `CLOSED` |
| `resolutions` | string[] | No       | `FALSE-POSITIVE`, `WONTFIX`, `FIXED`, `REMOVED`  |
| `resolved`    | boolean  | No       | Filter resolved or unresolved                    |
| `types`       | string[] | No       | `CODE_SMELL`, `BUG`, `VULNERABILITY`, `SECURITY_HOTSPOT` |

**Clean Code taxonomy (SonarQube 10.x+):**

| Parameter                         | Type     | Required | Description                                         |
|-----------------------------------|----------|----------|-----------------------------------------------------|
| `clean_code_attribute_categories` | string[] | No       | `ADAPTABLE`, `CONSISTENT`, `INTENTIONAL`, `RESPONSIBLE` |
| `impact_severities`               | string[] | No       | `HIGH`, `MEDIUM`, `LOW`                             |
| `impact_software_qualities`       | string[] | No       | `MAINTAINABILITY`, `RELIABILITY`, `SECURITY`        |
| `issue_statuses`                  | string[] | No       | New issue status values                             |

**Rules & tags:**

| Parameter | Type     | Required | Description                        |
|-----------|----------|----------|------------------------------------|
| `rules`   | string[] | No       | Filter by rule keys                |
| `tags`    | string[] | No       | Filter by tags (e.g. `security`)   |

**Date filters:**

| Parameter         | Type   | Required | Description                         |
|-------------------|--------|----------|-------------------------------------|
| `created_after`   | string | No       | Issues created after date           |
| `created_before`  | string | No       | Issues created before date          |
| `created_at`      | string | No       | Issues created at exact date        |
| `created_in_last` | string | No       | Period (e.g. `7d`)                  |

**Assignment:**

| Parameter   | Type     | Required | Description                  |
|-------------|----------|----------|------------------------------|
| `assigned`  | boolean  | No       | Assigned/unassigned          |
| `assignees` | string[] | No       | Assignee logins              |
| `author`    | string   | No       | Single author                |
| `authors`   | string[] | No       | Multiple authors             |

**Security standards:**

| Parameter               | Type     | Required | Description                   |
|-------------------------|----------|----------|-------------------------------|
| `cwe`                   | string[] | No       | CWE identifiers               |
| `owasp_top10`           | string[] | No       | OWASP Top 10 categories       |
| `owasp_top10_v2021`     | string[] | No       | OWASP Top 10 2021 categories  |
| `sans_top25`            | string[] | No       | SANS Top 25 categories        |
| `sonarsource_security`  | string[] | No       | SonarSource security categories |

**Facets & sorting:**

| Parameter          | Type     | Required | Description                     |
|--------------------|----------|----------|---------------------------------|
| `facets`           | string[] | No       | Faceted search fields           |
| `facet_mode`       | string   | No       | `count` or `effort`             |
| `languages`        | string[] | No       | Programming languages           |
| `s`                | string   | No       | Sort field                      |
| `asc`              | boolean  | No       | Sort ascending                  |
| `additional_fields`| string[] | No       | Additional response fields      |
| `since_leak_period`| boolean  | No       | Leak period filter              |
| `in_new_code_period`| boolean | No       | New code period filter          |
| `page`             | string   | No       | Page number                     |
| `page_size`        | string   | No       | Items per page                  |

### Issue actions

All issue action tools accept `issue_key` (string, required) and optional `comment` (string):
`markIssueFalsePositive`, `markIssueWontFix`, `confirmIssue`, `unconfirmIssue`, `resolveIssue`, `reopenIssue`.

**Bulk actions** accept `issue_keys` (string[], required) and optional `comment`:
`markIssuesFalsePositive`, `markIssuesWontFix`.

### `addCommentToIssue`

| Parameter   | Type   | Required | Description                   |
|-------------|--------|----------|-------------------------------|
| `issue_key` | string | **Yes**  | The issue key                 |
| `text`      | string | **Yes**  | Comment text (markdown)       |

### `assignIssue`

| Parameter  | Type   | Required | Description                    |
|------------|--------|----------|--------------------------------|
| `issueKey` | string | **Yes**  | The issue key                  |
| `assignee` | string | No       | Username. Empty to unassign    |

---

## Quality gates

### `quality_gates`

List all available quality gates. No parameters.

### `quality_gate`

| Parameter | Type   | Required | Description      |
|-----------|--------|----------|------------------|
| `id`      | string | **Yes**  | Quality gate ID  |

### `quality_gate_status`

| Parameter      | Type   | Required | Description      |
|----------------|--------|----------|------------------|
| `project_key`  | string | **Yes**  | Project key      |
| `branch`       | string | No       | Branch name      |
| `pull_request` | string | No       | Pull request key |

---

## Source code

### `source_code`

| Parameter      | Type   | Required | Description      |
|----------------|--------|----------|------------------|
| `key`          | string | **Yes**  | File key         |
| `from`         | string | No       | Start line       |
| `to`           | string | No       | End line         |
| `branch`       | string | No       | Branch name      |
| `pull_request` | string | No       | Pull request key |

### `scm_blame`

Same parameters as `source_code`.

---

## Security hotspots

### `hotspots`

| Parameter           | Type     | Required | Description                    |
|---------------------|----------|----------|--------------------------------|
| `project_key`       | string   | No       | Project key                    |
| `branch`            | string   | No       | Branch name                    |
| `pull_request`      | string   | No       | Pull request ID                |
| `status`            | string   | No       | `TO_REVIEW` or `REVIEWED`      |
| `resolution`        | string   | No       | `FIXED` or `SAFE`              |
| `files`             | string[] | No       | File paths                     |
| `assigned_to_me`    | boolean  | No       | Show only assigned             |
| `since_leak_period` | boolean  | No       | Leak period filter             |
| `in_new_code_period`| boolean  | No       | New code period filter         |
| `page`              | string   | No       | Page number                    |
| `page_size`         | string   | No       | Items per page                 |

### `hotspot`

| Parameter     | Type   | Required | Description  |
|---------------|--------|----------|--------------|
| `hotspot_key` | string | **Yes**  | Hotspot key  |

### `update_hotspot_status`

| Parameter     | Type   | Required | Description                               |
|---------------|--------|----------|-------------------------------------------|
| `hotspot_key` | string | **Yes**  | Hotspot key                               |
| `status`      | string | **Yes**  | `TO_REVIEW` or `REVIEWED`                 |
| `resolution`  | string | No       | `FIXED` or `SAFE` (when `REVIEWED`)       |
| `comment`     | string | No       | Explanation                               |

---

## System monitoring

`system_health`, `system_status`, `system_ping` — no parameters required.

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
