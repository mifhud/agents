---
name: myspec-plan
description: Save planning and feature specifications to organized markdown files under myspec/plan/. Triggers on myspec-plan, plan spec, planning document, feature spec, PRD.
license: MIT
---

## Trigger Keywords
This skill should be called when user mention `myspec-plan`

## What I do
- Save planning documents and feature specifications
- Organize files based on size (single file ≤600 lines, split if >600 lines)
- Use consistent naming: myspec/plan/{feature_name/issue_name}.md
- Never modify non-markdown files

## File organization rules
- Documents ≤600 lines: `myspec/plan/{feature_name}.md`
- Documents >600 lines: Split into `myspec/plan/{feature_name}/{datemonthhourminutesecond}.md`
- Only create or modify Markdown files

## When to use me
Use this skill when you need to save planning documents, feature specifications, or PRDs in an organized way.