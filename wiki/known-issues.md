---
updated: 2026-10-07
---
# Known issues

- **`:q` with a running `:terminal` hangs** (tested: >30 s). Vim waits for
  the job to stop. User accepted it: exit terminals first. Not
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
- **Downgrading from a vim 9.2 build to an 8.1 build** leaves junk files
  in `Library/ivim/scenes` (named like `_splitbelow = &splitbelow`): 9.2
  writes the auto-restore session as vim9script, and 8.1 reads
  `save_splitbelow = …` as `:save[as]`. Only when going back to an old
  build; harmless, delete the files.
- **`system('false')`** gives 127: `false` isn't an ios_system command
  (same on 8.1).
- **Commands started at the same instant** (e.g. two `job_start()` calls
  in a row) can get each other's or ios_system's default environment
  (then `ls` colours again): ios_system keeps one "next environment" slot
  and `ios_system()` blocks for the whole command, so iVim can't lock
  across store and copy. Seen in about 1 of 5 runs of a back-to-back test.
- **dSYM warning** for ivish.framework on upload (harmless,
  [release-testflight](release-testflight.md)).
- **`WARNING_CFLAGS`** also softens implicit-declaration errors in iVim's
  own code ([build](build.md)).
