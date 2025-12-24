#!/bin/bash

# Claude Code Telemetry Setup Script
# This script safely adds telemetry configuration to your Claude Code settings
# without overwriting existing configuration.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Determine settings file path based on OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    SETTINGS_DIR="$USERPROFILE/.claude"
    SETTINGS_FILE="$SETTINGS_DIR/settings.json"
else
    SETTINGS_DIR="$HOME/.claude"
    SETTINGS_FILE="$SETTINGS_DIR/settings.json"
fi

echo "Claude Code Telemetry Setup"
echo "============================"
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo ""
    echo "Install jq:"
    echo "  macOS:  brew install jq"
    echo "  Ubuntu: sudo apt-get install jq"
    echo "  Windows: choco install jq"
    exit 1
fi

# Create .claude directory if it doesn't exist
if [ ! -d "$SETTINGS_DIR" ]; then
    echo -e "${YELLOW}Creating $SETTINGS_DIR directory...${NC}"
    mkdir -p "$SETTINGS_DIR"
fi

# Define the telemetry env variables to add
TELEMETRY_ENV='{
  "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
  "OTEL_METRICS_EXPORTER": "otlp",
  "OTEL_LOGS_EXPORTER": "otlp",
  "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
  "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4317"
}'

# If settings file doesn't exist, create it with the telemetry config
if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}Creating new settings file...${NC}"
    echo "{\"env\": $TELEMETRY_ENV}" | jq '.' > "$SETTINGS_FILE"
    echo -e "${GREEN}Created $SETTINGS_FILE with telemetry configuration.${NC}"
else
    # Backup existing settings
    BACKUP_FILE="${SETTINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo -e "${YELLOW}Backed up existing settings to: $BACKUP_FILE${NC}"

    # Read existing settings
    EXISTING_SETTINGS=$(cat "$SETTINGS_FILE")

    # Check if it's valid JSON
    if ! echo "$EXISTING_SETTINGS" | jq empty 2>/dev/null; then
        echo -e "${RED}Error: Existing settings.json is not valid JSON.${NC}"
        echo "Please fix the file manually and try again."
        exit 1
    fi

    # Merge the env variables
    # This preserves all existing settings and merges the env object
    MERGED_SETTINGS=$(echo "$EXISTING_SETTINGS" | jq --argjson telemetry "$TELEMETRY_ENV" '
        .env = ((.env // {}) + $telemetry)
    ')

    # Write the merged settings
    echo "$MERGED_SETTINGS" > "$SETTINGS_FILE"
    echo -e "${GREEN}Updated $SETTINGS_FILE with telemetry configuration.${NC}"
fi

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Current telemetry settings:"
jq '.env' "$SETTINGS_FILE"
echo ""
echo -e "${YELLOW}Important: Restart Claude Code for changes to take effect.${NC}"
echo ""
echo "Next steps:"
echo "  1. Start the monitoring stack: docker-compose up -d"
echo "  2. Restart Claude Code"
echo "  3. Open Grafana at http://localhost:3000 (login: admin/admin)"
