---
name: warden
description: Turns a stated standing preference ("I want comments a certain way", "always/never do X", "from now on...") into a CLAUDE.md or rules/*.md edit, with minimal back-and-forth. Only fires for standing preferences meant to apply going forward, not one-off task requests. Also handles the explicit /rule command.
---

# Warden

Keep a clean CLAUDE.md. That's the whole job — not a rules engine, not a
hook, not a second storage format. Just: notice when the user is stating a
standing preference, confirm it once, write it into the file that already
governs that topic, show the diff.

## When this fires

**Only for standing preferences** — something meant to hold going forward:
"always run tests before committing", "never use emojis in commit messages",
"from now on, do X", "I want comments written a certain way".

**Not for one-off requests** — "fix this bug", "run the tests", "add a
button here". These get zero interruption. If you're not sure whether
something is a standing preference or a one-off, ask once, briefly:
"Want me to remember this as a rule, or is this just for now?" Don't ask
this on every message — most messages are one-offs. Err toward silence;
a rule that should have been saved can always be added later with `/rule`.

**Explicit:** `/rule <text>` always runs the flow below, no passive-detection
judgment call needed.

## Flow

1. **Pick the target file.** Default to global scope, `~/.claude/CLAUDE.md`
   directly — most standing preferences are general habits, not project
   quirks, and unless the user has set up a `rules/*.md` split, there's
   just the one file. Sanity-check yourself first: if the rule only makes
   sense for the current repo (names this project's specific stack/files/
   conventions), say so and ask instead of assuming global. If a
   `rules/*.md` split-by-topic convention exists (check for a `rules/`
   directory before assuming there isn't one), edit the matching topic
   file instead of CLAUDE.md directly — don't invent a new file either way.

2. **Make sure the request is clear.** If it's already unambiguous, skip
   straight to step 3. Only ask a clarifying question if something is
   genuinely unclear (one question, not a list). Only offer an example
   pair ("like this ✅ / not this ❌") if a question alone wouldn't
   resolve the ambiguity.

3. **Summarize and confirm.** One line: what the rule says and which file
   it goes in. Ask to add it. Don't re-confirm the wording separately from
   this — one confirmation, not a Q-then-draft-then-confirm chain.

4. **Write it and show the diff.** A short diff of the actual change, not
   a rewritten dump of the file.

## Don't

- Don't build a second file/store/hook for anything. If it needs to be
  remembered, it goes in CLAUDE.md or an existing `rules/*.md` file —
  full stop.
- Don't ask more than one question before showing the proposed change.
- Don't interrupt for requests that aren't standing preferences.
