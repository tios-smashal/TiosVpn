#!/bin/bash
#
# Create app icon from an image file
# Usage: ./create-icon.sh your-image.png
#

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <image-file>"
    echo
    echo "Converts an image (PNG, JPG, etc.) to macOS app icon (.icns)"
    echo "The image should be at least 1024x1024 pixels for best results"
    echo
    echo "Example:"
    echo "  ./create-icon.sh company-logo.png"
    exit 1
fi

IMAGE_FILE="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$IMAGE_FILE" ]; then
    echo "Error: Image file not found: $IMAGE_FILE"
    exit 1
fi

echo "Creating app icon from $IMAGE_FILE..."
echo

# Create temporary iconset directory
ICONSET_DIR="$SCRIPT_DIR/TiosVPN.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# Generate all required icon sizes
sips -z 16 16     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$IMAGE_FILE" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null

echo "✓ Generated all icon sizes"

# Convert iconset to icns
iconutil -c icns "$ICONSET_DIR" -o "$SCRIPT_DIR/TiosVPN.icns"
echo "✓ Created TiosVPN.icns"

# Copy to app bundle
cp "$SCRIPT_DIR/TiosVPN.icns" "$SCRIPT_DIR/TiosVPN.app/Contents/Resources/"
echo "✓ Copied icon to app bundle"

# Cleanup
rm -rf "$ICONSET_DIR"

echo
echo "========================================="
echo "           Icon Created! ✓"
echo "========================================="
echo
echo "The icon has been added to TiosVPN.app"
echo "Rebuild the .pkg to include the new icon:"
echo "  ./build-pkg.sh"
echo
