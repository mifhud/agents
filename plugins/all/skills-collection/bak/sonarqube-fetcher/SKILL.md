---
name: sonarqube-fetcher
description: "Queries SonarQube/SonarCloud for code quality metrics, issues, security hotspots, and quality gates. Use when asked to analyze code quality, find bugs, review security issues, or check project health via SonarQube."
---

# SonarQube Skill

Query and manage SonarQube/SonarCloud projects, issues, metrics, quality gates, security hotspots, and source code directly from the agent.

## Prerequisites

Set these environment variables before use:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `SONARQUBE_URL` | SonarQube instance URL | No | `https://sonarcloud.io` |
| `SONARQUBE_TOKEN` | Authentication token | Yes | - |
| `SONARQUBE_ORGANIZATION` | Organization key (required for SonarCloud) | No | - |

## Tools Reference

### Project Management

#### `projects`
List all SonarQube projects with pagination.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | string | No | Page number |
| `page_size` | string | No | Items per page |

### Metrics & Measures

#### `metrics`
Get available metrics from SonarQube.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | string | No | Page number |
| `page_size` | string | No | Items per page |

#### `measures_component`
Get measures for a specific component.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `component` | string | **Yes** | Component key |
| `metric_keys` | string[] | **Yes** | Array of metric keys (e.g., `["coverage", "bugs", "vulnerabilities"]`) |
| `additional_fields` | string[] | No | Additional fields to return |
| `branch` | string | No | Branch name |
| `pull_request` | string | No | Pull request key |
| `period` | string | No | Period index |

#### `measures_components`
Get measures for multiple components at once.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `component_keys` | string[] | **Yes** | Array of component keys |
| `metric_keys` | string[] | **Yes** | Array of metric keys |
| `additional_fields` | string[] | No | Additional fields to return |
| `branch` | string | No | Branch name |
| `pull_request` | string | No | Pull request key |
| `period` | string | No | Period index |
| `page` | string | No | Page number |
| `page_size` | string | No | Items per page |

#### `measures_history`
Get measures history for a component over time.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `component` | string | **Yes** | Component key |
| `metrics` | string[] | **Yes** | Array of metric keys |
| `from` | string | No | Start date (`YYYY-MM-DD`) |
| `to` | string | No | End date (`YYYY-MM-DD`) |
| `branch` | string | No | Branch name |
| `pull_request` | string | No | Pull request key |
| `page` | string | No | Page number |
| `page_size` | string | No | Items per page |

### Issue Management

#### `issues`
Search and filter SonarQube issues. Supports extensive filtering by severity, status, assignee, tag, file path, scope, clean code taxonomy, security standards, and faceted search.

**Component filters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project_key` | string | No | Single project key |
| `projects` | string[] | No | Filter by multiple project keys |
| `component_keys` | string[] | No | Filter by component keys (files, directories, modules) |
| `components` | string[] | No | Alias for `component_keys` |
| `on_component_only` | boolean | No | Only issues on specified components, not sub-components |
| `directories` | string[] | No | Filter by directory paths |
| `files` | string[] | No | Filter by file paths |
| `scopes` | string[] | No | Filter by scope: `MAIN`, `TEST`, `OVERALL` |

**Branch/PR:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `branch` | string | No | Branch name |
| `pull_request` | string | No | Pull request key |

**Issue filters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issues` | string[] | No | Filter by issue keys |
| `severity` | string | No | Single severity: `INFO`, `MINOR`, `MAJOR`, `CRITICAL`, `BLOCKER` |
| `severities` | string[] | No | Multiple severities |
| `statuses` | string[] | No | Statuses: `OPEN`, `CONFIRMED`, `REOPENED`, `RESOLVED`, `CLOSED` |
| `resolutions` | string[] | No | Resolutions: `FALSE-POSITIVE`, `WONTFIX`, `FIXED`, `REMOVED` |
| `resolved` | boolean | No | Filter resolved (`true`) or unresolved (`false`) |
| `types` | string[] | No | Types: `CODE_SMELL`, `BUG`, `VULNERABILITY`, `SECURITY_HOTSPOT` |

**Clean Code taxonomy (SonarQube 10.x+):**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `clean_code_attribute_categories` | string[] | No | `ADAPTABLE`, `CONSISTENT`, `INTENTIONAL`, `RESPONSIBLE` |
| `impact_severities` | string[] | No | `HIGH`, `MEDIUM`, `LOW` |
| `impact_software_qualities` | string[] | No | `MAINTAINABILITY`, `RELIABILITY`, `SECURITY` |
| `issue_statuses` | string[] | No | New issue status values |

**Rules & tags:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `rules` | string[] | No | Filter by rule keys |
| `tags` | string[] | No | Filter by tags (e.g., `security`, `bug`) |

**Date filters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `created_after` | string | No | Issues created after date |
| `created_before` | string | No | Issues created before date |
| `created_at` | string | No | Issues created at exact date |
| `created_in_last` | string | No | Issues created in last period (e.g., `7d`) |

**Assignment:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `assigned` | boolean | No | Filter assigned/unassigned |
| `assignees` | string[] | No | Filter by assignee logins |
| `author` | string | No | Filter by single author |
| `authors` | string[] | No | Filter by multiple authors |

**Security standards:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cwe` | string[] | No | CWE identifiers |
| `owasp_top10` | string[] | No | OWASP Top 10 categories |
| `owasp_top10_v2021` | string[] | No | OWASP Top 10 2021 categories |
| `sans_top25` | string[] | No | SANS Top 25 categories |
| `sonarsource_security` | string[] | No | SonarSource security categories |

**Facets & sorting:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `facets` | string[] | No | Enable faceted search: `severities`, `statuses`, `resolutions`, `rules`, `tags`, `types`, `authors`, `assignees`, `languages` |
| `facet_mode` | string | No | `count` or `effort` |
| `languages` | string[] | No | Filter by programming languages |
| `s` | string | No | Sort field |
| `asc` | boolean | No | Sort ascending |
| `additional_fields` | string[] | No | Additional fields in response |
| `since_leak_period` | boolean | No | Filter to leak period |
| `in_new_code_period` | boolean | No | Filter to new code period |
| `page` | string | No | Page number |
| `page_size` | string | No | Items per page |

#### `markIssueFalsePositive`
Mark a single issue as false positive.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issue_key` | string | **Yes** | The issue key |
| `comment` | string | No | Explanation comment |

#### `markIssueWontFix`
Mark a single issue as won't fix.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issue_key` | string | **Yes** | The issue key |
| `comment` | string | No | Explanation comment |

#### `markIssuesFalsePositive`
Bulk mark multiple issues as false positive.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issue_keys` | string[] | **Yes** | Array of issue keys (min 1) |
| `comment` | string | No | Comment for all issues |

#### `markIssuesWontFix`
Bulk mark multiple issues as won't fix.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issue_keys` | string[] | **Yes** | Array of issue keys (min 1) |
| `comment` | string | No | Comment for all issues |

#### `addCommentToIssue`
Add a comment to an issue. Supports markdown.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issue_key` | string | **Yes** | The issue key |
| `text` | string | **Yes** | Comment text (markdown supported) |

#### `assignIssue`
Assign an issue to a user or unassign it.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issueKey` | string | **Yes** | The issue key |
| `assignee` | string | No | Username. Empty to unassign |

#### `confirmIssue`
Confirm a SonarQube issue.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issue_key` | string | **Yes** | The issue key |
| `comment` | string | No | Explanation comment |

#### `unconfirmIssue`
Unconfirm an issue (needs further investigation).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issue_key` | string | **Yes** | The issue key |
| `comment` | string | No | Explanation comment |

#### `resolveIssue`
Resolve a SonarQube issue.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issue_key` | string | **Yes** | The issue key |
| `comment` | string | No | Resolution comment |

#### `reopenIssue`
Reopen a SonarQube issue.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `issue_key` | string | **Yes** | The issue key |
| `comment` | string | No | Explanation comment |

### Quality Gates

#### `quality_gates`
List all available quality gates. No parameters required.

#### `quality_gate`
Get conditions for a specific quality gate.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | **Yes** | Quality gate ID |

#### `quality_gate_status`
Get project quality gate status.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project_key` | string | **Yes** | Project key |
| `branch` | string | No | Branch name |
| `pull_request` | string | No | Pull request key |

### Source Code

#### `source_code`
View source code with issues highlighted.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `key` | string | **Yes** | File key |
| `from` | string | No | Start line number |
| `to` | string | No | End line number |
| `branch` | string | No | Branch name |
| `pull_request` | string | No | Pull request key |

#### `scm_blame`
Get SCM blame information for source code.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `key` | string | **Yes** | File key |
| `from` | string | No | Start line number |
| `to` | string | No | End line number |
| `branch` | string | No | Branch name |
| `pull_request` | string | No | Pull request key |

### Security Hotspots

#### `hotspots`
Search for security hotspots with filtering.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project_key` | string | No | Project key |
| `branch` | string | No | Branch name |
| `pull_request` | string | No | Pull request ID |
| `status` | string | No | `TO_REVIEW` or `REVIEWED` |
| `resolution` | string | No | `FIXED` or `SAFE` |
| `files` | string[] | No | File paths to filter |
| `assigned_to_me` | boolean | No | Show only assigned hotspots |
| `since_leak_period` | boolean | No | Leak period filter |
| `in_new_code_period` | boolean | No | New code period filter |
| `page` | string | No | Page number |
| `page_size` | string | No | Items per page |

#### `hotspot`
Get detailed info about a specific security hotspot (includes security category, vulnerability probability, rule info, changelog, comments, code flows).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `hotspot_key` | string | **Yes** | Hotspot key |

#### `update_hotspot_status`
Update the status of a security hotspot (requires permissions).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `hotspot_key` | string | **Yes** | Hotspot key |
| `status` | string | **Yes** | `TO_REVIEW` or `REVIEWED` |
| `resolution` | string | No | `FIXED` or `SAFE` (when status is `REVIEWED`) |
| `comment` | string | No | Explanation comment |

### System Monitoring

#### `system_health`
Get the health status of the SonarQube instance. No parameters.

#### `system_status`
Get the status of the SonarQube instance. No parameters.

#### `system_ping`
Ping the SonarQube instance to check availability. No parameters.

## Workflows

### 1. Project Health Check
```
1. Use `projects` to list available projects
2. Use `quality_gate_status` with the project key to check gate status
3. Use `measures_component` with metric_keys ["bugs", "vulnerabilities", "code_smells", "coverage", "duplicated_lines_density"]
4. Use `issues` with severities ["CRITICAL", "BLOCKER"] to find top-priority issues
```

### 2. Security Audit
```
1. Use `issues` with types ["VULNERABILITY"] and severities ["CRITICAL", "BLOCKER"]
2. Use `hotspots` with status "TO_REVIEW" for the project
3. Use `hotspot` to get details on each hotspot
4. Use `source_code` to view the affected code
5. Use `update_hotspot_status` to mark reviewed hotspots
```

### 3. PR Quality Review
```
1. Use `quality_gate_status` with the pull_request parameter
2. Use `issues` with pull_request parameter to find new issues
3. Use `measures_component` with pull_request to check coverage delta
```

### 4. Issue Triage Sprint
```
1. Use `issues` with facets ["severities", "types", "assignees"] for a dashboard view
2. Use `issues` with assignees filter for per-developer workload
3. Use `assignIssue` to distribute work
4. Use `markIssueFalsePositive` or `markIssueWontFix` for non-actionable issues
5. Use `addCommentToIssue` to annotate decisions
```

### 5. Metrics Trend Analysis
```
1. Use `metrics` to discover available metric keys
2. Use `measures_history` with from/to dates to get trends
3. Compare across branches using the branch parameter
```
