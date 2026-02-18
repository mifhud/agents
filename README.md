# Agents

## Settings Configuration
settings\claude-code-router.json -> ~/.claude-code-router/config.json
settings\claude-code.json -> ~/.claude.json or ~/.claude/config.json
settings\open-code.json -> ~/.config/opencode/opencode.json

## Linking Directory and Running Spec Script
```bash
ln -s /root/01-projects/me/agents/plugins .opencode && ln -s /root/01-projects/me/agents/plugins .claude && ln -s /root/01-projects/me/agents/agent-config . && /root/01-projects/me/agents/scripts/myspec.sh
```