# SonarQube Issue Identification

Get bugs, vulnerabilities, and security hotspots from sonarqube mcp.

Develop systematic approach for fixing identified issues:

```
## Total {TYPE} Issue: {TOTAL_ISSUE_COUNT}

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
Save in different new files based on type:
- Bug: bug-{datemonthhourminutesecond}.md
- Vulnerability: vulnerability-{datemonthhourminutesecond}.md
- Security Hotspot: security-hotspot-{datemonthhourminutesecond}.md