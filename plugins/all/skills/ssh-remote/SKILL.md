---
name: ssh-remote
description: "Run commands on a remote server via SSH. Use when the user wants to execute shell commands, manage services, inspect logs, edit files, or perform any interactive task on a remote machine. The user's natural-language prompt is translated into shell commands, then confirmed with the user via question before execution. Commands are sent directly over SSH and output is captured from stdout/stderr."
---

# SSH Remote Skill

Execute commands on a remote server by translating the user's request into shell commands, running them directly over SSH, and returning the full output.

# Important
**Must confirm all commands with the user before execution.**

## Core Workflow

1. **Parse** the user's natural-language request and determine the shell command(s) needed.
2. **ASK the user for confirmation** using the `question` tool — present the exact command(s) and let the user approve, edit, or cancel. **NEVER execute any command on the remote server without explicit user approval.**
3. **Send** only the approved command(s) directly over SSH.
4. **Capture** the full output from stdout/stderr and present it to the user.

> **MANDATORY CONFIRMATION RULE:** Before every command execution, you MUST use the `question` tool to present the command and ask the user to confirm. Do NOT run anything until the user has approved. This applies to every single command — no exceptions.

---

## Configuration

Before first use, establish these variables. Prompt the user for any values not already known.

```bash
# Remote host connection
SSH_USER="user"              # Remote username
SSH_HOST="hostname_or_ip"    # Remote host address
SSH_PORT="22"                # SSH port (default 22)
SSH_KEY=""                   # Path to SSH private key (optional, leave empty for password auth)
```

Build the SSH base command once:

```bash
if [ -n "$SSH_KEY" ]; then
  SSH_CMD="ssh -o StrictHostKeyChecking=no -p $SSH_PORT -i $SSH_KEY ${SSH_USER}@${SSH_HOST}"
else
  SSH_CMD="ssh -o StrictHostKeyChecking=no -p $SSH_PORT ${SSH_USER}@${SSH_HOST}"
fi
```

---

## Executing Commands

### Translating User Requests

Convert the user's natural-language prompt into concrete shell commands. Examples:

| User says | Command(s) |
|---|---|
| "Show me the disk usage" | `df -h` |
| "List running containers" | `docker ps` |
| "Tail the nginx logs" | `tail -100 /var/log/nginx/access.log` |
| "Check what's listening on port 8080" | `ss -tlnp \| grep 8080` |
| "Show the contents of /etc/hosts" | `cat /etc/hosts` |
| "Restart the web service" | `sudo systemctl restart nginx` |

**Always confirm with the user using the `question` tool before sending.** Example:

```
question: "I'll run this command on the remote server:\n\n`df -h`\n\nProceed?",
options: ["Yes, execute", "Edit command", "Cancel"],
type: "single_select"
```

- If the user selects **"Yes, execute"** → proceed to send the command via SSH.
- If the user selects **"Edit command"** → ask the user to provide the corrected command (in prose), then confirm again with `question`.
- If the user selects **"Cancel"** → do not execute anything.

For **multiple commands**, list all of them in the question so the user can review the full sequence:

```
question: "I'll run these commands in sequence on the remote server:\n\n1. `cd /var/log`\n2. `ls -lah`\n3. `tail -50 syslog`\n\nProceed?",
options: ["Yes, execute all", "Edit commands", "Cancel"],
type: "single_select"
```

For **dangerous or destructive commands** (rm, reboot, drop, kill, systemctl stop, etc.), add an extra warning:

```
question: "⚠️ This is a destructive command:\n\n`rm -rf /tmp/old-builds/`\n\nThis will permanently delete files. Are you sure?",
options: ["Yes, I understand the risk", "Edit command", "Cancel"],
type: "single_select"
```

### Sending a Command

Run the confirmed command directly over SSH and capture its output:

```bash
COMMAND='the confirmed command here'

$SSH_CMD "$COMMAND"
```

### Sending Multiple Sequential Commands

For multi-step tasks, chain commands or run them in sequence:

```bash
COMMANDS=(
  "cd /var/log"
  "ls -lah"
  "tail -50 syslog"
)

for CMD in "${COMMANDS[@]}"; do
  $SSH_CMD "$CMD"
done
```

Or combine into a single SSH call:

```bash
$SSH_CMD "cd /var/log && ls -lah && tail -50 syslog"
```

---

## Interactive / Long-Running Commands

For commands that produce continuous output (e.g., `tail -f`, `journalctl -f`), use the `-t` flag to allocate a pseudo-TTY and run with a timeout or line limit:

```bash
# Stream output for a limited time using timeout
$SSH_CMD "timeout 10 tail -f /var/log/syslog"
```

To stop a running interactive command, interrupt the SSH process locally (Ctrl-C).

---

## Full Workflow Example

```bash
# --- Configuration ---
SSH_USER="deploy"
SSH_HOST="192.168.1.100"
SSH_PORT="22"
SSH_KEY="$HOME/.ssh/id_rsa"
SSH_CMD="ssh -o StrictHostKeyChecking=no -p $SSH_PORT -i $SSH_KEY ${SSH_USER}@${SSH_HOST}"

# --- 1. Determine the command from user's request ---
COMMAND="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

# --- 2. ASK USER FOR CONFIRMATION (via question) ---
# Use question tool:
#   question: "I'll run this on the remote server:\n\n`docker ps --format '...'`\n\nProceed?"
#   options: ["Yes, execute", "Edit command", "Cancel"]
# STOP HERE — do NOT proceed to step 3 until user selects "Yes, execute"

# --- 3. ONLY after user approval, run the command via SSH ---
$SSH_CMD "$COMMAND"
```

---

## Important Tips

- **Always confirm commands with the user using `question`** before executing. Present the exact command(s) as options and wait for the user to select "Yes, execute". Never skip this step.
- **Use direct SSH execution** — run commands via `$SSH_CMD "command"` and capture stdout/stderr directly.
- **Quote commands carefully** — use single quotes for the remote command string to avoid local shell expansion.
- **For multi-step tasks**, chain commands with `&&` in a single SSH call or run them sequentially.
- **Poll for long-running commands** using `timeout` to avoid hanging indefinitely.

---

## Troubleshooting

| Issue | Solution |
|---|---|
| SSH connection refused | Verify `SSH_HOST`, `SSH_PORT`, and that sshd is running on the remote |
| Permission denied | Check `SSH_USER`, `SSH_KEY` permissions (`chmod 600`), or use password auth |
| Command output truncated | Increase terminal width with `COLUMNS=220` or use `--width` flags on specific tools |
| Command seems stuck | Add `timeout N` prefix to limit execution time |

$ARGUMENTS
