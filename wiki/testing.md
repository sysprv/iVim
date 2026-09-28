---
updated: 2026-09-28
---
# Testing

## Scripted tests inside vim (preferred)

Don't drive the simulator with osascript/System Events keystrokes: the
Mac's Norwegian layout and simulator shortcuts garble them (lost `:`,
dropped spaces, the app sent to the home screen). Instead:

1. Write a vim script to the app's `Documents/` (simulator:
   `xcrun simctl get_app_container "iPhone 17 Pro" io.github.sysprv.ivim data`).
2. Append a guarded `source` of it to `Documents/.vimrc`, keep a backup of
   the original `.vimrc`.
3. Drive the test with `timer_start()` (start after ~3–4 s: iVim restores
   the last session after startup and replaces the window), `system()`,
   `term_start()`, `term_sendkeys()` (one command per step: ivish drops
   typeahead while a command runs), `term_getline()`, `term_getstatus()`.
4. Write results with `writefile(..., 'a')` to a file in Documents and read
   it from the Mac.
5. Restore `.vimrc`, delete the test files. Clear
   `Library/ivim/scenes/` (auto-restore session) when a test leaves windows
   behind, or the next launch restores them.

Vim is 9.2 ([vim-upgrade](vim-upgrade.md)); when a test must also run on
an old 8.1 build, avoid 9.x-only syntax and options (`silent! set`, source
vim9script files behind `has('vim9script')`). Wrap steps in try/catch (an error
silently aborts a timer callback); `term_getjob()` of a finished terminal
is null. On the device, copy the script there only with the owner's OK and
per [device](device.md).

## Diagnosing

- `sample <pid> 1` shows where a hang is (find the pid with
  `pgrep -f "iVim.app/iVim"`); CPU at 0 % means waiting, ~100 % a loop.
- `xcrun simctl spawn <sim> log show --last 2m --predicate 'process ==
  "iVim"'` includes ios_system's own logging ("Starting command", "command
  not found", cleanup).
- Temporary `NSLog("IVIMDBG ...")` lines plus that log command worked well
  for tracing input; remove them afterwards.
- `nm .../iVim.debug.dylib | grep` shows which symbols are defined or
  imported (e.g. whether stubs or ios_system's functions are used).

## Simulator settings

- Keep I/O > Keyboard > Connect Hardware Keyboard **on**: off drops Mac
  keystrokes entirely. Cmd-K toggles the software keyboard.
- The simulator's region is `en_US@rg=nozzzz` (Norway), like the owner's
  phone; it matters for locale bugs ([guifont](fixes.md#guifont-sizes)).
- Set `com.apple.keyboard.preferences DidShowContinuousPathIntroduction`
  to true to skip the keyboard tutorial overlay.
- The owner's config is installed with its `INSTALL` script, `HOME`
  pointed at the app's Documents ([user-setup](user-setup.md)).
