---
updated: 2026-09-28
---
# Overview

Personal fork of [terrychou/iVim](https://github.com/terrychou/iVim) (vim 8.1
for iOS; last upstream commit 2020), updated to vim 9.2
([vim-upgrade](vim-upgrade.md)), at
[sysprv/iVim](https://github.com/sysprv/iVim), branch `ios27-keyboard-fix`.
Quick cleanup for the owner's own use, done with an LLM; not a maintained
continuation. Why iVim rather than Blink Shell or a-Shell: its extended
keyboard and a real `gui_running` vim.

## Goal and status

The trigger: on iOS 27 the App Store iVim drew vim full-screen, with the
statusline and command line hidden behind the keyboard. Fixed and verified
on the owner's iPhone (iOS 27). Since then, also working: `:terminal` with
ivish and external commands ([ios-system](ios-system.md), [ivish](ivish.md)),
`:q`, the cursor with `blinkon0`, `guifont` sizes. All fixes with root
causes: [fixes](fixes.md). Vim 9.2.1135 (branch `vim9-rebase`)
works on the simulator; not yet tried on the phone. Open problems: [known-issues](known-issues.md).

## Identity and decisions

- Bundle id `io.github.sysprv.ivim` (+ `.share`), shown as "iVim Dev", URL
  scheme `ivimdev`, so it can sit next to the App Store iVim.
- Paid Apple developer account, team B9Y5MBFAT8 (the same id the free
  personal team had). App Store Connect app "iVim sysprv fork"; distributed
  to the owner via TestFlight, internal testing only
  ([release-testflight](release-testflight.md)).
- Deliberately no App Group (so "Share with iVim" can't work) and no iCloud.
- Export compliance: `ITSAppUsesNonExemptEncryption = NO` (vim's file
  encryption declared exempt, the owner's decision).
- Deployment target iOS 15 (ios_system needs 14, ivish is built for 15).
- Python: wanted, not done. Lua and iplug: not wanted.

## Environment

Mac on macOS 15 with Xcode 26.0, so only iOS 26 simulators; the iPhone runs
iOS 27, so iOS-27-only behaviour can only be checked on the device
([build](build.md), [device](device.md), [testing](testing.md)). The
owner's vim setup: [user-setup](user-setup.md).
