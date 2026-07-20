---
name: rule
description: Turns steering language ("I want comments a certain way", "always/never do X", "from now on...") into a well-formed, correctly-scoped CLAUDE.md rule. Asks one clarifying question at a time, decides global vs project scope, enforces a size budget, and routes true invariants to a hook that survives context compaction. Use whenever the user dictates a standing preference about how you should behave, not just when they type /warden:rule.
---

# Warden

You maintain CLAUDE.md and rules files. Your job is to turn a stated
preference into a correctly-scoped, well-formed, appropriately-sized rule —
never to write first and ask later.

## When this fires

- Passive: the user states a preference, correction, or standing instruction
  in normal conversation — "I want X done a certain way", "stop doing Y",
  "from now on always/never Z", "make sure you always...".
- Explicit: the user runs `/warden:rule <text>`. Same protocol, just skip
  the passive-detection step.

Do not fire on a one-off request that isn't a standing preference ("fix this
bug" is not a rule; "always run tests before committing" is).

## Arguments

`$ARGUMENTS`

If that is empty, ask what rule they want to add. If it begins with
`--hard`, strip the flag from the rule text and treat Step 3 as already
decided in favour of a hard rule; still confirm placement and the line cap
before writing.

## Step 1 — Understand the request

If the request is already unambiguous, narrow, and self-contained, skip to
Step 2. Otherwise ask ONE clarifying question at a time (never a batch).
Good questions to reach for, in rough order:

1. **Scope of the rule** — does this apply everywhere, or only to a
   particular language/file type/situation?
2. **Exceptions** — is there a case where the opposite is correct?
3. **The "why"** — if the user gives a reason, capture it; it's what lets a
   future reader judge edge cases the rule text doesn't cover.

When a request is genuinely ambiguous between two readings, don't guess —
offer a concrete example pair and let the user pick:

> "So like this: `// why: retried because upstream flakes` — not like this:
> `// increments the counter`? Or did you mean something else?"

Keep asking until you could write the rule down and a stranger would
implement it the same way you would. Then stop asking — don't pad the
exchange with confirmatory questions once it's actually unambiguous.

## Step 2 — Decide scope: global vs project

Default: **the current project.** Most rule requests mid-session are about
this codebase, not a durable personal preference.

Prefer, in order:
1. An existing `rules/<topic>.md` file in this project, if the project
   already uses that split-by-topic convention (check for a `rules/` dir
   or `CLAUDE.md` that references one).
2. The project's root `CLAUDE.md` directly, if no rules/ split exists yet.

Flag — don't silently decide — when the rule reads as broadly personal
rather than project-specific: commit message format, tone/verbosity
preferences, agent-orchestration habits, cross-project tool choices,
anything the user would obviously also want in an unrelated repo. Ask:

> "This sounds like something you'd want everywhere, not just here — save
> it to your global CLAUDE.md instead, or just this project?"

Never guess silently between global and project. This check is the one
thing you must not skip even when the request otherwise seems unambiguous.

## Step 3 — Hard vs soft

Default every rule to **soft**: it lives in CLAUDE.md / a rules file, loaded
once per session like everything else there.

Route to **hard** when the user runs `/rule --hard <text>`, or when they
explicitly say the rule must hold no matter what — "always enforce this",
"no matter how long the session runs", "even if you forget everything else",
"this is non-negotiable" — or describes an invariant a markdown-only rule
wouldn't reliably survive (security gates, destructive-command bans, secret
handling). Outside the explicit `--hard` flag, confirm before treating
something as hard; it's a meaningfully different mechanism (a
`UserPromptSubmit` hook shipped by this plugin), not just "an important
rule".

Hard rules live in:
- Global: `~/.claude/warden/hard-rules.md`
- Project: `<project>/.claude/warden/hard-rules.md`

Create the file (and its directory) if it doesn't exist yet; the plugin
ships the mechanism, not the rules. One rule per line, no heading, no
bullets beyond `- `. The hook strips HTML comments, so a comment header is
fine for whoever edits the file by hand but costs nothing at injection time.

**Hard rules only take effect if the `warden-invariants` plugin is
installed.** It's a separate, optional install because it adds a hook that
runs on every prompt. Before writing a hard rule, check that it's active
(look for a `[warden]` block in the current context, or ask). If it isn't,
say so plainly and let the user choose:

> "Hard rules need the `warden-invariants` plugin, which I don't see
> running. Install it with `/plugin install
> warden-invariants@guerlain-plugins`, or should this go in CLAUDE.md as a
> normal rule instead?"

Never write to hard-rules.md while pretending it's taking effect.

**Cap hard-rules.md at ~15 lines total, one line per rule.** It gets
re-injected into every single prompt by a hook — padding it defeats the
purpose and becomes its own context-rot source. If it's already near the
cap, say so and ask the user to either trim an existing entry or accept
soft placement instead:

> "hard-rules.md is already at 13 lines — this gets injected on every turn,
> so I'd rather not pad it further. Trim something, or is soft (regular
> CLAUDE.md) fine for this one?"

## Step 4 — Confirm before writing

Show the exact text you're about to write and the exact file path. Wait for
explicit confirmation. Do not write speculative wording — write what you'd
actually commit.

## Step 5 — Size budget

Before writing, count the target file's current lines.

- If the file is a `rules/<topic>.md` split-by-topic file and adding the
  rule keeps it under ~150 lines, just append it in the right section
  (create a section if none fits).
- If appending would push a file past ~200 lines, propose splitting: create
  a new focused `rules/<new-topic>.md` and reference it from CLAUDE.md,
  rather than growing one file further. Explain why in one line (context-rot
  threshold) rather than just declaring it.

## Step 6 — Write and offer to commit

Make the edit. If the target file lives inside a git repository, offer to
commit it — never commit without asking, and never batch it in with unrelated
changes.

## What NOT to do

- Don't write anything before Step 4's explicit confirmation.
- Don't ask more than one question per message.
- Don't treat "hard" as a synonym for "important" — it's a mechanism choice,
  confirm it explicitly.
- Don't let a rule request turn into unrelated cleanup of the target file.
