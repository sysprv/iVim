---
updated: 2026-09-28
---
# ios_system and the one-process model

[holzschu/ios_system](https://github.com/holzschu/ios_system), pinned in
`scripts/fetch-frameworks.sh` (v3.0.6). iOS forbids starting processes, so
everything runs inside the iVim process:

- Commands are frameworks (`files`, `text`, `shell`, `tar`, `awk`) with
  `main()` renamed (`ls_main`, …), looked up by name in
  `commandDictionary.plist` and called on a new thread via `dlopen`.
- `fork()` only hands out a fake pid; vim's `os_unix.c` runs the "child" and
  "parent" branches one after the other on iOS.
- stdio is thread-local (`thread_stdout` etc.); `printf`, `write`, `exit`
  are macro-redirected (`vim/src/iviminclude/ios_system/ios_error.h`).
- cwd and environment live in "sessions"; `currentSession` is a single
  global, sessions are keyed by the *pointer* passed to
  `ios_switchSession()`, and switching `chdir()`s to the session's
  directory. `cd` updates the current session's directory.
- "Signals" are `pthread_kill`/`pthread_cancel` or registered handlers.
- Environment: each command gets a copy of the environment of the command
  started last, not of `environ`; iVim passes one explicitly
  ([fixes](fixes.md#command-environment-ls-colour-codes)). Swift code
  (ivish) calls libc `getenv()`, not `ios_getenv()`.
- Nothing is isolated: a crashing command can take the app down (ios_system
  catches crashes per thread), global state is shared, memory limits are
  the app's.

iVim's glue is `iVim/ios_term.m` (process table, sessions per pid, stream
setup, `:terminal` input handling) plus hooks in `vim/src/os_unix.c` and
`channel.c`.

## Upstream vs. what iVim was written against

iVim (2020) and [ivish](ivish.md) (2023) were built against an unpublished,
modified ios_system. Differences found, and how they're handled:

| Upstream behaviour | Handling |
|---|---|
| `exit()`, `_exit()`, `abort()` only end the calling thread | vim's own exit calls `ios_term_exit_process()` (libSystem's `exit`) |
| `ios_progname()` returns the app's name outside the command | `ios_term_run()` records each command's name (`process_progname()`) |
| `ios_closeSession()` leaves no current session → later cleanup crashes | ivish uses one session per shell |
| extra commands only loaded when side-loading | `addCommandList()` for `Resources/extraCommandsDictionary.plist` (ivish, ctags) |
| no TTY provider/restorer, non-TTY fds, per-session command names | patched out of ivish; see [known-issues](known-issues.md) |
| `ios_setWindowSize` takes a session id | adapted in the ivish patch |

`Resources/commandPersonalities.plist` (per-command `termmode` line/raw and
`intaction`, read by `ios_term.m` and ivish via `$IVISH_CMD_DB`) wasn't
published; recreated with just ivish = raw.

Details of each fix: [fixes](fixes.md).
