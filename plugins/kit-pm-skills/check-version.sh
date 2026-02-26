#!/bin/bash
# Kit PM Skills version check
# Called by Claude Code UserPromptSubmit hook — output is passed to Claude as context.

PLUGIN_JSON="$HOME/.claude/plugins/marketplaces/kit-pm-skills/plugins/kit-pm-skills/.claude-plugin/plugin.json"
CONFIG=".claude/pm-skills/config.md"

# Skip silently if either file not found
[ -f "$PLUGIN_JSON" ] || exit 0
[ -f "$CONFIG" ] || exit 0

# Read versions
PLUGIN_VERSION=$(python3 -c "import json; d=json.load(open('$HOME/.claude/plugins/marketplaces/kit-pm-skills/plugins/kit-pm-skills/.claude-plugin/plugin.json')); print(d.get('version',''))" 2>/dev/null)
INSTALLED_VERSION=$(grep "^installed_version:" "$CONFIG" 2>/dev/null | awk '{print $2}' | tr -d '[:space:]')

# No installed_version in config yet — skip (user needs to run /update first)
[ -z "$INSTALLED_VERSION" ] && exit 0

# Versions match — nothing to do
[ "$PLUGIN_VERSION" = "$INSTALLED_VERSION" ] && exit 0

# Show the notice at most once per day per version pair
FLAG="/tmp/kit-pm-skills-notify-$(date +%Y%m%d)-${INSTALLED_VERSION//./}"
[ -f "$FLAG" ] && exit 0
touch "$FLAG"

echo "Note: kit-pm-skills has been updated to v${PLUGIN_VERSION} (your workspace is configured for v${INSTALLED_VERSION}). Run /update to apply new settings."
