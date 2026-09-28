---
updated: 2026-09-28
---
# Release via TestFlight

App Store Connect app "iVim sysprv fork", bundle id `io.github.sysprv.ivim`,
team B9Y5MBFAT8 (see [overview](overview.md)). Version 2.15.

## Steps

1. Raise `CURRENT_PROJECT_VERSION` in `iVim.xcodeproj/project.pbxproj`
   (all four entries: app and share extension, Debug and Release must
   match). Each upload needs a higher build number.
2. Archive:

       xcodebuild -project iVim.xcodeproj -scheme iVim -configuration Release \
         -destination 'generic/platform=iOS' -archivePath <dir>/iVim.xcarchive \
         -allowProvisioningUpdates archive

3. Upload:

       xcodebuild -exportArchive -archivePath <dir>/iVim.xcarchive \
         -exportOptionsPlist <opts> -exportPath <dir>/upload -allowProvisioningUpdates

   `<opts>`: plist with `method` = `app-store-connect`, `destination` =
   `upload` (or `export` to write an .ipa), `teamID` = B9Y5MBFAT8,
   `signingStyle` = `automatic`, `manageAppVersionAndBuildNumber` = false.
4. Processing takes 5–30 min; the owner adds the build to the internal
   testing group if it isn't added automatically, and installs from the
   TestFlight app. TestFlight builds last 90 days.

## Notes

- Signing uses a cloud-managed Apple Distribution certificate (nothing in
  the local keychain); that's normal.
- "Upload Symbols Failed … no dSYM for ivish.framework": harmless (only
  crash symbolication). Fix would be building ivish with dSYMs in
  `fetch-frameworks.sh` and passing them to `-create-xcframework`.
- App Store Connect raises the minimum SDK every spring; Xcode 26 is
  accepted for now, a newer Xcode (and macOS) will eventually be needed.
- The share extension is still built and shows in share sheets but can't
  work without an App Group; removing it is an open option.

## History

- Build 1: first upload. Build 2: [guifont fix](fixes.md#guifont-sizes),
  verified on the phone.
- Build 3 (2026-09-28, branch `vim9-rebase`): vim 9.2.1135
  ([vim-upgrade](vim-upgrade.md)); verified on the phone.
