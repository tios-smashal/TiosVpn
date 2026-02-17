#!/bin/bash
#
# TiosVPN Uninstaller
# Removes TiosVPN app, CLI tools, credentials, and configuration
#

set -e

echo "========================================="
echo "       TiosVPN Uninstaller"
echo "========================================="
echo

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script with sudo."
    echo "The script will ask for sudo password when needed."
    exit 1
fi

# Confirm uninstallation
read -p "Are you sure you want to uninstall TiosVPN? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo
echo "Uninstalling TiosVPN..."
echo

# 1. Disconnect VPN if connected
echo "1. Checking VPN connection..."
if pgrep -f "openvpn.*client-config.ovpn" >/dev/null 2>&1; then
    echo "   Disconnecting VPN..."
    sudo pkill -f "openvpn.*client-config.ovpn" 2>/dev/null || true
    sleep 1
    echo "   ✓ VPN disconnected"
else
    echo "   ✓ VPN not connected"
fi

# 2. Remove application
echo "2. Removing application..."
if [ -d "/Applications/TiosVPN.app" ]; then
    rm -rf "/Applications/TiosVPN.app"
    echo "   ✓ Removed /Applications/TiosVPN.app"
else
    echo "   ℹ  Application not found in /Applications/"
fi

# 3. Remove CLI tools
echo "3. Removing CLI tools..."
if [ -f "/usr/local/bin/tiosvpn" ]; then
    sudo rm -f /usr/local/bin/tiosvpn
    echo "   ✓ Removed /usr/local/bin/tiosvpn"
else
    echo "   ℹ  tiosvpn not found"
fi

if [ -f "/usr/local/bin/vpn-manager.sh" ]; then
    sudo rm -f /usr/local/bin/vpn-manager.sh
    echo "   ✓ Removed /usr/local/bin/vpn-manager.sh"
else
    echo "   ℹ  vpn-manager.sh not found"
fi

# 4. Remove credentials from Keychain
echo "4. Removing credentials from Keychain..."
CREDS_REMOVED=false

if security find-generic-password -s TiosVPN -a vpn-username >/dev/null 2>&1; then
    security delete-generic-password -s TiosVPN -a vpn-username 2>/dev/null
    CREDS_REMOVED=true
fi

if security find-generic-password -s TiosVPN -a vpn-password >/dev/null 2>&1; then
    security delete-generic-password -s TiosVPN -a vpn-password 2>/dev/null
    CREDS_REMOVED=true
fi

if [ "$CREDS_REMOVED" = true ]; then
    echo "   ✓ Removed credentials from Keychain"
else
    echo "   ℹ  No credentials found in Keychain"
fi

# 5. Remove configuration files
echo "5. Removing configuration files..."
if [ -d "$HOME/Library/Application Support/TiosVPN" ]; then
    rm -rf "$HOME/Library/Application Support/TiosVPN"
    echo "   ✓ Removed configuration directory"
else
    echo "   ℹ  No configuration directory found"
fi

# 6. Remove any leftover files
echo "6. Cleaning up..."

# Remove from Downloads if present
if [ -f "$HOME/Downloads/TiosVPN-*.pkg" ]; then
    rm -f "$HOME/Downloads/TiosVPN-*.pkg"
    echo "   ✓ Removed installer from Downloads"
fi

echo

echo "========================================="
echo "     Uninstall Complete! ✓"
echo "========================================="
echo
echo "TiosVPN has been completely removed from your system."
echo
echo "The following were removed:"
echo "  • Application from /Applications/"
echo "  • CLI tools from /usr/local/bin/"
echo "  • Credentials from macOS Keychain"
echo "  • Configuration files"
echo
echo "Note: OpenVPN was NOT removed. To remove it:"
echo "  brew uninstall openvpn"
echo
