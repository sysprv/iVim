---
updated: 2026-10-07
---
# The user's setup

- Vim config: [github.com/sysprv/vimrc](https://github.com/sysprv/vimrc);
  its `INSTALL` script copies `.vimrc`, `.gvimrc`, `.vim/0.vim`,
  `.vim/statusline_defs.vim`, `.vim/indent/python.vim`, `.vim/colors/`.
  Uses `showmode` (mode message on the command line; mode in the
  statusline is only for terminal panes), `guicursor ... blinkon0`,
  `guifont=Menlo:h10.0` on iOS, undo files under `~/.vim/var/un` managed by
  its own `wundo`/`rundo` autocmds, `set sessionoptions+=sesdir`.
- iVim detection in vimscript: `has('ivim')` (also `has('ios')`,
  `has('gui_ios')`); `has('gui_running')` is true in iVim, so `.gvimrc`
  loads too.
- `sesdir` + iVim's auto-restore (a session saved in
  `Library/ivim/scenes`) makes vim, and new terminals, start in that
  folder; suggested guard: `if !has('ivim') | set sessionoptions+=sesdir |
  endif`.
- `0.vim` sources the default `Session.vim` (iVim, no file arguments)
  directly from the vimrc. In the GUI the screen doesn't exist yet then
  (`&lines` 24, then 70 at GUIEnter, the real size after), and
  `update_topline()` (`vim/src/move.c`) without a valid screen sets the
  top line to the cursor line, so the session's `zt` is lost: the window
  starts at the cursor and later resizes keep it there, leaving the last
  lines of a long file at the top (cursor 298/300: top line 296 instead of
  the saved 266). Sourcing it later fixes it:
  `autocmd UserVimRc VimEnter * ++nested silent source Session.vim`
  gives the saved view (simulator, 2026-10-07). Same cause as the
  config's `v:version < 802` `z-` workaround. Not an iVim bug: any GUI
  vim sourcing a session from the vimrc does it. The user switched to
  VimEnter and dropped `autowriteall` (2026-10-07): once, after a killed
  session, a clean-swap recovery left an extra blank line that got
  written; not reproduced since.
- `.gvimrc`'s `UserTrimMenus` gives E329 (no ToolBar menu in iVim):
  harmless.
- The config's normal-mode Enter mapping runs a search (E486 on stray
  Enters).
- A "blank, unreachable row" above the statusline after `G` is vim's
  end-of-buffer `~` filler: the colorscheme's `EndOfBuffer` (`#242940`)
  is nearly invisible. It appears when the line above the top line wraps
  into more rows than are left; `number` changes wrapping, so it comes
  and goes. Plain vim behaviour; `smoothscroll` removes it (tested on the
  simulator, 2026-10-06).
- Files: Working Copy links repos into iVim's folder via the Files app
  (`UIFileSharingEnabled`, `LSSupportsOpeningDocumentsInPlace`). An empty
  or dot-files-only Documents folder doesn't show up in Files.
- The Mac and phone use a Norwegian keyboard layout and region, but the
  user types dots for decimals ([guifont fix](fixes.md#guifont-sizes)).
- Fonts: `:ifont` lists fonts, `:ifont Menlo 9` / `:ifont <n> <size>`
  selects; built-in names are `SourceCodePro-Regular`, `Courier`,
  `CourierNewPSMT`, `Menlo-Regular` (prefixes like `Menlo` work).
