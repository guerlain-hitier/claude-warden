#!/usr/bin/env bash
# Installs Warden into ~/.claude: a skill + a /rule command. Nothing else —
# no hooks, no extra config files. Safe to re-run, never touches CLAUDE.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

echo "Installing Warden into $CLAUDE_DIR ..."

mkdir -p "$CLAUDE_DIR/skills/warden" "$CLAUDE_DIR/commands"

cp "$SCRIPT_DIR/skills/warden/SKILL.md" "$CLAUDE_DIR/skills/warden/SKILL.md"
cp "$SCRIPT_DIR/commands/rule.md" "$CLAUDE_DIR/commands/rule.md"

echo ""
echo "Warden installed:"
echo "  skill:   $CLAUDE_DIR/skills/warden/SKILL.md"
echo "  command: /rule  ($CLAUDE_DIR/commands/rule.md)"
echo ""
echo "Try it: run '/rule always run tests before committing' in a Claude Code session."
