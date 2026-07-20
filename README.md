<div align="center">

# Warden

**Keep your CLAUDE.md small, and your non-negotiables unforgettable.**

![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-blueviolet)
![No telemetry](https://img.shields.io/badge/telemetry-none-lightgrey.svg)

</div>

Say what you want once, in passing, and it becomes a properly worded rule in
the right file. The handful that truly must never slip get injected into
every prompt, so a long session can't quietly forget them.

```
you: from now on, commit messages should be one line, no body

warden: Adding to ~/.claude/CLAUDE.md:
          - Commit messages: conventional, one line, no body.

        This one looks like it'd drift over a long session. I can also
        promote it to a hard rule, injected every turn (5 of 15 used).
        Want that, or CLAUDE.md alone?
```

## The problem

CLAUDE.md files fail two different ways.

They **grow**, past the point where the model reliably follows everything in
them. And they **fade**: rules load once at session start, so when a long
session compacts, the summary can drop them. The rule is still sitting on
disk. The model just can't see it anymore, and neither of you notices.

## How it works

Warden splits the difference between "you maintain your rules by hand" and
"the AI manages your rules for you." Neither one works. Hand-maintained
files rot, and an agent with write access to its own constraints is a bad
idea.

So the work is split:

| Claude does | You do |
| :--- | :--- |
| Notices you stated a standing preference | Confirm it's a rule, not a one-off |
| Words it so a stranger would apply it the same way | Approve the exact text |
| Picks the file: global vs project, which rules file | Override if it guessed wrong |
| Judges whether it's worth injecting every turn | Decide yes or no |
| Warns when a file is getting too big to follow | Choose what to cut |

Claude proposes, you dispose. Nothing is written without you seeing the
exact text first, and nothing is ever removed on Claude's initiative.

## Soft rules and hard rules

**Soft** is the default and where almost everything belongs: normal
CLAUDE.md content, loaded once per session.

**Hard** is a promotion on top of that. The rule stays in CLAUDE.md *and*
gets re-injected on every prompt, so compaction can't take it. Warden
assesses every rule for this and offers it when it fits, rather than waiting
for you to know the magic word. It fits when all four hold:

1. Violating it is expensive, or it's a habit that visibly erodes over long
   sessions
2. It applies on every turn, not just to certain files or tasks
3. It fits on one line
4. It isn't already being followed reliably

Most rules fail that test, and warden says nothing. Because hard rules
stay in CLAUDE.md too, uninstalling the hook degrades them to normal rules
instead of silently dropping them.

## Scope

Warden is a personal steering mechanism, not a governance system.

It's built for one person keeping a dozen habits consistent across their own
sessions: commit style, comment conventions, how much explanation you want.
The hard-rules file is capped at 15 lines on purpose, because every line
costs context on every turn.

It is **not** a policy engine. If you need hundreds of rules, team-wide
enforcement, audit trails, or a guarantee a rule was obeyed, warden is the
wrong tool. Nothing here validates compliance. It puts text in front of the
model, and the model does what it does.

## Install

```
/plugin marketplace add guerlain-hitier/claude-warden
/plugin install warden@guerlain-plugins
```

That's a complete install: passive detection, `/warden:rule`, and the file
and size logic. It runs no background code. Stop here if you want.

### The optional hook

Hard rules need a second plugin. It's separate, and opt-in, because it adds
a `UserPromptSubmit` hook: code that runs on every prompt you send.

```
/plugin install warden-invariants@guerlain-plugins
```

Requires [Node.js](https://nodejs.org).

**Why a hook at all.** A hook is the only mechanism that runs *after*
compaction, on every turn. Nothing in a markdown file can do that.

**What it does.** Reads `hard-rules.md`, strips comments, prints the first
15 lines back to Claude, and warns if your file is longer than that. That's
all. 91 lines in
[`warden-inject.mjs`](plugins/warden-invariants/hooks/warden-inject.mjs),
worth skimming before you install. No network calls, no file writes, no
telemetry.

**Skip it if** you mostly run short sessions, or you'd rather not have code
running on every prompt. The rule writer works fine alone, and it will tell
you hard rules aren't active rather than writing ones that do nothing.

## Use

Just say it. Warden fires on standing preferences and stays quiet on one-off
requests.

```
from now on, always run the tests before committing
```

Or be explicit:

```
/warden:rule always use conventional commit messages
/warden:rule --hard never force-push to main
```

Hard rules live in `~/.claude/warden/hard-rules.md`, or
`<project>/.claude/warden/hard-rules.md` for project-specific ones. Both are
injected when present, and warden creates them on first use. They arrive at
the top of each turn like this:

```
[warden] These rules are invariant, hold regardless of session length or compaction:

Global hard rules:
- Never use em dashes.
- Commit messages: conventional, one line, no body.
```

**The 15 line cap is enforced, not advisory.** Rules past it are not
injected and therefore not in effect. The hook says so on stderr and in the
injected block, so an over-long file is loud rather than quietly broken, but
it won't fix it for you.

That file is yours, not the plugin's. It survives updates and uninstalls, so
it's worth keeping in whatever repo you sync your dotfiles with.

## Layout

```
.claude-plugin/marketplace.json  lets the repo host both plugins itself

plugins/warden/                  the rule writer, no background code
  skills/rule/SKILL.md           the rule-formulation protocol

plugins/warden-invariants/       the optional hook
  hooks/hooks.json               registers UserPromptSubmit
  hooks/warden-inject.mjs        reads hard-rules.md, injects it
```

## Development

```bash
git clone https://github.com/guerlain-hitier/claude-warden.git
claude --plugin-dir ./claude-warden/plugins/warden
```

Add a second `--plugin-dir` for `warden-invariants` to test the hook.
`/reload-plugins` picks up edits without a restart.

## License

MIT
