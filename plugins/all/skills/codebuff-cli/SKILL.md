---
name: codebuff-cli
description: "Run Codebuff coding agent interactively via tmux. Use when delegating coding tasks to Codebuff, switching modes mid-session, or running interactive coding workflows. Output: tmux pane content with Codebuff's responses and code changes."
---

# Codebuff CLI Skill

Codebuff is an AI coding agent run via terminal TUI. Use tmux for interactive sessions. Must process using tmux and codebuff cli.

## Binary Path

```bash
/root/.nvm/versions/node/v22.22.0/bin/codebuff
```

## Modes

Switch modes anytime mid-session by typing the slash command in the Codebuff input:

| Command       | Mode    | Use Case                        |
|---------------|---------|---------------------------------|
| `/mode:default` | Default | Balanced, general coding tasks  |
| `/mode:free`    | Free    | Free tier, limited usage        |
| `/mode:max`     | Max     | Maximum capability              |
| `/mode:plan`    | Plan    | Planning & architecture tasks   |

## Check Usage

Send `/usage` inside the Codebuff input to view your current credits and subscription quota:

bash

```
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- '/usage'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
sleep 2
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -50
```

The result will show a status bar at the bottom of the TUI, for example:

```
Session: 0 credits · Remaining: 454 credits (4 from ads) · Renews: Apr 9
```

| Field | Description |
| --- | --- |
| `Session` | Credits consumed in the current session |
| `Remaining` | Total credits still available |
| `(N from ads)` | Bonus credits earned from ads |
| `Renews` | Date when credits reset |

## Interactive Session (tmux)

### 1. Setup Socket & Session

```bash
SOCKET="${TMPDIR:-/tmp}/tmux-sockets/agent.sock"
mkdir -p "$(dirname "$SOCKET")"
SESSION=codebuff-session

# Kill existing session if any
tmux -S "$SOCKET" kill-session -t "$SESSION" 2>/dev/null || true

# Create new detached session
tmux -S "$SOCKET" new -d -s "$SESSION" -n shell

# Verify session is active
tmux -S "$SOCKET" list-sessions
```

### 2. Start Codebuff

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- \
  '/root/.nvm/versions/node/v22.22.0/bin/codebuff'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
```

### 3. Wait for Codebuff to be Ready

Poll until the Codebuff TUI is fully loaded (confirmed by "Enter a coding task" appearing):

```bash
for i in {1..20}; do
  sleep 3
  OUTPUT=$(tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -50)
  
  if echo "$OUTPUT" | grep -q "Enter a coding task\|CODEBUFF"; then
    echo "✅ Codebuff READY!"
    echo "$OUTPUT"
    break
  fi
  
  echo "⏳ Check $i — still loading..."
done
```

### 4. Send a Prompt

Always send text and Enter as two separate `send-keys` calls with a delay in between:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- \
  'List all files and explain what this project does'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
```

### 5. Monitor Output

```bash
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -100
```

### 6. Switch Mode Mid-Session

Switch modes at any point without leaving Codebuff:

```bash
# Switch to FREE mode
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- '/mode:free'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter

# Switch to MAX mode
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- '/mode:max'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter

# Switch to PLAN mode
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- '/mode:plan'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter

# Switch to DEFAULT mode
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- '/mode:default'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
```

After switching mode, wait for confirmation before sending the next prompt:

```bash
sleep 2
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -20
```

## Full Workflow Example

```bash
SOCKET="${TMPDIR:-/tmp}/tmux-sockets/agent.sock"
mkdir -p "$(dirname "$SOCKET")"
SESSION=codebuff-session

# 1. Create session
tmux -S "$SOCKET" kill-session -t "$SESSION" 2>/dev/null || true
tmux -S "$SOCKET" new -d -s "$SESSION" -n shell

# 2. Start Codebuff
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- \
  '/root/.nvm/versions/node/v22.22.0/bin/codebuff'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter

# 3. Wait until ready
for i in {1..20}; do
  sleep 3
  OUTPUT=$(tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -50)
  if echo "$OUTPUT" | grep -q "Enter a coding task\|CODEBUFF"; then
    echo "✅ Codebuff READY!"; break
  fi
  echo "⏳ Check $i..."
done

# 4. Start with PLAN mode for planning
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- '/mode:plan'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
sleep 2

# 5. Send task
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- \
  'Your prompt here!'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter

# 6. Switch to MAX mode for implementation
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- '/mode:max'
sleep 0.2
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter

# 7. Check results
sleep 10
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -200
```

## Important Tips

- **NEVER combine** two different commands in a single `send-keys` string when the session is not yet idle at the shell prompt — it will corrupt the command (e.g. `codebuffcd`)
- **Always separate** text and Enter into two distinct `send-keys` calls with `sleep 0.2` in between
- **Use the `-l` flag** on send-keys for literal strings (prevents tmux from interpreting special characters)
- **Polling with grep** is more reliable than a fixed `sleep` for waiting until the TUI is ready
- Modes can be **switched at any time** mid-session without restarting Codebuff

## Cleanup (MANDATORY)

Always kill the session when done — orphaned sessions consume RAM:

```bash
tmux -S "$SOCKET" kill-session -t "$SESSION" 2>/dev/null || true
echo "✅ Session killed."
```

You must running using tmux + codebuff CLI:
$ARGUMENTS
