---
name: myspec-debug
description: Save debugging documentation and troubleshooting guides to organized markdown files under myspec/debug/. Triggers on myspec-debug, debug spec, troubleshooting, bug investigation.
license: MIT
---

## Trigger Keywords
This skill should be called when user mention `myspec-debug`

## What I do
- Save debugging documentation and troubleshooting guides
- Organize files based on size (single file ≤600 lines, split if >600 lines)
- Use consistent naming: myspec/debug/{feature_name/issue_name}.md
- Never modify non-markdown files

## File organization rules
- Documents ≤600 lines: `myspec/debug/{feature_name}.md`
- Documents >600 lines: Split into `myspec/debug/{feature_name}/{datemonthhourminutesecond}.md`
- Only create or modify Markdown files

## When to use me
Use this skill when you need to save debugging documentation, troubleshooting guides, or technical investigations in an organized way.