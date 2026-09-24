#!/bin/bash
set -e

# FineTune DMG Build Script
# Requires: Xcode, Node.js 18+, GraphicsMagick, ImageMagick
# Install dependencies: brew install graphicsmagick imagemagick

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

echo "==> Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

SIGNING_IDENTITY="${FINETUNE_SIGNING_IDENTITY:-}"
if [[ -z "$SIGNING_IDENTITY" ]]; then
    SIGNING_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null \
        | sed -n 's/.*"\(Developer ID Application: [^"]*\)".*/\1/p' | head -1)"
fi
if [[ -z "$SIGNING_IDENTITY" ]]; then
    SIGNING_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null \
        | sed -n 's/.*"\([^"]*\)".*/\1/p' | head -1)"
fi
if [[ -z "$SIGNING_IDENTITY" ]]; then
    echo "No stable signing identity found. Set FINETUNE_SIGNING_IDENTITY or install a Developer ID certificate." >&2
    exit 1
fi

echo "==> Building release archive with stable identity: $SIGNING_IDENTITY"
xcodebuild -project "$PROJECT_DIR/FineTune.xcodeproj" \
    -scheme FineTune \
    -configuration Release \
    -archivePath "$BUILD_DIR/FineTune.xcarchive" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
    DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-}" \
    archive

if [[ "$SIGNING_IDENTITY" == Developer\ ID\ Application:* && -n "${DEVELOPMENT_TEAM:-}" ]]; then
    echo "==> Exporting signed app..."
    xcodebuild -exportArchive \
        -archivePath "$BUILD_DIR/FineTune.xcarchive" \
        -exportPath "$BUILD_DIR" \
        -exportOptionsPlist "$PROJECT_DIR/ExportOptions.plist"
else
    echo "==> Copying locally signed archive product..."
    cp -R "$BUILD_DIR/FineTune.xcarchive/Products/Applications/FineTune.app" "$BUILD_DIR/FineTune.app"
fi

echo "==> Creating DMG..."
# create-dmg auto-generates professional layout with:
# - App icon composited onto disk icon
# - "Drag to Applications" layout
# - Code signing
npx create-dmg "$BUILD_DIR/FineTune.app" "$BUILD_DIR" --overwrite

echo "==> Done!"
echo "DMG created at: $BUILD_DIR/"
ls -la "$BUILD_DIR"/*.dmg
