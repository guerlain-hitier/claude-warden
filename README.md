# Warden

Keeps CLAUDE.md clean. When you state a standing preference — "I want
comments a certain way," "never do X," "always run tests first" — Warden
notices, confirms it once, writes it into whichever file already governs
that topic (your global `~/.claude/CLAUDE.md` / `rules/*.md`, or the
current project's), and shows you the diff. No new file formats, no hooks,
no config to maintain — just your existing CLAUDE.md, edited a little more
carefully than doing it by hand mid-conversation.

This is not a rules engine for teams enforcing company policy. It's for one
person who's tired of repeating the same correction every session.

## Install

**macOS / Linux / Git Bash:**
```bash
git clone https://github.com/<you>/claude-warden.git
cd claude-warden
./install.sh
```

**Windows PowerShell:**
```powershell
git clone https://github.com/<you>/claude-warden.git
cd claude-warden
./install.ps1
```

Copies a skill and a `/rule` command into `~/.claude/`. Never touches your
CLAUDE.md or settings.json. Safe to re-run.

## Use

```
/rule always run tests before committing
```

or just say it in conversation. Warden asks a clarifying question only if
something's actually unclear, defaults new rules to global scope (flagging
if something looks project-specific instead), then shows the exact rule and
file before writing anything, plus a diff after.

It stays quiet for one-off requests ("fix this bug") — it only engages for
things you're stating as a standing preference.

## Repo layout

```
skills/warden/SKILL.md   the skill: when it fires, how it picks a file, how it confirms
commands/rule.md         the /rule slash command
install.sh / install.ps1 installers
```

## License

MIT
