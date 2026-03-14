#!/data/data/com.termux/files/usr/bin/bash
set -e

########################################
# Hutana Fast Preview Start Script
########################################

BASE="$HOME/hutana_project"
WORKFLOW="$HOME/downloads/hutana/workflow.sh"
STOP="$HOME/downloads/hutana/stop.sh"

echo "======================================"
echo "⚡ Starting Hutana Fast Preview Workflow..."
echo "======================================"

# Stop any previous run
if [ -x "$STOP" ]; then
    echo "🛑 Stopping any previous Hutana workflow..."
    "$STOP"
else
    echo "⚠️ Stop script not found, continuing..."
fi

# Start workflow
if [ -x "$WORKFLOW" ]; then
    echo "🚀 Launching workflow..."
    "$WORKFLOW"
else
    echo "❌ Workflow script not found or not executable!"
    exit 1
fi

