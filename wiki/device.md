---
updated: 2026-09-27
---
# The iPhone and devicectl

    xcrun devicectl list devices
    xcrun devicectl device install app --device <id> <dir>/Build/Products/Debug-iphoneos/iVim.app
    xcrun devicectl device process launch --device <id> --terminate-existing io.github.sysprv.ivim
    xcrun devicectl device info files --device <id> --domain-type appDataContainer \
      --domain-identifier io.github.sysprv.ivim [--json-output f.json]

- Launch fails with "Locked" while the phone is locked: ask the user to
  open the app.
- After the app is deleted, iOS drops trust in the developer certificate
  (when it was the last app from that developer): Settings > General > VPN &
  Device Management > Trust. Launch fails with "Security" until then.
- Xcode 26.0 installs fine on iOS 27.
- `info files --json-output` shows owner uid/gid and mode per file
  (read-only, safe).
- Now that builds come from [TestFlight](release-testflight.md), direct
  installs are for testing only.

## Copying files to the phone: pitfalls

There is no remove command, so mistakes can't be undone. Ask the user
before any `devicectl device copy to`. Learned the hard way:

- With a single `--source`, `--destination Documents/` is taken as the
  target *file name*: it replaced the whole Documents folder with the file.
- A directory given as a source becomes **owned by root** on the device
  (its contents are owned by the app, uid 501). The app can read it but
  can't create anything in it: vim's `mkdir()` fails with E739, undo files
  with E828. Copy files only, into directories the app created, or let the
  user copy via Files / Working Copy.
- `--remove-existing-content true` wipes the **whole domain** (all of the
  app's container), not just the destination folder — confirmed in the
  `temporary` domain. Never use it on the app container.
- A root-owned directory can be renamed from inside the app (rename needs
  write access to the parent only) but not emptied or deleted; only
  reinstalling the app removes it. The phone currently has such a leftover,
  `~/dotvim-root`.

Reading from the phone is safe: `devicectl device copy from ... --source
Documents/<file> --destination <local>`.
