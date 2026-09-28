---
updated: 2026-09-28
---
# Vim version and upgrading it

`vim/` holds vim **9.2.1135** (upstream tag `v9.2.1135`), with iVim's
patches on top. Upstream iVim shipped 8.1.2110; the fork moved to 9.2 on
branch `vim9-rebase` (2026-09-28). `src/` and `runtime/` are plain upstream
except for the patches listed here; upstream dotfiles (`.github` etc.) are
left out.

## How the upgrade was done (repeat it for the next one)

A three-way merge in a scratch git repo, so git finds the iVim hunks:

1. Commit a clean copy of the *old* tag (base), branch off and commit the
   repo's `vim/` over it (the iVim patch), go back to base and commit the
   *new* tag over it, then `git cherry-pick` the iVim commit.
2. Conflicted files: take the new version and re-apply each iVim hunk by
   hand (`git diff base ivim -- <file>` shows them). Most conflicts were
   comment-style changes; `os_unix.c` and `channel.c` need real porting.
3. Regenerate `src/ex_cmdidxs.h` (`vim --clean -X --not-a-term -S
   create_cmdidxs.vim -c quit` in `src/`) and the help `tags`
   (`:helptags runtime/doc`; keep upstream's `help-tags` line).
4. Copy the merged tree into `vim/` (`rsync --delete`).
5. Sync the Xcode project's source list with `BASIC_SRC` in
   `src/Makefile` (plus `job.c`, `channel.c`, `gui.c`, libvterm, xdiff). The
   project lists every file; the pbxproj was edited with a script (new
   PBXFileReference + PBXBuildFile + group child + Sources entry).
6. Build, fix, and run the scripted tests ([testing](testing.md)).

## The iVim patches in vim's sources

Grep for `FEAT_GUI_IOS`, `TARGET_OS_IPHONE` / `TARGET_OS_SIMULATOR`.

| File | What |
|---|---|
| `gui_ios.m`, `proto/gui_ios.pro` | the iOS GUI (iVim's own file) |
| `os_unix.c` | the ios_system process model: fork runs both branches, `ios_term_*` hooks, no pty, env via `ios_term_setenv`, `waitpid` → `ios_term_waitpid`, `mch_exit` → `ios_term_exit_process`, no shell wildcard expansion; see [ios-system](ios-system.md) |
| `channel.c`, `job.c` | register channels with the GUI; terminal input via `ios_term_handle_channel_input`; `ivim_read_channel`, `ivim_cleanup_existing_jobs` (split across both files since 9.x moved jobs to `job.c`) |
| `getchar.c` | calls `ivim_cleanup_existing_jobs()` |
| `ex_cmds.h`, `ex_cmdidxs.h`, `cmdexpand.c` | the `:i…` commands (`:ifont`, `:ishare`, …) |
| `evalfunc.c` | `has('ios')`, `has('ivim')`, `has('gui_ios')`; `mac`/`osx` off |
| `feature.h`, `vim.h`, `gui.h`, `os_mac.h` | GUI enablement, CTFont as `GuiFont`, no curses/select, no socketserver, IME hooks, `STRCPY` → `istrcpy` |
| `version.c`, `main.c` | version text, `VimMain` entry point |
| `list.c`, `xdiff/xpatience.c`, `blowfish.c`, `term.c`, `termlib.c`, `highlight.c`, `gui.c`, `libvterm/include/vterm.h` | small compile fixes (name clashes with Darwin headers, endianness, termlib) |
| `runtime/doc/` | `os_ios.txt`, `ios_commands.txt`, … plus index/tags entries |

Feature defines live in `iVim/ios_prefix.h` (no autoconf).

## Things vim 9 changed that mattered on iOS

Symptoms and fixes in [fixes](fixes.md#vim-92-upgrade). In short: the new
socket client-server, timers gated on `HAVE_DISPATCH_DISPATCH_H`,
`rgb.txt` gone (colour names via `v:colornames`), `system()` with a List
(new direct-exec path that forks), vim9script session files.
