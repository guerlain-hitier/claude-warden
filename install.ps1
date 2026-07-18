#requires -Version 5.1
# Installs Warden into ~/.claude on Windows: a skill + a /rule command.
# Nothing else. Safe to re-run, never touches CLAUDE.md.

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }

Write-Host "Installing Warden into $ClaudeDir ..."

New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir "skills\warden") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir "commands") | Out-Null

Copy-Item (Join-Path $ScriptDir "skills\warden\SKILL.md") (Join-Path $ClaudeDir "skills\warden\SKILL.md") -Force
Copy-Item (Join-Path $ScriptDir "commands\rule.md") (Join-Path $ClaudeDir "commands\rule.md") -Force

Write-Host ""
Write-Host "Warden installed:"
Write-Host "  skill:   $ClaudeDir\skills\warden\SKILL.md"
Write-Host "  command: /rule  ($ClaudeDir\commands\rule.md)"
Write-Host ""
Write-Host "Try it: run '/rule always run tests before committing' in a Claude Code session."
