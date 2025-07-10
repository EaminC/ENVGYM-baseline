#!/bin/bash

# Automated script to run codex CLI for Dockerfile generation
# Author: Auto-generated
# Date: $(date +%Y-%m-%d)

set -e  # Exit on error

# Get script directory (should be baseline directory now)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASELINE_DIR="$SCRIPT_DIR"

echo "Script location: $SCRIPT_DIR"
echo "Baseline directory: $BASELINE_DIR"
echo "Current working directory: $(pwd)"

# Change to baseline directory if not already there
cd "$BASELINE_DIR"
echo "Working from baseline directory: $(pwd)"

# Record start time
START_TIME=$(date +%s)
START_TIME_READABLE=$(date '+%Y-%m-%d %H:%M:%S')

echo "Starting Codex CLI task..."
echo "Task: Create Dockerfile with necessary tests and verification"
echo "Start time: $START_TIME_READABLE"
echo "========================================"

# Check if codex/dist/cli.js exists
if [ ! -f "./codex/dist/cli.js" ]; then
    echo "Error: ./codex/dist/cli.js file not found"
    echo "Please build the project first or ensure the file path is correct"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Execute the command from baseline directory
cd codex
node ./dist/cli.js \
    --approval-mode full-auto \
    "Please creat a dockerfile for this repo，you should add necessary test into the dockerfile.Also you should build and run this dockerfile to verify the environment is totally set up" \
    -q

# Calculate and display execution time
END_TIME=$(date +%s)
END_TIME_READABLE=$(date '+%Y-%m-%d %H:%M:%S')
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo "========================================"
echo "Task completed successfully!"
echo "End time: $END_TIME_READABLE"
echo "Total execution time: ${MINUTES}m ${SECONDS}s" 