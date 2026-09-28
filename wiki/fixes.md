---
updated: 2026-09-28
---
# Fixes: symptoms and root causes

Everything changed relative to upstream iVim, with the reasoning. Code is
in the three squashed commits on `ios27-keyboard-fix` plus later ones.

## Keyboard layout (the original bug)

- Symptom (iOS 27, App Store iVim): vim full-screen, statusline and command
  line behind the keyboard.
- Cause: `VimViewController.tuneFrameAccordingToKeyboard` set the root
  view's frame height on keyboard notifications; newer iOS re-lays out the
  root view and undoes it.
- Fix: `VimMainView` pins the vim view's bottom to `keyboardLayoutGuide`
  (iOS 15+; includes the extended bar, the input accessory view, and the
  bottom safe area). Manual frame code removed.
- Note: the old code also works on the iOS 26 simulator; the bug only
  showed on iOS 27, verified fixed on the phone.

## Cursor flicker with `blinkon0`

- Cause: vim calls `gui_mch_start_blink()` on every wait for input; iVim's
  Swift `VimCursorBlinker.startBlinking` lacked the other GUIs' check that
  no blink time is zero, so the cursor was mostly hidden and flashed.
- Fix: guard in `startBlinking` (as in `gui_gtk_x11.c`).

## Shell commands hung (`system()`, `:!`)

- `mch_call_shell_fork` only creates pipes when output is shown; for
  `system()` (temp file) `fd_toshell`/`fd_fromshell` were uninitialised, so
  `ios_term_run` failed to open streams and returned without an exit code;
  vim's waitpid loop never ended, and ios_system's fork lock stayed held
  (next `fork()` deadlocked).
- Fix: initialise the fds to -1 (`os_unix.c`); `ios_term_run` uses
  `/dev/null` for missing fds and records exit code 127 if streams still
  can't be opened.
- Leftover: `system('cmd > file')` runs but gives E484 (ios_system doesn't
  handle vim's `(cmd) > tmpfile` wrapping).

## `:terminal` / ivish

- ivish didn't compile, crashed on start, garbled input, and hung on exit:
  see [ivish](ivish.md) and [ios-system](ios-system.md). Causes:
  unpublished ios_system APIs, `ivish_context_t` layout, input mode chosen
  by `ios_progname()` (the app's name), session closing.

## `:q` froze the app

- Cause: upstream ios_system replaces `exit()` with `pthread_exit`; vim's
  final `exit(r)` in `mch_exit()` only ended the main thread.
- Fix: `ios_term_exit_process()` calls libSystem's `exit` (via `dlopen` /
  `dlsym`, falls back to `_Exit`).
- Still open: quitting with a running `:terminal` hangs
  ([known-issues](known-issues.md)).

## guifont sizes

- Symptom: `:set guifont=Menlo:h9.0` did nothing; the owner's config
  (`Menlo:h10.0`) never applied, so the default font at 14 pt was used.
- Causes: sizes parsed with `NumberFormatter()` in the phone's region
  format (Norway: decimal comma, so `9.0` → nil; whole numbers worked);
  font names had to match exactly (`Menlo-Regular`).
- Fix (`VimFontsManager.swift`): parse with the `en_US_POSIX` locale; fall
  back to the first font whose name starts with the given one. Shipped in
  TestFlight build 2.

## Vim 9.2 upgrade

Vim 8.1.2110 → 9.2.1135 ([vim-upgrade](vim-upgrade.md)). Problems found
while porting, all checked on the simulator:

- **Black screen at start**: 9.2's new `+socketserver` (clientserver over a
  Unix socket) failed to listen, and its error waited for Enter before the
  GUI had drawn anything. Fix: no `FEAT_SOCKETSERVER` on iOS
  (`feature.h`), so no `+clientserver` either (8.1 didn't have it).
- **Timers silently gone** (`has('timers')` 0, `timer_start` unknown): on
  Darwin, 9.x only enables `+reltime`/`+timers` with
  `HAVE_DISPATCH_DISPATCH_H`. Fix: define it in `ios_prefix.h`; the
  macOS `timer_create()` emulation in `os_mac.h` is skipped on iOS (it
  lives in `os_macosx.m`, not built), so timeouts use `setitimer()`.
- **`E254: Cannot allocate color grey25`**: iVim's colour lookup fell back
  to `$VIMRUNTIME/rgb.txt`, which 9.x removed. Fix: `gui_mch_get_color()`
  calls vim's `gui_get_color_cmn()` (all X11 names via `v:colornames`),
  like the Win32 and Haiku GUIs. `DarkYellow` is now vim's `#8b8b00`
  instead of iVim's `#bbbb00`.
- **`system(['cmd', 'arg'])`** (new in 9.x) runs argv directly via its own
  `fork()`/`execvp()`, which would never finish under ios_system. Fix: on
  iOS, `mch_get_cmd_output_direct()` shell-escapes the list and runs it as
  a string command.
- `:terminal` line endings: 9.x converts lone NL to CR NL itself for
  `PART_ERR`; on iOS (no pty) this now applies to all parts, replacing
  iVim's `ios_term_translate_msg()` (which also doubled existing CRs).
- Compile fixes: `extend()` in `list.c` clashed with an enum constant from
  `MacTypes.h`, which `gui.h` pulled into every file via
  `<CoreText/CoreText.h>`; `gui.h` now only forward-declares `CTFontRef`
  (`gui_ios.pro` imports `<objc/objc.h>` for `BOOL`, which used to come
  along). `xdiff/xpatience.c`'s `struct entry` clashes with Darwin's
  `search.h` under clang modules; that file is built with `-fno-modules`.
  Removed `FEAT_TITLE`/`FEAT_MBYTE`
  guards in `gui_ios.m` (the latter had silently disabled the wide cursor
  over double-width characters since 8.1.0733); new
  `gui_mch_get_scrollbar_{x,y}padding()` stubs; API renames
  (`MODE_NORMAL`, `UPD_NOT_VALID`, `SOURCING_NAME`, extra args to
  `trans_special`, `close_buffer`, `buf_reload`); macOS task QoS call
  skipped on iOS.
- Lua support dropped from `ios_prefix.h` (not wanted, never shipped).

## Smaller

- Personal bundle ids, team, URL scheme, display name; entitlements for App
  Group/iCloud removed ([overview](overview.md)).
- Code coverage off, BOOL prototype, `WARNING_CFLAGS` ([build](build.md)).
- Deployment target 10 → 15, which allowed dropping the pre-iOS 15 code.
