---
name: create-note
description: Creates a structured QnA note file based on a topic or question provided by the user. Use when the user wants to create, save, or write a note about a topic, concept, or question.
argument-hint: <topic or question for the note>
---

# Create Note

Use this skill to generate and save a structured QnA note from a topic or question.

## Template

Refer to the [note template](./template.md) for the exact file structure to follow.

## Steps

### 1. Parse Topic

Take the user's argument (the text after `/create-note`) as the note topic or question.
If no argument was given, ask the user: "What topic or question should this note cover?"

### 2. Determine Root Directory

Read the `ROOT_RESOURCES_JATIS` environment variable:

```bash
echo "$ROOT_RESOURCES_JATIS"
```

If it is empty or not set, stop and tell the user:
> ❌ `ROOT_RESOURCES_JATIS` is not set. Please set it to the root directory where notes should be stored (e.g. `export ROOT_RESOURCES_JATIS=~/Notes`).

### 3. List Available Subfolders

List the immediate subdirectories of the root directory and show them to the user:

```bash
ls -d "$ROOT_RESOURCES_JATIS"/*/
```

Display the result clearly, for example:
```
Available subfolders:
  1. 10 Daily
  2. 20 Projects
  3. 30 Resources
  4. 40 Archive
```

### 4. Ask for Subfolder

Ask the user:
> "Which subfolder should this note be saved in? (Pick a number from the list above, or type a subfolder name manually)"

Wait for the user's response before continuing. Accept either a number (mapped to the listed subdirectory) or a free-text name. Do not default or assume.

### 5. Generate Note Content

Using the topic from Step 1, generate the note content as follows:

- **Title**: Derive a clear, concise title from the topic (Title Case).
- **Question / Answer pairs**: Create at minimum 2–3 pairs that break down the topic into meaningful questions and thorough answers. More pairs are encouraged for complex topics.
- **created / updated**: Use the current date and time in the format `YYYY-MM-DDTHH:mm` (e.g. `2026-04-27T09:33`).

Fill in the template from [template.md](./template.md):
- Replace `{{title}}` with the note title.
- Replace `{{created}}` and `{{updated}}` with the current timestamp.
- Replace each `{{question_N}}` and `{{answer_N}}` placeholder with the generated Q&A content. Add extra Question/Answer blocks as needed.
- Leave all Back Matter fields empty (just the labels/comments) exactly as shown in the template.

### 6. Determine File Name

Use the note title as the file name, preserving spaces and casing, with a `.md` extension.
Example: if the title is `Understanding Async Await`, the file name is `Understanding Async Await.md`.

### 7. Write the File

Construct the full path:
```
$ROOT_RESOURCES_JATIS/<subfolder>/<file name>.md
```

Write the generated content to that path using:

```bash
cat > "<full_path>" << 'EOF'
<generated note content>
EOF
```

If the subfolder does not exist yet, create it first:
```bash
mkdir -p "$ROOT_RESOURCES_JATIS/<subfolder>"
```

### 8. Confirm to User

After saving, confirm with the absolute path of the created file:
> ✅ Note saved to: `<full path>`
