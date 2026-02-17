#!/bin/bash
#
# TiosVPN Installer
# Installs TiosVPN.app to Applications folder and optionally installs CLI tool
#

set -e

echo "========================================="
echo "       TiosVPN Installer"
echo "========================================="
echo

# Check if OpenVPN is installed
if ! command -v openvpn &> /dev/null; then
    echo "⚠️  OpenVPN is not installed"
    echo
    echo "Please install OpenVPN first:"
    echo "  brew install openvpn"
    echo
    read -p "Do you want to install it now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! command -v brew &> /dev/null; then
            echo "✗ Homebrew is not installed"
            echo "Please install Homebrew first: https://brew.sh"
            exit 1
        fi
        echo "Installing OpenVPN..."
        brew install openvpn
    else
        echo "Please install OpenVPN and run this installer again"
        exit 1
    fi
fi

echo "✓ OpenVPN is installed"
echo

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if TiosVPN.app exists
if [ ! -d "$SCRIPT_DIR/TiosVPN.app" ]; then
    echo "✗ Error: TiosVPN.app not found in current directory"
    echo "Please run this script from the tiosvpn directory"
    exit 1
fi

# Install GUI app
echo "Installing TiosVPN.app..."

# Remove existing installation if present
if [ -d "/Applications/TiosVPN.app" ]; then
    echo "Removing existing installation..."
    rm -rf "/Applications/TiosVPN.app"
fi

# Copy to Applications
cp -R "$SCRIPT_DIR/TiosVPN.app" /Applications/
echo "✓ TiosVPN.app installed to /Applications/"
echo

# Ask about CLI tool
read -p "Do you want to install the command-line tool 'tiosvpn'? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "$SCRIPT_DIR/tiosvpn" ]; then
        sudo cp "$SCRIPT_DIR/tiosvpn" /usr/local/bin/
        sudo cp "$SCRIPT_DIR/vpn-manager.sh" /usr/local/bin/
        sudo chmod +x /usr/local/bin/tiosvpn /usr/local/bin/vpn-manager.sh
        echo "✓ CLI tool 'tiosvpn' installed to /usr/local/bin/"
        echo
        echo "You can now use 'tiosvpn' from anywhere in the terminal"
    else
        echo "✗ tiosvpn CLI tool not found"
    fi
fi

echo
echo "========================================="
echo "       Installation Complete! ✓"
echo "========================================="
echo
echo "To get started:"
echo "  1. Open TiosVPN from your Applications folder"
echo "  2. Enter your VPN credentials (one-time setup)"
echo "  3. Enter your MFA code and connect"
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Command-line usage:"
    echo "  tiosvpn setup       # Configure credentials"
    echo "  tiosvpn connect     # Connect to VPN"
    echo "  tiosvpn disconnect  # Disconnect from VPN"
    echo "  tiosvpn status      # Check status"
    echo
fi

# Ask if user wants to open the app now
read -p "Would you like to open TiosVPN now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open /Applications/TiosVPN.app
fi

echo
echo "Done! 🎉"
