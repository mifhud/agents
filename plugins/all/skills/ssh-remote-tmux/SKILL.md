---
name: ssh-remote-tmux
description: "Run commands on a remote server via SSH inside a persistent tmux session. Use when the user wants to execute shell commands, manage services, inspect logs, edit files, or perform any interactive task on a remote machine. The user's natural-language prompt is translated into shell commands, then confirmed with the user via question before execution. Commands are executed inside a tmux pane over SSH. The tmux session persists between interactions and is only destroyed when the user explicitly asks. Output: captured tmux pane content showing full command output."
---

# SSH Remote Tmux Skill

Execute commands on a remote server by translating the user's request into shell commands, running them inside a persistent tmux session over SSH, and returning the full terminal output.

## Core Workflow

1. **Parse** the user's natural-language request and determine the shell command(s) needed.
2. **ASK the user for confirmation** using the `question` tool — present the exact command(s) and let the user approve, edit, or cancel. **NEVER execute any command on the remote server without explicit user approval.**
3. **Send** only the approved command(s) into the remote tmux session via SSH.
4. **Capture** the full terminal output and present it to the user.
5. **Keep** the tmux session alive — only destroy it when the user explicitly requests cleanup.

> **MANDATORY CONFIRMATION RULE:** Before every command execution, you MUST use the `question` tool to present the command and ask the user to confirm. Do NOT use bash to run the SSH command until the user has approved. This applies to every single command — no exceptions.

---

## Configuration

Before first use, establish these variables. Prompt the user for any values not already known.

```bash
# Remote host connection
SSH_USER="user"              # Remote username
SSH_HOST="hostname_or_ip"    # Remote host address
SSH_PORT="22"                # SSH port (default 22)
SSH_KEY=""                   # Path to SSH private key (optional, leave empty for password auth)

# Tmux settings
SESSION="remote-session"     # Tmux session name on the remote host
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

## Session Management

### 1. Create a Persistent Tmux Session on the Remote Host

Only create if one doesn't already exist:

```bash
# Check if session exists
$SSH_CMD "tmux has-session -t '$SESSION' 2>/dev/null" && echo "Session '$SESSION' already exists." || {
  $SSH_CMD "tmux new-session -d -s '$SESSION' -x 220 -y 50"
  echo "✅ Created remote tmux session: $SESSION"
}
```

> **Note:** The `-x 220 -y 50` sets a wide, tall pane so captured output includes long lines and large outputs without wrapping or truncation.

### 2. Verify the Session

```bash
$SSH_CMD "tmux list-sessions"
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
question({
  questions: [{
    question: "I'll run this command on the remote server:\n\n`df -h`\n\nProceed?",
    options: ["Yes, execute", "Edit command", "Cancel"],
    type: "single_select"
  }]
})
```

- If the user selects **"Yes, execute"** → proceed to send the command via SSH.
- If the user selects **"Edit command"** → ask the user to provide the corrected command (in prose), then confirm again with `question`.
- If the user selects **"Cancel"** → do not execute anything.

For **multiple commands**, list all of them in the question so the user can review the full sequence:

```
question({
  questions: [{
    question: "I'll run these commands in sequence on the remote server:\n\n1. `cd /var/log`\n2. `ls -lah`\n3. `tail -50 syslog`\n\nProceed?",
    options: ["Yes, execute all", "Edit commands", "Cancel"],
    type: "single_select"
  }]
})
```

For **dangerous or destructive commands** (rm, reboot, drop, kill, systemctl stop, etc.), add an extra warning:

```
question({
  questions: [{
    question: "⚠️ This is a destructive command:\n\n`rm -rf /tmp/old-builds/`\n\nThis will permanently delete files. Are you sure?",
    options: ["Yes, I understand the risk", "Edit command", "Cancel"],
    type: "single_select"
  }]
})
```

### Sending a Command

Always send the command text and the Enter key as **two separate calls** with a short delay:

```bash
COMMAND='the confirmed command here'

$SSH_CMD "tmux send-keys -t '$SESSION' -l -- $(printf '%q' "$COMMAND")"
sleep 0.3
$SSH_CMD "tmux send-keys -t '$SESSION' Enter"
```

### Sending Multiple Sequential Commands

For multi-step tasks, send each command one at a time and wait for completion between them:

```bash
COMMANDS=(
  "cd /var/log"
  "ls -lah"
  "tail -50 syslog"
)

for CMD in "${COMMANDS[@]}"; do
  $SSH_CMD "tmux send-keys -t '$SESSION' -l -- $(printf '%q' "$CMD")"
  sleep 0.3
  $SSH_CMD "tmux send-keys -t '$SESSION' Enter"
  sleep 2  # Wait for command to finish; increase for slower commands
done
```

---

## Capturing Output

### Full Pane Capture

Capture the entire scrollback buffer for maximum visibility. Use a large `-S` value to get as much history as possible:

```bash
$SSH_CMD "tmux capture-pane -t '$SESSION' -p -J -S -10000"
```

| Flag | Purpose |
|---|---|
| `-p` | Print to stdout (instead of to a tmux buffer) |
| `-J` | Join wrapped lines into single logical lines |
| `-S -10000` | Start capture 10,000 lines back from the current cursor position |

### Capture After a Command (with wait)

For commands that produce output over time, poll until the shell prompt reappears or a timeout is reached:

```bash
# Send the command
$SSH_CMD "tmux send-keys -t '$SESSION' -l -- 'df -h'"
sleep 0.3
$SSH_CMD "tmux send-keys -t '$SESSION' Enter"

# Poll for completion (look for the shell prompt, e.g. $ or #)
for i in {1..30}; do
  sleep 2
  OUTPUT=$($SSH_CMD "tmux capture-pane -t '$SESSION' -p -J -S -10000")

  # Check if the prompt has returned (adjust pattern to match the remote shell)
  if echo "$OUTPUT" | tail -3 | grep -qE '[\$#] *$'; then
    echo "✅ Command finished."
    echo "$OUTPUT"
    break
  fi

  echo "⏳ Waiting... (attempt $i)"
done
```

### Capture Only Recent Output

If you need just the last N lines (e.g., to avoid noise from earlier commands):

```bash
$SSH_CMD "tmux capture-pane -t '$SESSION' -p -J -S -200"
```

---

## Interactive / Long-Running Commands

For commands that produce continuous output (e.g., `top`, `tail -f`, `htop`):

### Start the interactive command

```bash
$SSH_CMD "tmux send-keys -t '$SESSION' -l -- 'tail -f /var/log/syslog'"
sleep 0.3
$SSH_CMD "tmux send-keys -t '$SESSION' Enter"
```

### Capture a snapshot of the live output

```bash
sleep 5
$SSH_CMD "tmux capture-pane -t '$SESSION' -p -J -S -500"
```

### Stop the interactive command

```bash
# Send Ctrl-C to interrupt
$SSH_CMD "tmux send-keys -t '$SESSION' C-c"
sleep 1
$SSH_CMD "tmux capture-pane -t '$SESSION' -p -J -S -200"
```

---

## Full Workflow Example

```bash
# --- Configuration ---
SSH_USER="deploy"
SSH_HOST="192.168.1.100"
SSH_PORT="22"
SSH_KEY="$HOME/.ssh/id_rsa"
SESSION="remote-session"
SSH_CMD="ssh -o StrictHostKeyChecking=no -p $SSH_PORT -i $SSH_KEY ${SSH_USER}@${SSH_HOST}"

# --- 1. Ensure tmux session exists ---
$SSH_CMD "tmux has-session -t '$SESSION' 2>/dev/null" || \
  $SSH_CMD "tmux new-session -d -s '$SESSION' -x 220 -y 50"

# --- 2. Determine the command from user's request ---
COMMAND="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

# --- 3. ASK USER FOR CONFIRMATION (via question) ---
# Use question tool:
#   question: "I'll run this on the remote server:\n\n`docker ps --format '...'`\n\nProceed?"
#   options: ["Yes, execute", "Edit command", "Cancel"]
# STOP HERE — do NOT proceed to step 4 until user selects "Yes, execute"

# --- 4. ONLY after user approval, send the command ---
COMMAND="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

$SSH_CMD "tmux send-keys -t '$SESSION' -l -- $(printf '%q' "$COMMAND")"
sleep 0.3
$SSH_CMD "tmux send-keys -t '$SESSION' Enter"

# --- 3. Wait and capture full output ---
for i in {1..20}; do
  sleep 2
  OUTPUT=$($SSH_CMD "tmux capture-pane -t '$SESSION' -p -J -S -10000")
  if echo "$OUTPUT" | tail -3 | grep -qE '[\$#] *$'; then
    echo "$OUTPUT"
    break
  fi
  echo "⏳ Waiting... ($i)"
done
```

---

## Session Cleanup

> **IMPORTANT:** Do NOT automatically destroy the tmux session. Only clean up when the user explicitly asks (e.g., "kill the session", "clean up", "destroy the tmux session").

When the user requests cleanup:

```bash
$SSH_CMD "tmux kill-session -t '$SESSION' 2>/dev/null" && \
  echo "✅ Remote tmux session '$SESSION' destroyed." || \
  echo "ℹ️  No session named '$SESSION' found."
```

To list active sessions (useful before cleanup):

```bash
$SSH_CMD "tmux list-sessions 2>/dev/null" || echo "No active tmux sessions."
```

---

## Important Tips

- **Always confirm commands with the user using `question`** before executing. Present the exact command(s) as options and wait for the user to select "Yes, execute". Never skip this step.
- **Never combine** command text and Enter in a single `send-keys` call — always separate them with a short sleep.
- **Use `-l` flag** on `send-keys` for literal strings to prevent tmux from interpreting special characters.
- **Use `printf '%q'`** to safely quote commands passed through SSH to avoid shell expansion issues.
- **Use `-S -10000`** (or higher) for `capture-pane` to get the full scrollback buffer so long file contents and outputs are fully visible.
- **Set wide pane dimensions** (`-x 220 -y 50`) when creating sessions to avoid line wrapping in captured output.
- **Poll for prompt return** rather than using fixed sleeps — this handles both fast and slow commands gracefully.
- **Persistent sessions** survive disconnects. If SSH drops, simply reconnect and the tmux session with all its history is still available.
- **Never destroy the session automatically.** Only clean up on explicit user request.

---

## Troubleshooting

| Issue | Solution |
|---|---|
| SSH connection refused | Verify `SSH_HOST`, `SSH_PORT`, and that sshd is running on the remote |
| Permission denied | Check `SSH_USER`, `SSH_KEY` permissions (`chmod 600`), or use password auth |
| Tmux not found on remote | Install with `sudo apt install tmux` or equivalent |
| Garbled output / line wrapping | Increase pane width with `tmux resize-window -t '$SESSION' -x 250` |
| Command seems stuck | Capture pane to check status; send `C-c` to interrupt if needed |
| Session disappeared | Remote was rebooted — recreate the session |

$ARGUMENTS