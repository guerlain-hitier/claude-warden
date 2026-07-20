# Warden

A CLAUDE.md maintainer for Claude Code, plus a hook that keeps your
non-negotiable rules from being forgotten mid-session.

## The problem

CLAUDE.md files rot two ways. They grow past the point where Claude reliably
follows everything in them. And separately, rules loaded once at session
start can vanish from context after compaction summarizes the history they
were loaded into. The rule is still on disk; it's just no longer in front of
the model.

## The solution

Two pieces that work independently.

**A rule writer.** Say "from now on, always run tests before committing" and
warden picks it up, asks one clarifying question at a time, decides whether
it belongs in your global `~/.claude/CLAUDE.md` or this project, checks the
target file's size budget, and shows you the exact text before writing.

**A hook.** A handful of rules you mark as *hard* get re-injected into every
prompt, read live off disk. They can't be summarized away, because they're
re-added after every compaction.

## Scope

Warden is a personal steering mechanism, not a governance system.

It's built for one person keeping maybe a dozen habits consistent across
their own sessions: commit message style, comment conventions, how much
explanation you want. The hard-rules file is capped at 15 lines on purpose,
because every line costs context on every single turn.

It is **not** a policy engine. If you need hundreds of rules, per-team
enforcement, audit trails, or guarantees that a rule was actually obeyed,
warden is the wrong tool and will quietly disappoint you. Nothing here
validates compliance. It puts text in front of the model and the model
does what it does.

## Install

```
/plugin marketplace add guerlain-hitier/claude-warden
/plugin install warden@guerlain-plugins
```

Requires [Node.js](https://nodejs.org) for the hook.

### What it runs on your machine

Installing this plugin means a `UserPromptSubmit` hook executes on every
prompt you send. Warden's hook does exactly one thing: read
`hard-rules.md`, strip comments, print the first 15 lines back to Claude.
It's 71 lines in [`hooks/warden-inject.mjs`](hooks/warden-inject.mjs) and
worth skimming before you install. No network calls, no writes, no
telemetry.

This is true of any plugin shipping hooks, not just this one. Read them
before you trust them.

## Use

```
/warden:rule always use conventional commit messages
```

Or just say it in conversation. Warden fires on standing preferences and
stays quiet on one-off requests.

For an invariant that survives compaction, keep these rare:

```
/warden:rule --hard never force-push to main
```

Hard rules live in `~/.claude/warden/hard-rules.md`, or
`<project>/.claude/warden/hard-rules.md` for project-specific ones. Both are
injected when present. Warden creates them on first use.

They arrive at the top of each turn looking like this:

```
[warden] These rules are invariant, hold regardless of session length or compaction:

Global hard rules:
- Never use em dashes.
- Commit messages: conventional, one line, no body.
```

That file is yours, not the plugin's. It survives updates and uninstalls, so
it's worth keeping in whatever repo you sync your dotfiles with.

## Layout

```
.claude-plugin/plugin.json       plugin manifest
.claude-plugin/marketplace.json  so the repo can host itself
skills/rule/SKILL.md             the rule-formulation protocol
hooks/hooks.json                 registers the UserPromptSubmit hook
hooks/warden-inject.mjs          reads hard-rules.md, injects it
```

## Development

```bash
git clone https://github.com/guerlain-hitier/claude-warden.git
claude --plugin-dir ./claude-warden
```

Then `/reload-plugins` to pick up edits.

## License

MIT
