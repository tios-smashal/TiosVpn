# TiosVPN - Easy OpenVPN Connection for macOS

A simple macOS application to connect to your company VPN with MFA support.

## Features

- ✅ Native macOS app (double-click to launch)
- 🔐 Secure credential storage in macOS Keychain
- 🔢 MFA code support
- 💻 Command-line interface available
- 🎯 One-time setup, easy to use
- 🚀 No dependencies (uses built-in macOS tools)
- 🎨 Custom branding support (add your company logo)

## Installation

### For Employees (Simple Installation)

1. **Download and install TiosVPN**:
   - Double-click `TiosVPN-1.0.pkg`
   - Click "Continue" and follow the installer
   - OpenVPN will be installed automatically (if Homebrew is available)

2. **Launch TiosVPN**:
   - Open from Applications folder, or
   - Press ⌘+Space and type "TiosVPN"

3. **First-time setup**:
   - Enter your VPN username and password
   - Click "Save Credentials" (stored securely in macOS Keychain)

4. **Connect to VPN**:
   - Enter your 6-digit MFA code
   - Click "Connect"

**That's it!** The installer handles everything automatically.

### For IT Admins (Building Installer Package)

Build a professional `.pkg` installer for easy distribution with **one simple command**:

#### Recommended: Build with Your Company Logo

```bash
# 1. Place your logo in the directory (rename to TiosVpn.png)
# 2. Build the installer
./build-installer.sh
```

**That's it!** The script automatically:
- ✅ Detects `TiosVpn.png` in the current directory
- ✅ Creates app icon from your logo
- ✅ Adds logo to installer welcome/completion screens
- ✅ Builds the complete `TiosVPN-1.0.pkg` package

**Logo Requirements:**
- File name: `TiosVpn.png` (must be in current directory)
- Format: PNG (transparent background recommended)
- Recommended size: 1024x1024 pixels
- Will be automatically resized for all uses

#### Without Custom Branding

If you don't have a logo or want a basic version:

```bash
# Just build without TiosVpn.png in directory
./build-installer.sh
```

This creates a basic `TiosVPN-1.0.pkg` without custom branding.

#### Manual Installation (Development/Testing)

For local testing without building a package:

```bash
./install.sh
```

## Usage

### GUI Application

**Double-click `TiosVPN.app`** to launch the GUI.

- **First time**: Enter username/password (stored securely in Keychain)
- **Connect**: Enter your 6-digit MFA code and click Connect
- **Disconnect**: Click Disconnect when connected
- **Settings**: Update or delete credentials

### Command-Line Interface

```bash
# Install CLI tool (optional)
sudo cp tiosvpn /usr/local/bin/

# First-time setup
tiosvpn setup

# Connect to VPN
tiosvpn connect

# Check status
tiosvpn status

# Disconnect
tiosvpn disconnect

# Update VPN config
tiosvpn update-config

# Help
tiosvpn help
```

## Requirements

- macOS 10.13 or later
- Homebrew (recommended - for automatic OpenVPN installation)

**Note:** The `.pkg` installer automatically installs OpenVPN if Homebrew is present. If not, users will be prompted to install Homebrew first.

## How It Works

1. **Credentials**: Stored securely in macOS Keychain using the `security` command
2. **VPN Config**: Automatically downloaded from S3 on first connection
3. **MFA**: Uses `expect` (built into macOS) to handle the MFA challenge
4. **Connection**: Runs `sudo openvpn` with your credentials and MFA code

## Security

- ✅ Passwords encrypted in macOS Keychain (not stored in plain text)
- ✅ Temporary auth files are deleted after use
- ✅ MFA code required for each connection
- ✅ No credentials stored in files

## Troubleshooting

### "Command not found: openvpn"
The installer should have installed OpenVPN automatically. If you see this error:

1. Check if Homebrew is installed: `brew --version`
2. If not, install Homebrew from: https://brew.sh
3. Then install OpenVPN: `brew install openvpn`
4. Restart TiosVPN

### "Authentication failed"
- Check your username/password in Settings
- Verify your MFA code is correct (6 digits)
- Update credentials: Open app → Settings → Update Credentials

### "Cannot resolve host"
- Check your internet connection
- Try updating the VPN config: `tiosvpn update-config`

### App won't open
Make sure the app is executable:
```bash
chmod +x TiosVPN.app/Contents/MacOS/TiosVPN
```

## Uninstallation

To completely remove TiosVPN from your system:

### Quick Uninstall (Recommended)

```bash
# Download or locate uninstall.sh, then run:
./uninstall.sh
```

The uninstaller will:
- ✅ Disconnect active VPN connection
- ✅ Remove TiosVPN.app from Applications
- ✅ Remove CLI tools
- ✅ Delete credentials from Keychain
- ✅ Remove all configuration files

### Manual Uninstall

If you prefer to remove manually:

```bash
# 1. Disconnect VPN
sudo pkill -f "openvpn.*client-config.ovpn"

# 2. Remove application
rm -rf /Applications/TiosVPN.app

# 3. Remove CLI tools
sudo rm /usr/local/bin/tiosvpn /usr/local/bin/vpn-manager.sh

# 4. Remove credentials
security delete-generic-password -s TiosVPN -a vpn-username
security delete-generic-password -s TiosVPN -a vpn-password

# 5. Remove configuration
rm -rf ~/Library/Application\ Support/TiosVPN
```

**Note:** OpenVPN is not removed. To remove it separately:
```bash
brew uninstall openvpn
```

## Building and Distribution

### For IT Admins: Creating the Installer

#### Step 1: Add Your Company Logo (Recommended)

Place your company logo in the project directory:

```bash
# Your logo must be named: TiosVpn.png
# - Format: PNG (transparent background recommended)
# - Size: 1024x1024px recommended (will auto-resize)
# - Location: Same directory as build-installer.sh
```

#### Step 2: Build the Installer Package

```bash
# Single command builds everything automatically
./build-installer.sh
```

This command automatically:
1. Detects if `TiosVpn.png` exists
2. Creates app icon and installer images from it
3. Builds **TiosVPN-1.0.pkg** - a professional macOS installer

Output:
```
✓ Found TiosVpn.png - adding branding...
✓ App icon created
✓ Installer logo prepared
✓ Package built successfully

Installer package: TiosVPN-1.0.pkg
Branding: ✓ Custom logo included
```

#### Step 3: Test the Installer

```bash
# Test before distributing to employees
open TiosVPN-1.0.pkg
```

Verify:
- ✅ Your logo appears in welcome screen
- ✅ Your logo appears in completion screen
- ✅ App has custom icon after installation
- ✅ Installation completes successfully

#### Step 4: Distribute to Employees

**Option A: Simple File Share**
- Share `TiosVPN-1.0.pkg` via email, file server, S3, or company portal
- Employees double-click to install

**Option B: Complete Package with Instructions**

```bash
# Create distribution package
mkdir TiosVPN-Distribution
cp TiosVPN-1.0.pkg TiosVPN-Distribution/
cp README.md TiosVPN-Distribution/

# Create employee instructions
cat > TiosVPN-Distribution/INSTALL-INSTRUCTIONS.txt << 'EOF'
TiosVPN Installation - Quick Start

1. Install OpenVPN (one-time):
   - Open Terminal
   - Run: brew install openvpn
   - If you don't have Homebrew, install it first from: https://brew.sh

2. Install TiosVPN:
   - Double-click TiosVPN-1.0.pkg
   - Click "Continue" through the installer
   - Click "Install" (may require admin password)

3. Launch TiosVPN:
   - Open Applications folder
   - Double-click TiosVPN
   - Or use Spotlight: Press ⌘+Space, type "TiosVPN"

4. First-Time Setup:
   - Enter your VPN username
   - Enter your VPN password
   - Click "Save Credentials"
   - Your credentials are securely stored in macOS Keychain

5. Connect to VPN:
   - Enter your 6-digit MFA code
   - Click "Connect"
   - VPN connection will be established

Command-Line Usage (Optional):
   - tiosvpn setup      # Configure credentials
   - tiosvpn connect    # Connect to VPN
   - tiosvpn status     # Check connection status
   - tiosvpn disconnect # Disconnect from VPN

Need Help?
Contact IT Support at: support@yourcompany.com
EOF

# Package everything
zip -r TiosVPN-Distribution.zip TiosVPN-Distribution/
```

Now distribute `TiosVPN-Distribution.zip` to your employees.

### Employee Installation Instructions

Send these simple instructions to employees:

```
1. Double-click TiosVPN-1.0.pkg

2. Follow the installation wizard (OpenVPN installs automatically)

3. Launch TiosVPN from Applications (or ⌘+Space → "TiosVPN")

4. Enter your credentials (one-time setup)

5. Enter MFA code and connect

Done!
```

**Note:** If the employee doesn't have Homebrew, they'll see a message to install it first. Most Macs already have Homebrew installed.

## Customization Options

### Adding Custom Branding

Make TiosVPN look professional with your company branding - **it's automatic!**

#### Simple Automatic Branding

Just place your logo in the directory and build:

```bash
# 1. Add your logo (must be named TiosVpn.png)
cp /path/to/your-logo.png TiosVpn.png

# 2. Build (automatically uses TiosVpn.png)
./build-installer.sh
```

The script automatically:
- ✅ Creates app icon for Applications, Dock, Spotlight
- ✅ Adds logo to installer welcome screen
- ✅ Adds logo to installer completion screen
- ✅ Builds complete branded package

**Logo Requirements:**
- **File name:** Must be `TiosVpn.png` in the project directory
- **Format:** PNG (transparent background recommended)
- **Size:** 1024x1024 pixels recommended (auto-resized as needed)
- **Shape:** Square works best

#### Updating Your Logo

To change the logo later:

```bash
# 1. Replace the logo file
cp /path/to/new-logo.png TiosVpn.png

# 2. Rebuild
./build-installer.sh
```

#### Building Without Branding

Remove or don't include `TiosVpn.png`, then build:

```bash
# Builds without custom branding if TiosVpn.png doesn't exist
./build-installer.sh
```

### Updating VPN Configuration

The VPN configuration is automatically downloaded from:
```
https://tios-packages.s3.us-east-1.amazonaws.com/macbook-laptops/downloaded-client-config.ovpn
```

To change this URL, edit the `CONFIG_URL` variable in `vpn-manager.sh`:

```bash
CONFIG_URL="https://your-server.com/path/to/config.ovpn"
```

Then rebuild the package.

## Project Structure

```
tiosvpn/
├── TiosVPN-1.0.pkg              # Installer package (distribute this!)
├── TiosVpn.png                  # Your company logo (add this for branding!)
│
├── TiosVPN.app/                 # macOS application bundle
│   └── Contents/
│       ├── MacOS/TiosVPN        # App launcher script
│       ├── Resources/
│       │   ├── TiosVPN-GUI.sh   # GUI interface (AppleScript)
│       │   ├── vpn-manager.sh   # Core VPN logic
│       │   └── TiosVPN.icns     # App icon (generated from TiosVpn.png)
│       └── Info.plist           # App metadata
│
├── Core Scripts/
│   ├── vpn-manager.sh           # Core VPN management functions
│   ├── TiosVPN-GUI.sh           # GUI interface (AppleScript)
│   └── tiosvpn                  # CLI tool
│
├── Build Scripts/
│   ├── build-installer.sh       # ⭐ Main build script (use this!)
│   ├── build-pkg.sh             # Basic build (legacy)
│   ├── build-pkg-with-images.sh # Build with images (legacy)
│   ├── install.sh               # Manual installation
│   ├── create-icon.sh           # Icon helper (called by build-installer.sh)
│   └── add-installer-images.sh  # Image helper (called by build-installer.sh)
│
├── Documentation/
│   ├── README.md                # This file
│   └── ADD-IMAGES.md            # Detailed branding guide
│
└── scripts/
    └── postinstall              # Post-installation script
```

**Key Files:**
- `TiosVpn.png` - Add your logo here (1024x1024px recommended)
- `build-installer.sh` - Run this to build the installer
- `TiosVPN-1.0.pkg` - Final installer to distribute

## Advanced Configuration

### MFA Code Configuration

By default, TiosVPN expects a 6-digit MFA code. The code is prompted each time you connect.

### Changing VPN Server

Edit `vpn-manager.sh` and update the `CONFIG_URL`:

```bash
CONFIG_URL="https://your-vpn-server.com/config.ovpn"
```

### CLI Installation

The CLI tool is automatically installed to `/usr/local/bin/` during package installation. To install manually:

```bash
sudo cp tiosvpn /usr/local/bin/
sudo cp vpn-manager.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/tiosvpn /usr/local/bin/vpn-manager.sh
```

## Technical Details

### How It Works

1. **Credential Storage**: Uses macOS Keychain via `security` command
   - Service: `TiosVPN`
   - Accounts: `vpn-username`, `vpn-password`
   - Encrypted and secure

2. **VPN Configuration**: Downloaded from S3 on first connection
   - Stored in: `~/Library/Application Support/TiosVPN/`
   - Can be manually updated with `tiosvpn update-config`

3. **MFA Handling**: Uses `expect` (built into macOS)
   - Waits for "CHALLENGE:" prompt
   - Sends MFA code
   - Handles connection success/failure

4. **Connection**: Runs `sudo openvpn` with temporary auth file
   - Auth file created and deleted after use
   - No credentials stored in plain text

### Technologies Used

- **Shell Scripts** (bash): Main application logic
- **AppleScript**: GUI dialogs and user interaction
- **Expect**: MFA prompt automation
- **macOS Keychain**: Secure credential storage
- **OpenVPN**: VPN connection
- **pkgbuild/productbuild**: Package creation

### Security Features

- ✅ Passwords encrypted in macOS Keychain
- ✅ Temporary auth files deleted after use
- ✅ MFA required for each connection
- ✅ No credentials in plain text files
- ✅ Secure VPN connection via OpenVPN

## FAQ

**Q: Do I need to install Python or other dependencies?**
A: No! Everything uses built-in macOS tools. OpenVPN is installed automatically by the `.pkg` installer.

**Q: Do I need to install OpenVPN manually?**
A: No! The installer automatically installs OpenVPN if you have Homebrew. If not, you'll be prompted to install Homebrew first (one-time setup).

**Q: Can I use this without the GUI?**
A: Yes! Use the CLI tool: `tiosvpn connect`

**Q: How do I update my password?**
A: Open TiosVPN → Settings → Update Credentials

**Q: Can I connect from the command line?**
A: Yes! Run `tiosvpn connect`

**Q: How do I uninstall?**
A: Use the uninstaller script:
```bash
# Easy way (recommended)
./uninstall.sh

# Or manual removal:
# 1. Remove app
rm -rf /Applications/TiosVPN.app

# 2. Remove CLI tools
sudo rm /usr/local/bin/tiosvpn /usr/local/bin/vpn-manager.sh

# 3. Remove credentials
security delete-generic-password -s TiosVPN -a vpn-username
security delete-generic-password -s TiosVPN -a vpn-password

# 4. Remove configuration
rm -rf ~/Library/Application\ Support/TiosVPN
```

**Q: Can I customize the app icon?**
A: Yes! Just place your logo as `TiosVpn.png` in the directory and run `./build-installer.sh`

**Q: How do I change the VPN server?**
A: Edit `CONFIG_URL` in `vpn-manager.sh` and rebuild the package

**Q: Does this work on Apple Silicon (M1/M2/M3)?**
A: Yes! It works on both Intel and Apple Silicon Macs.

## Support

For issues or questions:
- Read the troubleshooting section above
- Contact your IT department
- Check `ADD-IMAGES.md` for branding help

## Version History

**1.0** - Initial release
- Native macOS app with GUI
- Command-line interface
- Secure Keychain integration
- MFA support
- Professional .pkg installer
- Custom branding support

## License

Internal company use only. Modify as needed for your organization.
