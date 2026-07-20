---
description: Turn a stated preference into a well-formed, correctly-scoped CLAUDE.md rule (dead-simple entry point for the warden skill)
---

Invoke the `warden` skill's rule-formulation protocol on the following
request, treating it as an explicit invocation (skip passive-detection,
go straight to Step 1 of SKILL.md):

$ARGUMENTS

If the request begins with `--hard`, strip that flag from the rule text and
treat it as the user explicitly asking for a hard rule. Step 3's routing is
already decided, so don't re-litigate hard vs soft, but still confirm the
placement and the ~15 line cap before writing.

If no arguments were given, ask the user what rule they want to add.
