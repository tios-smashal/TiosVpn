#!/bin/bash
#
# TiosVPN GUI - AppleScript-based graphical interface
#

# Determine script location (works from .app bundle or standalone)
if [ -n "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

VPN_MANAGER="$SCRIPT_DIR/vpn-manager.sh"

# Verify vpn-manager exists
if [ ! -f "$VPN_MANAGER" ]; then
    osascript -e 'tell app "System Events" to display dialog "Error: VPN manager script not found.\n\nPlease reinstall TiosVPN." buttons {"OK"} default button "OK" with icon stop with title "TiosVPN Error"'
    exit 1
fi

# Check if credentials exist
CREDS_EXIST=$("$VPN_MANAGER" credentials-exist 2>/dev/null)
if [ "$CREDS_EXIST" != "yes" ]; then
    # Show setup dialog
    setup_result=$(osascript << 'EOF'
tell application "System Events"
    activate

    -- Username dialog
    set usernameDialog to display dialog "Welcome to TiosVPN" & return & return & "Enter your VPN username:" default answer "" buttons {"Cancel", "Continue"} default button "Continue" with title "TiosVPN Setup"
    set username to text returned of usernameDialog

    if username is "" then
        display dialog "Username cannot be empty" buttons {"OK"} default button "OK" with icon stop with title "TiosVPN Setup"
        error number -128
    end if

    -- Password dialog
    set passwordDialog to display dialog "Enter your VPN password:" default answer "" buttons {"Cancel", "Save"} default button "Save" with title "TiosVPN Setup" with hidden answer
    set password to text returned of passwordDialog

    if password is "" then
        display dialog "Password cannot be empty" buttons {"OK"} default button "OK" with icon stop with title "TiosVPN Setup"
        error number -128
    end if

    return username & "|" & password
end tell
EOF
)

    # Check if user cancelled
    if [ $? -ne 0 ] || [ -z "$setup_result" ]; then
        exit 0
    fi

    # Parse username and password
    username=$(echo "$setup_result" | cut -d'|' -f1)
    password=$(echo "$setup_result" | cut -d'|' -f2-)

    # Debug output
    echo "Saving credentials for user: $username"

    # Save credentials
    if "$VPN_MANAGER" save-credentials "$username" "$password" 2>&1; then
        osascript -e 'tell app "System Events" to display dialog "Credentials saved successfully!" & return & return & "You can now connect to VPN." buttons {"OK"} default button "OK" with title "TiosVPN Setup"'
    else
        osascript -e 'tell app "System Events" to display dialog "Failed to save credentials!" & return & return & "Please try again or contact IT support." buttons {"OK"} default button "OK" with icon stop with title "TiosVPN Error"'
        exit 1
    fi
fi

# Main menu loop
while true; do
    # Check connection status
    IS_CONNECTED=$("$VPN_MANAGER" is-connected 2>/dev/null)

    if [ "$IS_CONNECTED" = "yes" ]; then
        # Connected - show disconnect option
        choice=$(osascript -e 'tell application "System Events" to display dialog "TiosVPN Status: Connected ✓" buttons {"Disconnect", "Settings", "Quit"} default button "Disconnect" with title "TiosVPN"' -e 'button returned of result' 2>/dev/null)

        case "$choice" in
            "Disconnect")
                "$VPN_MANAGER" disconnect
                if [ $? -eq 0 ]; then
                    osascript -e 'tell app "System Events" to display dialog "Disconnected from VPN" buttons {"OK"} default button "OK" with title "TiosVPN"'
                else
                    osascript -e 'tell app "System Events" to display dialog "Failed to disconnect" buttons {"OK"} default button "OK" with icon stop with title "TiosVPN"'
                fi
                ;;
            "Settings")
                settings_choice=$(osascript -e 'tell application "System Events" to display dialog "TiosVPN Settings" buttons {"Update Credentials", "Delete Credentials", "Back"} default button "Back" with title "TiosVPN Settings"' -e 'button returned of result' 2>/dev/null)

                case "$settings_choice" in
                    "Update Credentials"|"Delete Credentials")
                        "$VPN_MANAGER" delete-credentials
                        osascript -e 'tell app "System Events" to display dialog "Credentials removed.\n\nRestart TiosVPN to set new credentials." buttons {"OK"} default button "OK" with title "TiosVPN"'
                        exit 0
                        ;;
                esac
                ;;
            "Quit"|"")
                exit 0
                ;;
        esac
    else
        # Disconnected - show connect option
        mfa_result=$(osascript << 'EOF'
tell application "System Events"
    activate
    set dialogResult to display dialog "TiosVPN Status: Disconnected" & return & return & "Enter your 6-digit MFA code:" default answer "" buttons {"Quit", "Settings", "Connect"} default button "Connect" with title "TiosVPN"
    set buttonPressed to button returned of dialogResult
    set mfaCode to text returned of dialogResult
    return buttonPressed & "|" & mfaCode
end tell
EOF
)

        # Check if user cancelled
        if [ $? -ne 0 ]; then
            exit 0
        fi

        button=$(echo "$mfa_result" | cut -d'|' -f1)
        mfa_code=$(echo "$mfa_result" | cut -d'|' -f2)

        case "$button" in
            "Connect")
                # Validate MFA code
                if [ ${#mfa_code} -ne 6 ] || ! [[ "$mfa_code" =~ ^[0-9]+$ ]]; then
                    osascript -e 'tell app "System Events" to display dialog "MFA code must be exactly 6 digits" buttons {"OK"} default button "OK" with icon stop with title "TiosVPN"'
                    continue
                fi

                # Show connecting notification
                osascript -e 'tell app "System Events" to display notification "Connecting to VPN..." with title "TiosVPN"' 2>/dev/null || true

                # Open Terminal and connect
                osascript << APPLESCRIPT
tell application "Terminal"
    activate
    do script "cd '$SCRIPT_DIR' && '$VPN_MANAGER' connect '$mfa_code'"
end tell
APPLESCRIPT
                # Exit this GUI instance since Terminal takes over
                exit 0
                ;;
            "Settings")
                settings_choice=$(osascript -e 'tell application "System Events" to display dialog "TiosVPN Settings" buttons {"Update Credentials", "Delete Credentials", "Back"} default button "Back" with title "TiosVPN Settings"' -e 'button returned of result' 2>/dev/null)

                case "$settings_choice" in
                    "Update Credentials"|"Delete Credentials")
                        "$VPN_MANAGER" delete-credentials
                        osascript -e 'tell app "System Events" to display dialog "Credentials removed.\n\nRestart TiosVPN to set new credentials." buttons {"OK"} default button "OK" with title "TiosVPN"'
                        exit 0
                        ;;
                esac
                ;;
            "Quit"|"")
                exit 0
                ;;
        esac
    fi
done
