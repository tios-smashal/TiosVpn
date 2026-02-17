# Adding Custom Images to TiosVPN

You can customize TiosVPN with your company logo and branding!

## 🎨 Option 1: Add App Icon

Add a custom icon that appears in Applications folder, Dock, and Spotlight.

### Steps:

1. **Prepare your image:**
   - Should be at least 1024x1024 pixels
   - PNG format works best
   - Square aspect ratio
   - Can be your company logo

2. **Create the icon:**
   ```bash
   ./create-icon.sh path/to/your-logo.png
   ```

3. **Rebuild the package:**
   ```bash
   ./build-pkg.sh
   ```

### Example:
```bash
# If you have company-logo.png
./create-icon.sh company-logo.png

# This creates TiosVPN.icns and adds it to the app
# Then rebuild
./build-pkg.sh
```

---

## 🖼️ Option 2: Add Installer Images

Add your company logo to the installer welcome and completion screens.

### Steps:

1. **Prepare your logo:**
   - PNG or JPG format
   - Recommended size: 200-400px wide
   - Transparent background looks best

2. **Add to installer:**
   ```bash
   ./add-installer-images.sh path/to/logo.png
   ```

3. **Build package with images:**
   ```bash
   ./build-pkg-with-images.sh
   ```

### Example:
```bash
# Add logo to installer
./add-installer-images.sh company-logo.png

# Build the package
./build-pkg-with-images.sh
```

---

## 🎯 Do Both (Recommended)

For the most professional look, add both app icon and installer images:

```bash
# Step 1: Add app icon
./create-icon.sh company-logo.png

# Step 2: Add installer images
./add-installer-images.sh company-logo.png

# Step 3: Build package with everything
./build-pkg-with-images.sh
```

---

## 📝 Quick Start Example

Let's say you have a file called `tios-logo.png`:

```bash
# Create app icon from logo
./create-icon.sh tios-logo.png

# Add logo to installer
./add-installer-images.sh tios-logo.png

# Build the final package
./build-pkg-with-images.sh

# Test it
open TiosVPN-1.0.pkg
```

The installer will now show:
- ✅ Your logo in the welcome screen
- ✅ Your logo in the completion screen
- ✅ Custom app icon when installed

---

## 🎨 Image Requirements

### App Icon:
- **Format:** PNG, JPG, or any image format
- **Size:** At least 1024x1024 pixels (will be auto-resized)
- **Shape:** Square
- **Background:** Can be transparent or solid color

### Installer Logo:
- **Format:** PNG (transparent background recommended), JPG
- **Size:** 200-400px wide (will be auto-resized to max 200px)
- **Aspect Ratio:** Any (but square or horizontal works best)

---

## 🔄 Updating Images

To change the images later:

```bash
# Update app icon
./create-icon.sh new-logo.png

# Update installer images
./add-installer-images.sh new-logo.png

# Rebuild
./build-pkg-with-images.sh
```

---

## 📁 Files Created

After adding images, you'll have:

```
tiosvpn/
├── TiosVPN.icns                      # App icon file
├── TiosVPN.app/Contents/Resources/
│   └── TiosVPN.icns                  # Icon in app bundle
├── installer-resources/
│   └── logo.png                      # Installer logo
└── build-pkg-with-images.sh          # Build script with images
```

---

## 💡 Tips

1. **Use your company logo** for brand consistency
2. **PNG with transparency** looks most professional
3. **Test the installer** after adding images: `open TiosVPN-1.0.pkg`
4. **Keep original images** in case you need to rebuild

---

Need help? The scripts will show errors if image files aren't found or have issues.
