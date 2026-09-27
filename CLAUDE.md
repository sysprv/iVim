# iVim fork

Personal fork of terrychou/iVim (vim for iOS, last upstream commit 2020),
updated for iOS 27. Bundle id `io.github.sysprv.ivim`, shown as "iVim Dev",
URL scheme `ivimdev`. Free Apple developer account: no App Group or iCloud,
builds expire after 7 days. Deployment target iOS 15.

## Build

Needs Xcode (26.0 on this Mac, macOS 15; only the iOS 26 simulator is
available, the user's iPhone runs iOS 27).

    scripts/fetch-frameworks.sh     # required once; re-runs only redo what changed

It downloads ios_system (holzschu, pinned release) and builds ivish
(terrychou, pinned commit + `scripts/ivish-upstream-ios_system.patch`) into
`Frameworks/` (git-ignored). The project doesn't build without them.

    # simulator
    xcodebuild -project iVim.xcodeproj -scheme iVim -configuration Debug \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
      -derivedDataPath <dir> build
    xcrun simctl install "iPhone 17 Pro" <dir>/Build/Products/Debug-iphonesimulator/iVim.app
    xcrun simctl launch "iPhone 17 Pro" io.github.sysprv.ivim

    # iPhone (device id from `xcrun devicectl list devices`)
    xcodebuild ... -destination 'id=<udid>' -allowProvisioningUpdates build
    xcrun devicectl device install app --device <id> <dir>/Build/Products/Debug-iphoneos/iVim.app
    xcrun devicectl device process launch --device <id> --terminate-existing io.github.sysprv.ivim

Launch fails with "Locked" when the phone is locked; ask the user to open it.
After the app is deleted, the user has to trust the developer certificate
again (Settings > General > VPN & Device Management).

Copying files to the phone (`devicectl device copy to`) is risky; there's
no remove command to undo mistakes. Ask the user first, and:
- with a single `--source`, `--destination Documents/` is taken as the
  target file name: it replaces the whole Documents folder.
- a copied directory itself ends up owned by root, so the app can't write
  in it (mkdir/undo files fail with E739/E828). Copy only files, into
  directories the app created; or let the user copy via Files/Working Copy.
Expect many warnings from vim/ctags C code; legacy clang errors are
downgraded via WARNING_CFLAGS on the iVim target.

## Testing

- Don't drive the simulator with osascript keystrokes: the Mac's Norwegian
  layout and simulator shortcuts garble them. Instead put a vim script in
  the app's `Documents/` (`xcrun simctl get_app_container ... data`),
  source it from `.vimrc`, drive it with `timer_start()` /
  `term_sendkeys()`, write results to a file there, and read it from the
  Mac. Vim is 8.1: no default-argument lambdas; wrap steps in try/catch.
  Remove the test hook afterwards.
- iVim restores the last session on launch; start terminal tests with a
  timer after that (~3 s).
- `sample <pid>` shows where a hang is; `xcrun simctl spawn <sim> log show
  --predicate 'process == "iVim"'` shows ios_system's own logging.
- Simulator: keep I/O > Keyboard > Connect Hardware Keyboard on (off drops
  Mac keystrokes); Cmd-K shows the software keyboard.
- The user's vim config is github.com/sysprv/vimrc (its INSTALL script, with
  HOME pointed at the app's Documents).

## How commands work (ios_system)

Everything is one process: commands are frameworks called on threads
(`ls_main` etc., looked up in `commandDictionary.plist`), fork() hands out
fake pids, stdio is thread-local, cwd/env live in ios_system "sessions"
(`currentSession` is a global). Upstream ios_system differs from the
unpublished one iVim/ivish were built against:

- `exit()`, `_exit()`, `abort()` only end the calling thread; vim's own
  exit uses `ios_term_exit_process()` (libSystem's exit).
- `ios_progname()` returns the app's name; `ios_term.m` records each
  command's name when it starts (`process_progname()`).
- `ios_closeSession()` leaves no current session; ivish uses one session
  per shell.
- `extraCommandsDictionary.plist` (ivish, ctags) is registered with
  `addCommandList()`; `commandPersonalities.plist` (termmode/intaction per
  command, ivish = raw) was recreated, the original wasn't published.
- ivish needs `ivish_context_t`, not the bare callbacks.

Known issues: `:q` with a running `:terminal` hangs (user accepted: exit
the terminal first). Programs needing a tty/raw mode (less) and precise
Ctrl-C don't work (patched-out ios_system APIs). `system()` of a command
with its own redirection gives E484. Python isn't included yet (planned).

## Git

Branch `ios27-keyboard-fix`. Remotes: `origin` = the fork sysprv/iVim,
`upstream` = terrychou/iVim (don't open PRs there). Push over https with
`git -c credential.helper= -c 'credential.helper=!gh auth git-credential' push`
(the global helper is osxkeychain).
Commit messages: minimal, scoped format, no Co-Authored-By trailer, e.g.

    ios_term: fix exit code for commands that fail to start

    Optional short body only when the why isn't obvious.
