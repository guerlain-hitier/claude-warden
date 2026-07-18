#requires -Version 5.1
# Installs Warden into ~/.claude on Windows. Safe to re-run — merges into
# existing settings.json rather than overwriting, and never touches CLAUDE.md.

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "node is required (used by the settings.json merge step and the hook itself)."
    exit 1
}

Write-Host "Installing Warden into $ClaudeDir ..."

New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir "skills\warden") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir "commands") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir "warden\hooks") | Out-Null

Copy-Item (Join-Path $ScriptDir "skills\warden\SKILL.md") (Join-Path $ClaudeDir "skills\warden\SKILL.md") -Force
Copy-Item (Join-Path $ScriptDir "commands\rule.md") (Join-Path $ClaudeDir "commands\rule.md") -Force
Copy-Item (Join-Path $ScriptDir "hooks\warden-inject.mjs") (Join-Path $ClaudeDir "warden\hooks\warden-inject.mjs") -Force

$researchDest = Join-Path $ClaudeDir "warden\research.md"
if (-not (Test-Path $researchDest)) {
    Copy-Item (Join-Path $ScriptDir "docs\research.md") $researchDest -Force
}

$hardRulesPath = Join-Path $ClaudeDir "warden\hard-rules.md"
if (-not (Test-Path $hardRulesPath)) {
    @'
<!--
Global hard rules — re-injected into EVERY prompt by the warden-inject hook.
Keep this to a handful of one-line, non-negotiable invariants (max ~15 lines
total). Anything longer belongs in your regular CLAUDE.md / rules files
instead — see ~/.claude/warden/research.md for why.
-->
'@ | Set-Content -Encoding utf8 $hardRulesPath
}

$hookScriptPath = Join-Path $ClaudeDir "warden\hooks\warden-inject.mjs"
$hookCmd = "node `"$hookScriptPath`""
$settingsPath = Join-Path $ClaudeDir "settings.json"
$mergeScript = Join-Path $ScriptDir "scripts\merge-settings.mjs"

& node $mergeScript $settingsPath $hookCmd

Write-Host ""
Write-Host "Warden installed:"
Write-Host "  skill:   $ClaudeDir\skills\warden\SKILL.md"
Write-Host "  command: /rule  ($ClaudeDir\commands\rule.md)"
Write-Host "  hook:    UserPromptSubmit -> warden-inject.mjs (registered in settings.json)"
Write-Host "  hard rules file: $hardRulesPath (empty template, edit or let /rule --hard fill it in)"
Write-Host ""
Write-Host "Try it: run '/rule always use conventional commit messages' in a Claude Code session."
