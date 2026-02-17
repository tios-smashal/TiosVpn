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

1. **Install OpenVPN** (one-time):
   ```bash
   brew install openvpn
   ```

2. **Copy TiosVPN.app** to your Applications folder:
   - Drag `TiosVPN.app` to `/Applications/`

3. **First Launch**:
   - Double-click `TiosVPN.app`
   - Enter your VPN username and password (one-time setup)
   - Credentials are securely stored in macOS Keychain

4. **Connect to VPN**:
   - Double-click `TiosVPN.app`
   - Enter your 6-digit MFA code
   - Click "Connect"

### For IT Admins (Building Installer Package)

Build a professional `.pkg` installer for easy distribution:

#### Quick Start (No Customization)

```bash
# Build basic installer package
./build-pkg.sh
```

This creates `TiosVPN-1.0.pkg` ready to distribute.

#### With Custom Branding (Recommended)

Add your company logo to make it professional:

```bash
# 1. Add your logo (PNG, 1024x1024px recommended)
./create-icon.sh your-company-logo.png

# 2. Add logo to installer screens
./add-installer-images.sh your-company-logo.png

# 3. Build the package with branding
./build-pkg-with-images.sh
```

This creates a branded `TiosVPN-1.0.pkg` with:
- Your company logo as the app icon
- Logo displayed in installer welcome/completion screens

#### Manual Installation (Development)

For testing without building a package:

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
- OpenVPN installed via Homebrew: `brew install openvpn`
- Sudo access (for OpenVPN connection)

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
Install OpenVPN:
```bash
brew install openvpn
```

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

## Building and Distribution

### For IT Admins: Creating the Installer

#### Step 1: Customize with Your Branding (Optional but Recommended)

```bash
# Place your company logo in the directory (PNG format, 1024x1024px recommended)
# For example: company-logo.png or TiosVpn.png

# Create app icon from your logo
./create-icon.sh TiosVpn.png

# Add logo to installer welcome/completion screens
./add-installer-images.sh TiosVpn.png
```

#### Step 2: Build the Installer Package

```bash
# If you added custom images:
./build-pkg-with-images.sh

# OR if no custom images:
./build-pkg.sh
```

This creates **TiosVPN-1.0.pkg** - a professional macOS installer package.

#### Step 3: Test the Installer

```bash
# Test the installer before distributing
open TiosVPN-1.0.pkg
```

Go through the installation wizard to verify everything works correctly.

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
1. Install OpenVPN:
   brew install openvpn

2. Download and double-click TiosVPN-1.0.pkg

3. Follow the installation wizard

4. Launch TiosVPN from Applications

5. Enter your credentials (one-time setup)

6. Enter MFA code and connect
```

## Customization Options

### Adding Custom Branding

Make TiosVPN look professional with your company branding:

#### 1. App Icon

Add a custom icon that appears in Applications, Dock, and Spotlight:

```bash
./create-icon.sh path/to/logo.png
```

**Image Requirements:**
- Format: PNG, JPG, or any image format
- Recommended size: 1024x1024 pixels (will be auto-resized)
- Shape: Square
- Can have transparent or solid background

#### 2. Installer Images

Add your logo to the installer welcome and completion screens:

```bash
./add-installer-images.sh path/to/logo.png
```

**Image Requirements:**
- Format: PNG (transparent background recommended) or JPG
- Recommended size: 200-400px wide
- Any aspect ratio (square or horizontal works best)

#### 3. Complete Branding Example

```bash
# If you have your logo as company-logo.png
./create-icon.sh company-logo.png
./add-installer-images.sh company-logo.png
./build-pkg-with-images.sh
```

See `ADD-IMAGES.md` for detailed instructions and examples.

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
├── TiosVPN.app/                 # macOS application bundle
│   └── Contents/
│       ├── MacOS/TiosVPN        # App launcher script
│       ├── Resources/
│       │   ├── TiosVPN-GUI.sh   # GUI interface (AppleScript)
│       │   ├── vpn-manager.sh   # Core VPN logic
│       │   └── TiosVPN.icns     # App icon (if customized)
│       └── Info.plist           # App metadata
│
├── Scripts/
│   ├── vpn-manager.sh           # Core VPN management functions
│   ├── TiosVPN-GUI.sh           # GUI interface (AppleScript)
│   └── tiosvpn                  # CLI tool
│
├── Build Scripts/
│   ├── build-pkg.sh             # Build basic installer
│   ├── build-pkg-with-images.sh # Build installer with custom images
│   ├── install.sh               # Manual installation script
│   ├── create-icon.sh           # Create app icon from image
│   └── add-installer-images.sh  # Add images to installer
│
├── Documentation/
│   ├── README.md                # This file
│   └── ADD-IMAGES.md            # Custom branding guide
│
└── scripts/
    └── postinstall              # Post-installation script
```

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
- ✅ Sudo required for VPN connection

## FAQ

**Q: Do I need to install Python or other dependencies?**
A: No! Everything uses built-in macOS tools.

**Q: Can I use this without the GUI?**
A: Yes! Use the CLI tool: `tiosvpn connect`

**Q: How do I update my password?**
A: Open TiosVPN → Settings → Update Credentials

**Q: Can I connect from the command line?**
A: Yes! Run `tiosvpn connect`

**Q: How do I uninstall?**
A:
```bash
# Remove app
rm -rf /Applications/TiosVPN.app

# Remove CLI tool
sudo rm /usr/local/bin/tiosvpn /usr/local/bin/vpn-manager.sh

# Remove credentials
security delete-generic-password -s TiosVPN -a vpn-username
security delete-generic-password -s TiosVPN -a vpn-password

# Remove configuration
rm -rf ~/Library/Application\ Support/TiosVPN
```

**Q: Can I customize the app icon?**
A: Yes! See "Customization Options" section above or read `ADD-IMAGES.md`

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
