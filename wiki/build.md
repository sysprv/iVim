---
updated: 2026-09-28
---
# Build

## Frameworks

    scripts/fetch-frameworks.sh

Required before the first build: the project references the frameworks and
Xcode refuses to build without them (there is no "lite" build any more). It
downloads the pinned [ios_system](ios-system.md) release (ios_system, files,
shell, text, tar, awk xcframeworks and `commandDictionary.plist`) and builds
[ivish](ivish.md) from a pinned commit plus
`scripts/ivish-upstream-ios_system.patch`, into `Frameworks/` and
`Resources/commandDictionary.plist` (both git-ignored). Downloads are cached
in `build/deps` and fetched in parallel; ivish is only rebuilt when the
commit or the patch changes (stamp file). After changing the patch, re-run
it, then rebuild iVim.

## Simulator

    xcodebuild -project iVim.xcodeproj -scheme iVim -configuration Debug \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
      -derivedDataPath <dir> build
    xcrun simctl install "iPhone 17 Pro" <dir>/Build/Products/Debug-iphonesimulator/iVim.app
    xcrun simctl launch "iPhone 17 Pro" io.github.sysprv.ivim

Only iOS 26 simulators exist on this Mac. Reinstalling moves the app's data
container; get the path again with `xcrun simctl get_app_container <sim>
io.github.sysprv.ivim data`.

## iPhone

    xcodebuild ... -destination 'id=<udid>' -allowProvisioningUpdates build

then install and launch with devicectl, see [device](device.md).
Distribution: [release-testflight](release-testflight.md).

## Project notes

- Expect many warnings from vim and ctags C code. Clang errors that old C
  triggers (implicit int, incompatible function pointers, implicit function
  declarations, int conversion) are downgraded via `WARNING_CFLAGS` on the
  iVim target — this also softens them for iVim's own code.
- `ENABLE_CODE_COVERAGE = NO` on the iVim target: Xcode 26 enables coverage
  for Debug, and the app then writes `default.profraw` into its Documents
  folder (visible in Files).
- Vim's `.c` files are listed one by one in the iVim target; keep them in
  sync with `src/Makefile` when upgrading vim ([vim-upgrade](vim-upgrade.md)).
  libvterm's `screen.c`/`mouse.c` share names with vim's; Xcode handles it.
  `xdiff/xpatience.c` has a per-file `-fno-modules` ([vim-upgrade](vim-upgrade.md)).
- `vim/src/proto/gui_ios.pro` hides a BOOL/block prototype from plain C
  files with `#ifdef __OBJC__`.
- Xcode dependency tracking doesn't notice changes in `__has_include`
  results: clean-build after adding or removing frameworks.
- Xcode re-sorts build settings and writes `xcuserdata/` (ignored) when the
  owner opens the project; that's noise, not a change.
