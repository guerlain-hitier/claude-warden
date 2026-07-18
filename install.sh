#!/usr/bin/env bash
# Installs Warden into ~/.claude. Safe to re-run — merges into existing
# settings.json rather than overwriting, and never touches your CLAUDE.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

command -v node >/dev/null 2>&1 || {
  echo "error: node is required (used by the settings.json merge step and the hook itself)." >&2
  exit 1
}

echo "Installing Warden into $CLAUDE_DIR ..."

mkdir -p "$CLAUDE_DIR/skills/warden" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/warden/hooks"

cp "$SCRIPT_DIR/skills/warden/SKILL.md" "$CLAUDE_DIR/skills/warden/SKILL.md"
cp "$SCRIPT_DIR/commands/rule.md" "$CLAUDE_DIR/commands/rule.md"
cp "$SCRIPT_DIR/hooks/warden-inject.mjs" "$CLAUDE_DIR/warden/hooks/warden-inject.mjs"
cp -n "$SCRIPT_DIR/docs/research.md" "$CLAUDE_DIR/warden/research.md" 2>/dev/null || true

if [ ! -f "$CLAUDE_DIR/warden/hard-rules.md" ]; then
  cat > "$CLAUDE_DIR/warden/hard-rules.md" <<'EOF'
<!--
Global hard rules — re-injected into EVERY prompt by the warden-inject hook.
Keep this to a handful of one-line, non-negotiable invariants (max ~15 lines
total). Anything longer belongs in your regular CLAUDE.md / rules files
instead — see ~/.claude/warden/research.md for why.
-->
EOF
fi

HOOK_CMD="node \"$CLAUDE_DIR/warden/hooks/warden-inject.mjs\""

node "$SCRIPT_DIR/scripts/merge-settings.mjs" "$CLAUDE_DIR/settings.json" "$HOOK_CMD"

echo ""
echo "Warden installed:"
echo "  skill:   $CLAUDE_DIR/skills/warden/SKILL.md"
echo "  command: /rule  ($CLAUDE_DIR/commands/rule.md)"
echo "  hook:    UserPromptSubmit -> warden-inject.mjs (registered in settings.json)"
echo "  hard rules file: $CLAUDE_DIR/warden/hard-rules.md (empty template, edit or let /rule --hard fill it in)"
echo ""
echo "Try it: run '/rule always use conventional commit messages' in a Claude Code session."
