---
name: myspec-design
description: Save design documentation and architecture specifications to organized markdown files under myspec/design/. Triggers on myspec-design, design spec, architecture doc, technical design.
license: MIT
---

## Trigger Keywords
This skill should be called when user mention `myspec-design`

## What I do
- Save design documentation and architecture specifications
- Organize files based on size (single file ≤600 lines, split if >600 lines)
- Use consistent naming: myspec/design/{feature_name/issue_name}.md
- Never modify non-markdown files

## File organization rules
- Documents ≤600 lines: `myspec/design/{feature_name}.md`
- Documents >600 lines: Split into `myspec/design/{feature_name}/{datemonthhourminutesecond}.md`
- Only create or modify Markdown files

## When to use me
Use this skill when you need to save design documentation, architecture specifications, or technical designs in an organized way.