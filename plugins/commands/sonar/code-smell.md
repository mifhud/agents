# SonarQube Code Smells Identification

Get code smell from sonarqube mcp.

Develop systematic approach for fixing identified issues:

```
## Total {SEVERITY} Issue: {TOTAL_ISSUE_COUNT}

Issue: {Sonar Issue Name}
Error Location Code:
## {relative-file-path}:{start-line:end-line}
```
1: Code Line 1
2: Code Line 2
...
```
Fix Approach: Fix Approach
```

Save in folder: myspec/plan/sonar
Save in different severity new file: smell-{severities}-{datemonthhourminutesecond}.md, ...