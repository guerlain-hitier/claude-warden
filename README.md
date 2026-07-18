# Warden

A CLAUDE.md maintainer for Claude Code. Turns steering language — "I want
comments a certain way," "never do X," "always run tests first" — into a
correctly-scoped, well-formed, appropriately-sized rule instead of an ad hoc
edit you have to word yourself.

Two independent pieces:

- **A skill + `/rule` command** that asks clarifying questions one at a
  time, offers a compliant/non-compliant example when a request is
  ambiguous, checks whether the rule belongs in your global
  `~/.claude/CLAUDE.md` or the current project, and enforces a size budget
  so your rules files stay in the range Claude actually follows.
- **A `UserPromptSubmit` hook** that re-injects a short, explicitly-curated
  set of *invariant* rules on every single turn, read live off disk — so
  they can't be lost to context compaction or a long session's summarized
  history the way ordinary CLAUDE.md content can. See
  [`docs/research.md`](docs/research.md) for the community research this is
  built on (what survives compaction, what doesn't, and why).

## Why

CLAUDE.md files rot two ways: they grow past the point where Claude reliably
follows everything in them, and — separately — path-scoped or nested rules
can vanish from a long session's context after compaction summarizes the
history they were loaded into. Warden addresses both: it pushes back on
padding when you ask it to add a rule, and it gives you a second, hook-based
channel for the handful of rules that must never depend on being "still in
context."

## Install

Requires [Node.js](https://nodejs.org) (used by the hook itself and the
settings.json merge step).

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

The installer only adds files under `~/.claude/` (skill, command, hook
script, and an empty `hard-rules.md` template) and additively merges one
`UserPromptSubmit` hook entry into `~/.claude/settings.json`. It never
overwrites your `CLAUDE.md`, never removes existing hooks, and is safe to
re-run.

## Use

```
/rule always use conventional commit messages
```

or just say it in conversation — "from now on, always run tests before
committing" — and the warden skill will pick it up, ask anything it needs to
before writing, tell you which file it's targeting and why, and show you the
exact text before touching anything.

To mark something as a true invariant (survives compaction, re-injected
every turn — keep this rare):

```
/rule --hard never force-push to main
```

## Repo layout

```
skills/warden/SKILL.md   the interactive rule-formulation skill
commands/rule.md         the /rule slash command shim
hooks/warden-inject.mjs  UserPromptSubmit hook: re-injects hard-rules.md live
scripts/merge-settings.mjs  additive settings.json merge used by installers
docs/research.md         sourced research this design is based on
docs/design.md           the design spec this was built from
install.sh / install.ps1 installers
```

## License

MIT
