#!/usr/bin/env node
// Additively merges the warden UserPromptSubmit hook into settings.json.
// Never overwrites the file; never removes existing hooks; safe to re-run
// (detects if warden's hook is already registered and skips).

import { readFileSync, writeFileSync, existsSync } from "node:fs";

const [, , settingsPath, hookCommand] = process.argv;

if (!settingsPath || !hookCommand) {
  console.error("usage: merge-settings.mjs <settings.json path> <hook command>");
  process.exit(1);
}

let settings = {};
if (existsSync(settingsPath)) {
  const raw = readFileSync(settingsPath, "utf8").trim();
  if (raw) {
    try {
      settings = JSON.parse(raw);
    } catch (err) {
      console.error(
        `error: ${settingsPath} exists but isn't valid JSON — fix or back it up before re-running install.`
      );
      process.exit(1);
    }
  }
}

settings.hooks ??= {};
settings.hooks.UserPromptSubmit ??= [];

const alreadyRegistered = settings.hooks.UserPromptSubmit.some((entry) =>
  (entry.hooks ?? []).some((h) => h.command?.includes("warden-inject.mjs"))
);

if (alreadyRegistered) {
  console.log("warden hook already registered in settings.json — leaving as-is.");
} else {
  settings.hooks.UserPromptSubmit.push({
    hooks: [
      {
        type: "command",
        command: hookCommand,
        timeout: 10,
      },
    ],
  });
  writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + "\n");
  console.log(`registered warden hook in ${settingsPath}`);
}
