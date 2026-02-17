#!/bin/bash
#
# Build TiosVPN Installer - Automatic build with branding
# Automatically detects and uses TiosVpn.png if present
#

set -e

echo "========================================="
echo "    Building TiosVPN Installer Package"
echo "========================================="
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGO_FILE="$SCRIPT_DIR/TiosVpn.png"

# Check if logo exists and auto-configure
if [ -f "$LOGO_FILE" ]; then
    echo "✓ Found TiosVpn.png - adding branding..."
    echo

    # Create app icon
    echo "Creating app icon..."
    mkdir -p "$SCRIPT_DIR/TiosVPN.iconset"
    sips -z 16 16     "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_16x16.png" >/dev/null
    sips -z 32 32     "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_16x16@2x.png" >/dev/null
    sips -z 32 32     "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_32x32.png" >/dev/null
    sips -z 64 64     "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_32x32@2x.png" >/dev/null
    sips -z 128 128   "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_128x128.png" >/dev/null
    sips -z 256 256   "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_128x128@2x.png" >/dev/null
    sips -z 256 256   "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_256x256.png" >/dev/null
    sips -z 512 512   "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_256x256@2x.png" >/dev/null
    sips -z 512 512   "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_512x512.png" >/dev/null
    sips -z 1024 1024 "$LOGO_FILE" --out "$SCRIPT_DIR/TiosVPN.iconset/icon_512x512@2x.png" >/dev/null

    iconutil -c icns "$SCRIPT_DIR/TiosVPN.iconset" -o "$SCRIPT_DIR/TiosVPN.icns"
    cp "$SCRIPT_DIR/TiosVPN.icns" "$SCRIPT_DIR/TiosVPN.app/Contents/Resources/"
    rm -rf "$SCRIPT_DIR/TiosVPN.iconset"
    echo "  ✓ App icon created"

    # Prepare installer logo
    mkdir -p "$SCRIPT_DIR/installer-resources"
    sips -Z 200 "$LOGO_FILE" --out "$SCRIPT_DIR/installer-resources/logo.png" >/dev/null
    echo "  ✓ Installer logo prepared"

    USE_BRANDING=true
else
    echo "ℹ  No TiosVpn.png found - building without branding"
    echo "  (Add TiosVpn.png to current directory for branded version)"
    echo
    USE_BRANDING=false
fi

# Configuration
APP_NAME="TiosVPN"
VERSION="1.0"
IDENTIFIER="com.tios.vpn"

# Directories
BUILD_DIR="$SCRIPT_DIR/build"
PAYLOAD_DIR="$BUILD_DIR/payload"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
RESOURCES_DIR="$BUILD_DIR/resources"
OUTPUT_PKG="$SCRIPT_DIR/TiosVPN-${VERSION}.pkg"

# Clean previous build
echo "Preparing build..."
rm -rf "$BUILD_DIR"
rm -f "$OUTPUT_PKG"
mkdir -p "$PAYLOAD_DIR/Applications"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy app to payload
cp -R "$SCRIPT_DIR/TiosVPN.app" "$PAYLOAD_DIR/Applications/"

# Include CLI tools
cp "$SCRIPT_DIR/tiosvpn" "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/Resources/"
cp "$SCRIPT_DIR/vpn-manager.sh" "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/Resources/"

# Ensure permissions
chmod +x "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/MacOS/TiosVPN"
chmod +x "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/Resources/"*.sh
chmod +x "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/Resources/tiosvpn"

echo "✓ Payload prepared"

# Copy branding if available
if [ "$USE_BRANDING" = true ]; then
    cp "$SCRIPT_DIR/installer-resources/logo.png" "$RESOURCES_DIR/"
    LOGO_TAG='<div style="text-align: center; margin: 20px 0;"><img src="logo.png" alt="TiosVPN" style="max-width: 200px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"></div>'
else
    LOGO_TAG=''
fi

# Copy postinstall script
if [ ! -f "$SCRIPTS_DIR/postinstall" ]; then
    cat > "$SCRIPTS_DIR/postinstall" << 'POSTINSTALL'
#!/bin/bash
echo "Running TiosVPN post-installation..."
chmod +x /Applications/TiosVPN.app/Contents/MacOS/TiosVPN
chmod +x /Applications/TiosVPN.app/Contents/Resources/TiosVPN-GUI.sh
chmod +x /Applications/TiosVPN.app/Contents/Resources/vpn-manager.sh
if [ -f "/Applications/TiosVPN.app/Contents/Resources/tiosvpn" ]; then
    cp /Applications/TiosVPN.app/Contents/Resources/tiosvpn /usr/local/bin/tiosvpn 2>/dev/null || true
    cp /Applications/TiosVPN.app/Contents/Resources/vpn-manager.sh /usr/local/bin/vpn-manager.sh 2>/dev/null || true
    chmod +x /usr/local/bin/tiosvpn /usr/local/bin/vpn-manager.sh 2>/dev/null || true
fi
echo "TiosVPN installation complete!"
exit 0
POSTINSTALL
    chmod +x "$SCRIPTS_DIR/postinstall"
fi

# Build component package
echo "Building component package..."
pkgbuild \
    --root "$PAYLOAD_DIR" \
    --identifier "$IDENTIFIER" \
    --version "$VERSION" \
    --install-location "/" \
    --scripts "$SCRIPTS_DIR" \
    "$BUILD_DIR/TiosVPN-component.pkg" >/dev/null

echo "✓ Component package created"

# Create distribution XML
cat > "$BUILD_DIR/distribution.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
    <title>TiosVPN</title>
    <organization>com.tios</organization>
    <domains enable_localSystem="true"/>
    <options customize="never" require-scripts="false" hostArchitectures="x86_64,arm64"/>
    <welcome file="welcome.html"/>
    <conclusion file="conclusion.html"/>
    <pkg-ref id="$IDENTIFIER">
        <bundle-version>
            <bundle id="$IDENTIFIER"/>
        </bundle-version>
    </pkg-ref>
    <options customize="never" require-scripts="true"/>
    <choices-outline>
        <line choice="default">
            <line choice="$IDENTIFIER"/>
        </line>
    </choices-outline>
    <choice id="default"/>
    <choice id="$IDENTIFIER" visible="false">
        <pkg-ref id="$IDENTIFIER"/>
    </choice>
    <pkg-ref id="$IDENTIFIER" version="$VERSION" onConclusion="none">TiosVPN-component.pkg</pkg-ref>
</installer-gui-script>
EOF

# Create welcome page
cat "$SCRIPT_DIR/installer-welcome.html" | sed "s|LOGO_PLACEHOLDER|$LOGO_TAG|g" > "$RESOURCES_DIR/welcome.html"

# Create conclusion page
cat "$SCRIPT_DIR/installer-conclusion.html" | sed "s|LOGO_PLACEHOLDER|$LOGO_TAG|g" > "$RESOURCES_DIR/conclusion.html"

# Build final product package
echo "Building final installer package..."
productbuild \
    --distribution "$BUILD_DIR/distribution.xml" \
    --package-path "$BUILD_DIR" \
    --resources "$RESOURCES_DIR" \
    "$OUTPUT_PKG" >/dev/null

echo "✓ Package built successfully"

# Get package size
PKG_SIZE=$(du -h "$OUTPUT_PKG" | cut -f1)

echo
echo "========================================="
echo "           Build Complete! ✓"
echo "========================================="
echo
echo "Installer package: $OUTPUT_PKG"
echo "Size: $PKG_SIZE"
if [ "$USE_BRANDING" = true ]; then
    echo "Branding: ✓ Custom logo included"
else
    echo "Branding: Default (add TiosVpn.png for custom logo)"
fi
echo
echo "Test the installer:"
echo "  open $OUTPUT_PKG"
echo
echo "Distribute to employees:"
echo "  Share TiosVPN-1.0.pkg"
echo
echo "Done! 🎉"
