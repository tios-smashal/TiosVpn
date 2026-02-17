#!/bin/bash
#
# Add images to installer package
# Usage: ./add-installer-images.sh logo.png [background.png]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <logo-image> [background-image]"
    echo
    echo "Adds custom images to the installer package:"
    echo "  - Logo image: Shown in welcome/conclusion pages"
    echo "  - Background (optional): Installer window background"
    echo
    echo "Example:"
    echo "  ./add-installer-images.sh company-logo.png"
    echo "  ./add-installer-images.sh company-logo.png background.png"
    exit 1
fi

LOGO_FILE="$1"
BACKGROUND_FILE="${2:-}"

if [ ! -f "$LOGO_FILE" ]; then
    echo "Error: Logo file not found: $LOGO_FILE"
    exit 1
fi

echo "Adding images to installer package..."
echo

# Create resources directory
mkdir -p "$SCRIPT_DIR/installer-resources"

# Copy and resize logo
echo "Processing logo image..."
sips -Z 200 "$LOGO_FILE" --out "$SCRIPT_DIR/installer-resources/logo.png" >/dev/null
echo "✓ Logo prepared (200px max)"

# Copy background if provided
if [ -n "$BACKGROUND_FILE" ] && [ -f "$BACKGROUND_FILE" ]; then
    echo "Processing background image..."
    cp "$BACKGROUND_FILE" "$SCRIPT_DIR/installer-resources/background.png"
    echo "✓ Background prepared"
fi

# Update build-pkg.sh to include images in HTML
echo "Updating installer HTML templates..."

# Update the build-pkg.sh to include the logo
cat > "$SCRIPT_DIR/build-pkg-with-images.sh" << 'BUILDSCRIPT'
#!/bin/bash
#
# Build macOS installer package (.pkg) for TiosVPN with custom images
#

set -e

echo "========================================="
echo "    Building TiosVPN Installer Package"
echo "========================================="
echo

# Configuration
APP_NAME="TiosVPN"
VERSION="1.0"
IDENTIFIER="com.tios.vpn"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directories
BUILD_DIR="$SCRIPT_DIR/build"
PAYLOAD_DIR="$BUILD_DIR/payload"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
RESOURCES_DIR="$BUILD_DIR/resources"
OUTPUT_PKG="$SCRIPT_DIR/TiosVPN-${VERSION}.pkg"

# Clean previous build
echo "Cleaning previous build..."
rm -rf "$BUILD_DIR"
rm -f "$OUTPUT_PKG"
mkdir -p "$PAYLOAD_DIR/Applications"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy app to payload
echo "Preparing payload..."
cp -R "$SCRIPT_DIR/TiosVPN.app" "$PAYLOAD_DIR/Applications/"

# Include CLI tools
cp "$SCRIPT_DIR/tiosvpn" "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/Resources/"
cp "$SCRIPT_DIR/vpn-manager.sh" "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/Resources/"

# Ensure permissions
chmod +x "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/MacOS/TiosVPN"
chmod +x "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/Resources/"*.sh
chmod +x "$PAYLOAD_DIR/Applications/TiosVPN.app/Contents/Resources/tiosvpn"

echo "✓ Payload prepared"

# Copy custom images if they exist
if [ -f "$SCRIPT_DIR/installer-resources/logo.png" ]; then
    cp "$SCRIPT_DIR/installer-resources/logo.png" "$RESOURCES_DIR/"
    echo "✓ Custom logo included"
    LOGO_TAG='<div style="text-align: center;"><img src="logo.png" alt="TiosVPN Logo" style="max-width: 200px; margin: 20px 0;"></div>'
else
    LOGO_TAG=''
fi

if [ -f "$SCRIPT_DIR/installer-resources/background.png" ]; then
    cp "$SCRIPT_DIR/installer-resources/background.png" "$RESOURCES_DIR/"
    echo "✓ Custom background included"
fi

# Build component package
echo "Building component package..."
pkgbuild \
    --root "$PAYLOAD_DIR" \
    --identifier "$IDENTIFIER" \
    --version "$VERSION" \
    --install-location "/" \
    --scripts "$SCRIPTS_DIR" \
    "$BUILD_DIR/TiosVPN-component.pkg"

echo "✓ Component package created"

# Create distribution XML
echo "Creating distribution definition..."
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

# Create welcome page with logo
cat > "$RESOURCES_DIR/welcome.html" << HTMLEOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            padding: 20px;
        }
        h1 { color: #007AFF; }
        .logo-container { text-align: center; margin: 20px 0; }
        .logo-container img { max-width: 200px; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    $LOGO_TAG
    <h1>Welcome to TiosVPN</h1>
    <p>This installer will install TiosVPN on your Mac.</p>

    <h3>What is TiosVPN?</h3>
    <p>TiosVPN is an easy-to-use VPN client for connecting to your company's VPN with MFA support.</p>

    <h3>Before You Begin:</h3>
    <p><strong>OpenVPN Required:</strong> Make sure you have OpenVPN installed.</p>
    <p>If not installed, run this command in Terminal:</p>
    <pre>brew install openvpn</pre>

    <h3>What Will Be Installed:</h3>
    <ul>
        <li>TiosVPN.app in your Applications folder</li>
        <li>Command-line tool: <code>tiosvpn</code> (optional)</li>
    </ul>

    <p>Click Continue to proceed with the installation.</p>
</body>
</html>
HTMLEOF

# Create conclusion page with logo
cat > "$RESOURCES_DIR/conclusion.html" << HTMLEOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            padding: 20px;
        }
        h1 { color: #34C759; }
        .logo-container { text-align: center; margin: 20px 0; }
        .logo-container img { max-width: 200px; }
        .next-steps { background: #f5f5f5; padding: 15px; border-radius: 8px; margin: 15px 0; }
        pre { background: #e8e8e8; padding: 10px; border-radius: 5px; font-size: 12px; }
    </style>
</head>
<body>
    $LOGO_TAG
    <h1>✓ Installation Complete!</h1>
    <p>TiosVPN has been successfully installed.</p>

    <div class="next-steps">
        <h3>Next Steps:</h3>
        <ol>
            <li><strong>Verify OpenVPN is installed:</strong>
                <pre>brew install openvpn</pre>
            </li>
            <li><strong>Launch TiosVPN:</strong>
                <ul>
                    <li>Open from Applications folder, or</li>
                    <li>Use Spotlight (⌘ + Space) and type "TiosVPN"</li>
                </ul>
            </li>
            <li><strong>First-time setup:</strong>
                <ul>
                    <li>Enter your VPN username and password</li>
                    <li>Credentials are securely stored in macOS Keychain</li>
                </ul>
            </li>
            <li><strong>Connect:</strong>
                <ul>
                    <li>Enter your 6-digit MFA code</li>
                    <li>Click Connect</li>
                </ul>
            </li>
        </ol>
    </div>

    <h3>Command-Line Usage (Optional):</h3>
    <pre>tiosvpn setup       # Configure credentials
tiosvpn connect     # Connect to VPN
tiosvpn disconnect  # Disconnect
tiosvpn status      # Check status</pre>

    <p><strong>Need Help?</strong> Contact your IT department.</p>
</body>
</html>
HTMLEOF

echo "✓ HTML pages created with images"

# Build final product package
echo "Building final installer package..."
productbuild \
    --distribution "$BUILD_DIR/distribution.xml" \
    --package-path "$BUILD_DIR" \
    --resources "$RESOURCES_DIR" \
    "$OUTPUT_PKG"

echo "✓ Package built successfully"

# Get package size
PKG_SIZE=$(du -h "$OUTPUT_PKG" | cut -f1)

echo "========================================="
echo "           Build Complete! ✓"
echo "========================================="
echo
echo "Installer package created:"
echo "  Location: $OUTPUT_PKG"
echo "  Size: $PKG_SIZE"
echo
echo "To test the installer:"
echo "  open $OUTPUT_PKG"
echo
echo "Done! 🎉"
BUILDSCRIPT

chmod +x "$SCRIPT_DIR/build-pkg-with-images.sh"

echo
echo "========================================="
echo "           Setup Complete! ✓"
echo "========================================="
echo
echo "Images have been prepared for the installer."
echo
echo "To build the package with images:"
echo "  ./build-pkg-with-images.sh"
echo
echo "Files created:"
echo "  - installer-resources/logo.png"
if [ -n "$BACKGROUND_FILE" ] && [ -f "$BACKGROUND_FILE" ]; then
    echo "  - installer-resources/background.png"
fi
echo "  - build-pkg-with-images.sh"
echo
