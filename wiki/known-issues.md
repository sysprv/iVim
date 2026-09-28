---
updated: 2026-09-28
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
- **Downgrading from a vim 9.2 build to an 8.1 build** leaves junk files
  in `Library/ivim/scenes` (named like `_splitbelow = &splitbelow`): 9.2
  writes the auto-restore session as vim9script, and 8.1 reads
  `save_splitbelow = …` as `:save[as]`. Only when going back to an old
  build; harmless, delete the files.
- **`system('false')`** gives 127: `false` isn't an ios_system command
  (same on 8.1).
- **Restoring a long file from vim's own `Session.vim`** (iVim's
  auto-restore is off on the phone) can leave the last line near the top
  of the window with the rest empty; `ggG` fixes it. The saved values are
  right (cursor row 43 of 44); probably the window is tiny when the
  session's `zt` runs. Not reproduced on the simulator; owner parked it.
- **dSYM warning** for ivish.framework on upload (harmless,
  [release-testflight](release-testflight.md)).
- **`WARNING_CFLAGS`** also softens implicit-declaration errors in iVim's
  own code ([build](build.md)).
