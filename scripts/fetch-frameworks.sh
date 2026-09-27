#!/bin/sh
#
# Fetch and build the frameworks for iVim's external commands, :terminal
# and the ivish shell, into Frameworks/ (not committed):
#
# - ios_system and its command frameworks, from the upstream releases at
#   https://github.com/holzschu/ios_system
# - ivish, built from https://github.com/terrychou/ivish with
#   ivish-upstream-ios_system.patch applied (the original was built
#   against an unpublished, modified ios_system)
#
# Without Frameworks/, iVim builds as "lite": no external commands.
#
# Needs: Xcode, git, curl, unzip.  Usage: scripts/fetch-frameworks.sh

set -eu

IOS_SYSTEM_VERSION=v3.0.6
IOS_SYSTEM_FRAMEWORKS="ios_system files shell text tar awk"
IVISH_REPO=https://github.com/terrychou/ivish.git
IVISH_COMMIT=5647a86

cd "$(dirname "$0")/.."
ROOT=$(pwd)
FW="$ROOT/Frameworks"
WORK="$ROOT/build/deps"
RELEASES="https://github.com/holzschu/ios_system/releases/download/$IOS_SYSTEM_VERSION"

mkdir -p "$FW" "$WORK" "$ROOT/Resources"

echo "== ios_system $IOS_SYSTEM_VERSION"
# the version is pinned: reuse downloads, fetch missing ones in parallel
for f in $IOS_SYSTEM_FRAMEWORKS; do
    zip="$WORK/$IOS_SYSTEM_VERSION-$f.xcframework.zip"
    if [ ! -f "$zip" ]; then
        { curl -fsSL -o "$zip.part" "$RELEASES/$f.xcframework.zip" &&
            mv "$zip.part" "$zip"; } &
    fi
done
wait    # a failed download shows up as a missing zip below
for f in $IOS_SYSTEM_FRAMEWORKS; do
    rm -rf "$FW/$f.xcframework"
    unzip -q "$WORK/$IOS_SYSTEM_VERSION-$f.xcframework.zip" -d "$FW"
    echo "   $f.xcframework"
done
curl -fsSL -o "$ROOT/Resources/commandDictionary.plist" \
    "$RELEASES/commandDictionary.plist"

echo "== ivish $IVISH_COMMIT"
PATCH="$ROOT/scripts/ivish-upstream-ios_system.patch"
STAMP="$IVISH_COMMIT $(shasum "$PATCH" | cut -d' ' -f1)"
if [ -d "$FW/ivish.xcframework" ] &&
    [ "$(cat "$WORK/ivish.stamp" 2>/dev/null)" = "$STAMP" ]; then
    echo "   ivish.xcframework (up to date)"
    echo "done: $FW"
    exit 0
fi
[ -d "$WORK/ivish" ] || git clone -q "$IVISH_REPO" "$WORK/ivish"
git -C "$WORK/ivish" checkout -q -f "$IVISH_COMMIT"
git -C "$WORK/ivish" apply "$PATCH"
# the ivish project expects ../frameworks/ios_system.xcframework
mkdir -p "$WORK/frameworks"
rm -rf "$WORK/frameworks/ios_system.xcframework"
ln -s "$FW/ios_system.xcframework" "$WORK/frameworks/"

args=""
for sdk in iphoneos iphonesimulator; do
    xcodebuild -quiet -project "$WORK/ivish/ivish.xcodeproj" \
        -scheme ivish -configuration Release -sdk "$sdk" \
        -derivedDataPath "$WORK/ivish-dd" \
        CODE_SIGNING_ALLOWED=NO DEVELOPMENT_TEAM= \
        IPHONEOS_DEPLOYMENT_TARGET=15.0 SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        build
    args="$args -framework $WORK/ivish-dd/Build/Products/Release-$sdk/ivish.framework"
done
rm -rf "$FW/ivish.xcframework"
# shellcheck disable=SC2086
xcodebuild -create-xcframework $args -output "$FW/ivish.xcframework" >/dev/null
echo "$STAMP" > "$WORK/ivish.stamp"
echo "   ivish.xcframework"

echo "done: $FW"
