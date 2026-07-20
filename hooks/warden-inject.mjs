#!/usr/bin/env node
// UserPromptSubmit hook: re-injects "hard" (invariant) rules on every turn,
// read live off disk, so they can never be lost to context compaction or
// summarized-away conversation history.

import { readFileSync, existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const MAX_LINES = 15; // keep the injected block tiny — see SKILL.md Step 3

function readHardRules(path) {
  if (!existsSync(path)) return null;
  const text = readFileSync(path, "utf8").trim();
  if (!text) return null;
  const lines = text.split("\n").slice(0, MAX_LINES);
  return lines.join("\n");
}

function main() {
  let input = "";
  try {
    input = readFileSync(0, "utf8");
  } catch {
    // no stdin — nothing to key project path off of, fall back to global only
  }

  let cwd = process.cwd();
  try {
    const parsed = JSON.parse(input);
    if (parsed.cwd) cwd = parsed.cwd;
  } catch {
    // malformed/absent stdin JSON — proceed with process.cwd()
  }

  const globalPath = join(homedir(), ".claude", "warden", "hard-rules.md");
  const projectPath = join(cwd, ".claude", "warden", "hard-rules.md");

  const globalRules = readHardRules(globalPath);
  const projectRules = readHardRules(projectPath);

  if (!globalRules && !projectRules) {
    process.exit(0); // nothing to inject, stay silent
  }

  const sections = [];
  if (globalRules) sections.push(`Global hard rules:\n${globalRules}`);
  if (projectRules) sections.push(`Project hard rules:\n${projectRules}`);

  const additionalContext =
    "[warden] These rules are invariant — hold regardless of session length " +
    "or compaction:\n\n" +
    sections.join("\n\n");

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "UserPromptSubmit",
        additionalContext,
      },
      suppressOutput: true,
    })
  );
  process.exit(0);
}

main();
