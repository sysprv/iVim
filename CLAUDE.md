# iVim fork

Personal fork of terrychou/iVim (vim for iOS), updated for iOS 27.
Bundle id `io.github.sysprv.ivim` ("iVim Dev"), paid team B9Y5MBFAT8,
TestFlight app "iVim sysprv fork". Details live in the wiki (below); read
`wiki/index.md` first when a task touches something not covered here.

## Essentials

- Before the first build: `scripts/fetch-frameworks.sh` (ios_system +
  patched ivish into `Frameworks/`; the project doesn't build without it).
- Build: `xcodebuild -project iVim.xcodeproj -scheme iVim` for
  `platform=iOS Simulator,name=iPhone 17 Pro` or the device
  (`-allowProvisioningUpdates`). Only iOS 26 simulators; the user's
  iPhone runs iOS 27. More: `wiki/build.md`.
- Test behaviour with vim scripts sourced from the app's `.vimrc`, not
  osascript keystrokes; see `wiki/testing.md`.
- Ask the user before writing anything to the phone
  (`devicectl device copy to`): it has destroyed data before and there is
  no undo. Never use `--remove-existing-content` on the app container.
  See `wiki/device.md`.
- TestFlight: raise `CURRENT_PROJECT_VERSION` (all four entries) before
  every upload; steps in `wiki/release-testflight.md`.
- `vim/` is vim 9.2.1135 plus iVim's patches, all guarded by
  `FEAT_GUI_IOS`; keep them minimal. Patch list and upgrade steps:
  `wiki/vim-upgrade.md`.
- Everything runs in one process via ios_system, whose upstream
  `exit()`, `ios_progname()` and sessions behave differently from what
  iVim expected: read `wiki/ios-system.md` before touching `ios_term.m`,
  `os_unix.c` process code or the ivish patch.

## Git

Branch `ios27-keyboard-fix`. Remotes: `origin` = the fork sysprv/iVim,
`upstream` = terrychou/iVim (don't open PRs there). Push over https with
`git -c credential.helper= -c 'credential.helper=!gh auth git-credential' push`
(the global helper is osxkeychain).
Commit messages: minimal, scoped format, no Co-Authored-By trailer, e.g.

    ios_term: fix exit code for commands that fail to start

    Optional short body only when the why isn't obvious.

## Wiki (`wiki/`)

An LLM-maintained knowledge base after Karpathy's "LLM Wiki" pattern. The
LLM writes and maintains it; the user reads it and directs.

- Layers: raw sources (upstream repos, the user's vimrc, sessions; listed
  in `wiki/sources.md`, never copied or modified) → wiki pages → this file
  (the schema).
- Pages: one topic each, lowercase-hyphenated file names, YAML front
  matter with `updated: YYYY-MM-DD`, relative markdown links between pages
  (`[fixes](fixes.md)`), no duplicated facts — link instead.
- `wiki/index.md`: every page with a one-line summary, by category. Update
  it whenever a page is added, renamed or its scope changes.
- `wiki/log.md`: append-only; each entry starts `## [YYYY-MM-DD] kind |
  title` with kind ingest, query, lint or update.
- Ingest: after a fix, finding or decision, update the affected pages
  (root cause in `fixes.md`, open problems in `known-issues.md`, status in
  `overview.md`), then index and log. Do it in the same commit as the code
  change where possible (`wiki:` scope for wiki-only commits).
- Query: answer from the wiki (index first), cite pages; file useful
  answers back as pages.
- Lint (when asked or when pages look stale): contradictions, stale
  claims, orphan pages, missing links or pages; log it.
- Keep this file to what every session needs; move detail to the wiki.
