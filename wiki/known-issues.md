---
updated: 2026-09-27
---
# Known issues

- **`:q` with a running `:terminal` hangs** (tested: >30 s). Vim waits for
  the job to stop. Owner accepted it: exit terminals first. Not
  investigated further.
- **Programs that need a tty / raw mode** (`less`, full-screen or
  REPL-style programs) don't work properly; **Ctrl-C** is imprecise. Both
  come from the ios_system APIs patched out of [ivish](ivish.md).
- **`system()` of a command with its own redirection** (e.g.
  `system('echo hi > f')`) runs it but gives E484 (see
  [fixes](fixes.md)).
- **ivish drops typeahead** sent while a command is running.
- **Concurrent commands** (a `system()` while ivish runs) share
  ios_system's global session state; untested and likely fragile
  ([ios-system](ios-system.md)).
- **"Share with iVim"** shows in share sheets but can't work (no App
  Group, by choice).
- **Python** isn't included (planned); lua and iplug not wanted.
- **dSYM warning** for ivish.framework on upload (harmless,
  [release-testflight](release-testflight.md)).
- **`WARNING_CFLAGS`** also softens implicit-declaration errors in iVim's
  own code ([build](build.md)).
