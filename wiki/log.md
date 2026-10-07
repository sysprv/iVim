# Wiki log

Append-only. Entry format: `## [YYYY-MM-DD] kind | title` (kinds: ingest,
query, lint, update). Last entries: `grep "^## \[" wiki/log.md | tail -5`.

## [2026-09-27] ingest | Initial wiki from CLAUDE.md and the first sessions

Created the wiki. Moved build/test/device/TestFlight/ios_system details out
of CLAUDE.md, and ingested the working sessions: the keyboard layout fix,
lite build and its removal, ios_system/ivish bring-up, exit, cursor blink,
guifont, devicectl mishaps, TestFlight builds 1–2. Pages: overview, build,
testing, device, release-testflight, ios-system, ivish, fixes,
known-issues, user-setup, sources.

## [2026-09-28] ingest | Vim 8.1.2110 → 9.2.1135

Rebased iVim's vim patches onto vim 9.2.1135 (branch `vim9-rebase`),
tested on the simulator against the 8.1 build as baseline. New page
vim-upgrade; fixes (vim 9.2 section), known-issues (downgrade junk files,
`false`), overview, sources, testing updated.

## [2026-09-28] update | TestFlight build 3

Uploaded build 3 (vim 9.2) from `vim9-rebase`; release-testflight history.

## [2026-09-28] update | Build 3 verified

User confirmed TestFlight build 3 (vim 9.2) works on the phone.

## [2026-09-28] update | Simplify pass on the vim 9.2 patches

One guard name (`FEAT_GUI_IOS`), smaller hunks (CoreText out of `gui.h`,
`-fno-modules` for xpatience.c instead of a rename, `setenv` macro,
redundant hunks dropped), dead `ios_term_translate_msg` removed. Same
`:version` features and test results as build 3. vim-upgrade, fixes,
build updated.

## [2026-09-28] update | vim9-rebase merged

Fast-forwarded `ios27-keyboard-fix` to `vim9-rebase` and deleted the
branch; overview, vim-upgrade, release-testflight updated.

## [2026-09-28] update | TestFlight build 4

Uploaded build 4 (simplified vim 9.2 patches); release-testflight history.

## [2026-09-28] update | Two nits from build 4

`:!ls` colour escapes traced to ios_system's per-command environment;
session scroll after restoring `Session.vim`. Both in known-issues.

## [2026-09-28] update | Command environment fixed

Commands now get vim's child environment via `storeEnvironment()`; no more
`ls` colour codes in `:!` output. fixes, ios-system, known-issues updated.

## [2026-09-28] update | Simplify pass on the command environment

Dropped iVim's settings cache: vim's upstream `setenv()` calls stay, and
`copy_command_environment()` hands `environ` to `storeEnvironment()`.
Found and documented the concurrent-start race. fixes, known-issues,
vim-upgrade updated.

## [2026-09-28] update | TestFlight build 5

Uploaded build 5 (command environment); build 4 marked verified.

## [2026-09-28] update | Build 5 verified

User confirmed build 5 works on the phone.

## [2026-09-28] update | End-of-session doc pass

README (vim 9.2, TestFlight), CLAUDE.md (pointer to vim-upgrade), fixes
formatting.

## [2026-10-06] update | Tap lands ~30 lines too high

Reproduced the cause in the simulator (keyboard reset on tap resizes vim
before the click is handled); fix in fixes.md, XCUITest taps in
testing.md; TestFlight build 6.

## [2026-10-06] query | Blank row above the statusline at EOF

Vim's `~` filler in a near-invisible colour, not an iVim bug; noted in
user-setup.md.

## [2026-10-06] update | Build 6 verified

User confirmed taps land correctly on the phone; overview status updated.

## [2026-10-07] update | Session.vim restore scroll explained

The last lines at the top after restoring a long file come from sourcing
`Session.vim` in the vimrc, before the GUI screen exists; sourcing it from
VimEnter restores the saved view. Moved from known-issues to user-setup.

## [2026-10-07] update | "user" instead of "owner"

Wiki and CLAUDE.md now call the person who uses and directs the fork the
user.
