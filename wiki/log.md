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
