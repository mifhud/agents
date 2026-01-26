#!/bin/bash

# 1. Create directory structure
# -p ensures parent folders are created if they don't exist
mkdir -p "myspec/debug"
mkdir -p "myspec/issue"
mkdir -p "myspec/plan"
mkdir -p "myspec/design"
mkdir -p "myspec/archive/debug"
mkdir -p "myspec/archive/issue"
mkdir -p "myspec/archive/plan"
mkdir -p "myspec/archive/design"

echo "✅ Directories created successfully."

# 2. Update or create .gitignore
GITIGNORE=".gitignore"
ENTRY="myspec/archive"
SETTINGS_ENTRY="agent-config"
MCP_CLAUDE_ENTRY=".mcp.json"
OPENCODE_ENTRY="opencode.json"
JDTLS_ENTRY=".jdtls-workspace"
OSGREP_ENTRY=".osgrep"
CLAUDE_DIR_ENTRY=".claude"
OPENCODE_DIR_ENTRY=".opencode"

if [ -f "$GITIGNORE" ]; then
    # If the file exists, add a newline and the entries to ensure they don't merge with existing text
    echo "" >> "$GITIGNORE"
    echo "$ENTRY" >> "$GITIGNORE"
    echo "$SETTINGS_ENTRY" >> "$GITIGNORE"
    echo "$MCP_CLAUDE_ENTRY" >> "$GITIGNORE"
    echo "$OPENCODE_ENTRY" >> "$GITIGNORE"
    echo "$JDTLS_ENTRY" >> "$GITIGNORE"
    echo "$OSGREP_ENTRY" >> "$GITIGNORE"
    echo "$CLAUDE_DIR_ENTRY" >> "$GITIGNORE"
    echo "$OPENCODE_DIR_ENTRY" >> "$GITIGNORE"
    echo "✅ '$ENTRY', '$SETTINGS_ENTRY', '$MCP_CLAUDE_ENTRY', '$OPENCODE_ENTRY', '$JDTLS_ENTRY', '$OSGREP_ENTRY', '$CLAUDE_DIR_ENTRY', and '$OPENCODE_DIR_ENTRY' added to the existing .gitignore."
else
    # If the file does not exist, create a new one
    echo "$ENTRY" >> "$GITIGNORE"
    echo "$SETTINGS_ENTRY" >> "$GITIGNORE"
    echo "$MCP_CLAUDE_ENTRY" >> "$GITIGNORE"
    echo "$OPENCODE_ENTRY" >> "$GITIGNORE"
    echo "$JDTLS_ENTRY" >> "$GITIGNORE"
    echo "$OSGREP_ENTRY" >> "$GITIGNORE"
    echo "$CLAUDE_DIR_ENTRY" >> "$GITIGNORE"
    echo "$OPENCODE_DIR_ENTRY" >> "$GITIGNORE"
    echo "✅ New .gitignore created with entries '$ENTRY', '$SETTINGS_ENTRY', '$MCP_CLAUDE_ENTRY', '$OPENCODE_ENTRY', '$JDTLS_ENTRY', '$OSGREP_ENTRY', '$CLAUDE_DIR_ENTRY', and '$OPENCODE_DIR_ENTRY'."
fi

# 3. Create .mcp.json file
MCP_FILE=".mcp.json"
cat > "$MCP_FILE" << 'EOF'
{
    "mcpServers": {
        "code-mode": {
            "command": "npx",
            "args": [
                "@utcp/code-mode-mcp"
            ],
            "env": {
                "UTCP_CONFIG_FILE": "${PWD}/.utcp_config.json"
            }
        }
    }
}
EOF
echo "✅ .mcp.json for claude code created successfully."

# 4. Create opencode.json file
OPENCODE_FILE="opencode.json"
cat > "$OPENCODE_FILE" << 'EOF'
{
  "mcp": {
        "code-mode": {
            "type": "local",
            "command": [
                "npx",
                "@utcp/code-mode-mcp"
            ],
            "environment": {
                "UTCP_CONFIG_FILE": "${PWD}/.utcp_config.json"
            }
        }  
  },
  "lsp": {
  }
}
EOF
echo "✅ opencode.json created successfully."

# 5. Create .utcp_config.json file
UTCP_CONFIG_FILE=".utcp_config.json"
cat > "$UTCP_CONFIG_FILE" << 'EOF'
{
    "manual_call_templates": [
        {
            "call_template_type": "mcp",
            "config": {
                "mcpServers": {
                }
            }
        }
    ]
}
EOF
echo "✅ .utcp_config.json created successfully."

# 6. Create .claude/config.json file
mkdir -p ".claude"
CLAUDE_CONFIG_FILE=".claude/config.json"
cat > "$CLAUDE_CONFIG_FILE" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(git checkout:*)"
    ],
    "deny": [
      "Bash(git rm:*)"
    ]
  }
}
EOF
echo "✅ .claude/config.json created successfully."