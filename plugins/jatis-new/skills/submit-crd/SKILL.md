---
name: submit-crd
description: Submit a CRD (Change Request Document) to BOFIS by filling out the form at https://bofis.jatismobile.com/crd/create using Chrome DevTools MCP. The user must provide a completed CRD document with all required fields AND specify the target PB/PMD number. Requires chrome-devtools MCP server to be configured.
disable-model-invocation: true
---

# Submit CRD to BOFIS

You are automating the submission of a CRD (Change Request Document) on the BOFIS platform using Chrome DevTools MCP.

## Prerequisites

- Chrome browser must be open and accessible via DevTools protocol
- The chrome-devtools MCP server must be running
- Environment variables `BOFIS_USERNAME` and `BOFIS_PASSWORD` must be set
- **MANDATORY: The user must provide the target PB/PMD number.** If not provided, use question/AskUserQuestion tool to ask the user for the PB/PMD number before proceeding.

## CRD Input

The user will provide a CRD document with fields to fill. If no CRD content was provided as arguments, use question/AskUserQuestion tool to ask the user to provide the CRD document content.

Arguments provided: $ARGUMENTS

## Important CKEditor Note

**For CKEditor fields in (Pre-Implementation Procedure, Implementation Procedure, Post-Implementation Procedure, Success Criteria, and Rollback Procedure)**: For numbered lists, only type the number ‘1’ as the list indicator. There’s no need to type the rest, since CKEditor will automatically continue the numbering when you press Enter. The same applies to bulleted lists—just add ‘-’ for the first item, and the rest will be created automatically when you press Enter. For example, if the CRD document contains text like:
```
1. Step 1
2. Step 2
3. Step 3    
...
```
In CKEditor, you only need to type the first item (‘1. Step 1’). There’s no need to type ‘2.’ and beyond, since they will be generated automatically. The same applies to bulleted lists—just type ‘-’ for the first item, and the rest will follow automatically. If you want to reset the list, press Enter twice.

Make sure that for numbered and bulleted lists, the rules are strictly followed—only the first item should include the list indicator, and no additional numbering or bullets should be added to the subsequent items.

## Workflow

Follow these steps carefully and in order:

### Step 1: Retrieve Login Credentials

Read the login credentials from environment variables:
- Username: `BOFIS_USERNAME`
- Password: `BOFIS_PASSWORD`

Use Bash to read them: `echo $BOFIS_USERNAME` and `echo $BOFIS_PASSWORD`

If either is not set, inform the user and stop.

### Step 2: Navigate to PB/PMD and Start Dev

1. Use `navigate_page` to go to `https://bofis.jatismobile.com/pbpmd`
2. Wait for the page to load
3. Take a screenshot to see the current state
4. If the page shows a login form, handle authentication first (see Step 3)
5. Take a snapshot (accessibility tree) to find the list/table of PB/PMD entries
6. Locate the row that matches the user's target PB/PMD number
7. In that same row, find and click the icon with class `fa-eye` (the view/detail icon)
8. Wait for the page/modal to load
9. Take a screenshot to verify the detail view is shown
10. Find and click the **"Start Dev"** button
11. Wait for the action to complete
12. Take a screenshot to confirm "Start Dev" was successful
13. If "Start Dev" fails or the button is not found, take a screenshot, report the error to the user, and stop

**IMPORTANT: Do NOT proceed to create the CRD until "Start Dev" has been successfully clicked.**

### Step 3: Navigate to the CRD Page

1. Use `navigate_page` to go to `https://bofis.jatismobile.com/crd/create`
2. Wait for the page to load
3. Take a screenshot to see the current state

### Step 4: Handle Authentication (if needed)

1. Take a snapshot to inspect the page structure
2. If the page shows a login form (look for username/password fields or login button):
   - Use `fill` to enter the username from `BOFIS_USERNAME`
   - Use `fill` to enter the password from `BOFIS_PASSWORD`
   - Click the login/submit button
   - Wait for navigation to complete
   - Take a screenshot to verify login was successful
3. After login, if not already on the CRD create page, navigate to `https://bofis.jatismobile.com/crd/create`

### Step 5: Inspect the CRD Form

1. Take a snapshot (accessibility tree) to identify all form fields, their labels, types, and UIDs
2. Take a screenshot for visual confirmation
3. Map each field from the user's CRD document to the corresponding form field on the page
4. If any required form field cannot be mapped to the CRD document, use question/AskUserQuestion tool to ask the user for the missing values

### Step 6: Fill the Form

1. For each field in the CRD document, use the appropriate tool:
   - For text inputs and textareas: use `fill` with the field's UID and value
   - For dropdowns/selects: use `fill` with the selected value
   - For checkboxes/radio buttons: use `click`
   - For date fields: use `fill` with the formatted date
   - **For CKEditor fields in (Pre-Implementation Procedure, Implementation Procedure, Post-Implementation Procedure, Success Criteria, and Rollback Procedure)**: For numbered lists, only type the number ‘1’ as the list indicator. There’s no need to type the rest, since CKEditor will automatically continue the numbering when you press Enter. The same applies to bulleted lists—just add ‘-’ for the first item, and the rest will be created automatically when you press Enter. For example, if the CRD document contains text like:
    ```
    1. Step 1
    2. Step 2
    3. Step 3    
    ...
    ```
    In CKEditor, you only need to type the first item (‘1. Step 1’). There’s no need to type ‘2.’ and beyond, since they will be generated automatically. The same applies to bulleted lists—just type ‘-’ for the first item, and the rest will follow automatically. If you want to reset the list, press Enter twice.
2. After filling each section, take a screenshot to verify the values were entered correctly
3. If a field fails to fill, try alternative approaches:
   - Use `click` to focus the field first, then `type_text`
   - Use `evaluate_script` to set the value programmatically

### Step 7: Review and Confirm

1. Take a final screenshot of the completed form
2. Take a snapshot to capture all filled values
3. Present a summary to the user of ALL filled fields using question/AskUserQuestion tool:
   - List every field name and the value that was entered
   - Ask: "The CRD form has been filled with the values above. Do you want to proceed and click Save?"
   - Options: "Yes, Save" / "No, Cancel" / "Let me review changes"
4. **CRITICAL: Do NOT click Save without explicit user confirmation**

### Step 8: Submit or Cancel

- If the user confirms "Yes, Save":
  1. Find and click the Save button
  2. Wait for the page to respond
  3. Take a screenshot to confirm submission
  4. Report the result to the user (success or any error messages)
- If the user says "No, Cancel":
  1. Inform the user that the form was not submitted
  2. Optionally navigate away from the page
- If the user says "Let me review changes":
  1. Use question/AskUserQuestion tool to ask which fields need to be modified
  2. Update the specified fields
  3. Go back to Step 7

## Error Handling

- If any navigation fails, take a screenshot and report the error
- If a form field cannot be found, take a snapshot and try to locate it by different selectors
- If the page times out, retry once before reporting failure
- Always take a screenshot when something unexpected happens so the user can see the state

## Important Notes

- Never store or log the password in plain text in responses
- Always verify each step visually with screenshots before proceeding
- The form structure may change; adapt by reading the snapshot/accessibility tree rather than hardcoding selectors
