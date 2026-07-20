# Warden

A CLAUDE.md maintainer for Claude Code. Turns steering language ("I want
comments a certain way", "never do X", "always run tests first") into a
correctly-scoped, well-formed, size-budgeted rule instead of an ad hoc edit
you have to word yourself.

Two independent pieces:

- **A skill + `/rule` command.** Asks clarifying questions one at a time,
  offers a compliant/non-compliant example when a request is ambiguous,
  decides whether the rule belongs in global `~/.claude/CLAUDE.md` or the
  current project, and enforces a size budget so your rules files stay in
  the range Claude actually follows.
- **A `UserPromptSubmit` hook.** Re-injects a short, curated set of
  *invariant* rules every turn, read live off disk, so they survive context
  compaction and long-session summarization that ordinary CLAUDE.md content
  does not. See [`docs/research.md`](docs/research.md) for the community
  research behind this.

## Why

CLAUDE.md files rot two ways. They grow past the point where Claude reliably
follows everything in them, and separately, path-scoped or nested rules can
vanish once compaction summarizes the history they were loaded into. Warden
handles both: it pushes back on padding when you add a rule, and it gives you
a hook-based channel for the handful of rules that must never depend on being
still in context.

## Install

Requires [Node.js](https://nodejs.org), used by the hook and the
settings.json merge step.

**macOS / Linux / Git Bash:**
```bash
git clone https://github.com/guerlain-hitier/claude-warden.git
cd claude-warden
bash install.sh
```

**Windows PowerShell:**
```powershell
git clone https://github.com/guerlain-hitier/claude-warden.git
cd claude-warden
powershell -ExecutionPolicy Bypass -File ./install.ps1
```

The installer only adds files under `~/.claude/` (skill, command, hook
script, empty `hard-rules.md` template) and additively merges one
`UserPromptSubmit` entry into `~/.claude/settings.json`. It never overwrites
your `CLAUDE.md`, never removes existing hooks, and is safe to re-run.

## Use

```
/rule always use conventional commit messages
```

Or say it in conversation ("from now on, always run tests before
committing") and the skill picks it up, asks what it needs, tells you which
file it's targeting and why, then shows the exact text before writing.

For a true invariant that survives compaction and gets re-injected every
turn (keep this rare):

```
/rule --hard never force-push to main
```

## Repo layout

```
skills/warden/SKILL.md      the interactive rule-formulation skill
commands/rule.md            the /rule slash command shim
hooks/warden-inject.mjs     UserPromptSubmit hook: re-injects hard-rules.md live
scripts/merge-settings.mjs  additive settings.json merge used by installers
docs/research.md            sourced research this design is based on
docs/design.md              the design spec this was built from
install.sh / install.ps1    installers
```

## License

MIT
