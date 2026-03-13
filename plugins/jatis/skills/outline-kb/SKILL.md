---
name: outline-kb
description: Fetch and search documents from Outline Knowledge Base. Use for retrieving documentation, searching articles, listing collections, or exploring nested document structures from the Outline wiki.
argument-hint: "[command] [args]"
allowed-tools: Bash, Read
---

# Outline Knowledge Base Fetcher

Interact with Outline Knowledge Base (outline-rbi.jatismobile.com) to fetch documents, search content, and explore collections.

## Commands

### Search documents
`/outline-kb search &lt;keyword&gt; [limit]`
Search for documents by keyword across all collections.

### Read document
`/outline-kb doc &lt;urlId|URL&gt;`
Read full content of a specific document by its urlId or full URL. Automatically lists child documents if present.

### List child documents
`/outline-kb children &lt;urlId|URL&gt; [limit]`
List nested/child documents under a parent document.

### List collections
`/outline-kb collections`
Show all available collections with their urlIds.

### List collection documents
`/outline-kb collection-docs &lt;collectionId|urlId&gt; [limit]`
List all documents within a specific collection.

## URL Formats Supported
- Full URL: `https://outline-rbi.jatismobile.com/doc/post-login-GDTFBgZmll`
- Short urlId: `GDTFBgZmll`
- UUID: `9bb1fd97-76c7-45dc-...`

## Environment Setup
Credentials loaded from `~/.config/jatismobile/.env`:
- `OUTLINE_API_URL`
- `OUTLINE_API_TOKEN`

## Usage Examples

Search for login-related docs:

/outline-kb search "post login"

Read a specific document:
```
/outline-kb doc GDTFBgZmll
```

List all collections:
```
/outline-kb collections
```

Get child documents:
```
/outline-kb children GDTFBgZmll
```

## Implementation

Run the appropriate command using the bundled script:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/outline-fetch.sh --$0 $ARGUMENTS
```

Where `$0` is the subcommand (search, doc, children, collections, collection-docs).