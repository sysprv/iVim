---
updated: 2026-09-27
---
# ivish

Terry Chou's shell for iVim's `:terminal`
([terrychou/ivish](https://github.com/terrychou/ivish), version 1.20,
commit 5647a86 pinned in `scripts/fetch-frameworks.sh`). iVim's vimrc sets
`shell=ivish`; `Resources/extraCommandsDictionary.plist` maps the command
`ivish` to `ivish.framework/ivish` / `ivish_main`.

## The patch (`scripts/ivish-upstream-ios_system.patch`)

Makes ivish build and run with upstream [ios_system](ios-system.md):

- `ios_setWindowSize()` gets the session id.
- Removed: TTY provider/restorer (commands opening `/dev/tty`, raw mode),
  `ios_addNonTTYFileNo` (redirected output marked non-TTY), per-session
  command names (so `intCandidate` is always nil and Ctrl-C falls back to
  generic handling). The `sid` still passed to `preCmd` is a placeholder.
- One ios_system session per shell (`sessionId`, a stable `strdup`'d
  pointer, never freed) instead of a new session per command that was
  closed afterwards: closing left no current session and ivish's exit
  crashed in ios_system's cleanup, looping at 100 % CPU.

To change it: edit the checkout in `build/deps/ivish`, `git diff >
scripts/ivish-upstream-ios_system.patch`, re-run the fetch script (it
notices the changed patch).

## How iVim talks to it

- `ios_term.m` passes an `ivish_context_t` (callbacks + parent shell NULL)
  via `ios_setContext()`; ivish 1.20 crashes on the bare callbacks struct.
- ivish has its own line editor, so its `termmode` must be `raw` in
  `commandPersonalities.plist`; in `line` mode iVim also edits/echoes input
  and sends `\n`, which ivish doesn't treat as Enter.
- The terminal starts in vim's cwd; with the owner's `sesdir` session
  option that was iVim's `Library/ivim/scenes` ([user-setup](user-setup.md)).
