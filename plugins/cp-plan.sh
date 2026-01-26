#!/bin/bash
#
# Script to copy the latest plan file from ~/.claude/plans to myspec/plan
# Usage: ./cp-plan.sh [destination-dir]
#

set -e

# Source directory
SOURCE_DIR="$HOME/.claude/plans"

# Default destination directory (can be overridden by argument)
DEST_DIR="${1:-./myspec/plan}"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# Check if destination directory exists
if [ ! -d "$DEST_DIR" ]; then
    echo "Error: Destination directory $DEST_DIR does not exist"
    exit 1
fi

# Find the latest file by modification time
LATEST_FILE=$(ls -t "$SOURCE_DIR"/*.md 2>/dev/null | head -n 1)

if [ -z "$LATEST_FILE" ]; then
    echo "Error: No .md files found in $SOURCE_DIR"
    exit 1
fi

# Get the filename
FILENAME=$(basename "$LATEST_FILE")

# Copy the file
echo "Copying latest plan file:"
echo "  Source: $LATEST_FILE"
echo "  Destination: $DEST_DIR/$FILENAME"

cp "$LATEST_FILE" "$DEST_DIR/"

echo "✓ Successfully copied $FILENAME to $DEST_DIR"
