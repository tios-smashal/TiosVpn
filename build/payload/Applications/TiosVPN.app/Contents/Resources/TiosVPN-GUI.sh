#!/bin/bash
#
# TiosVPN GUI - AppleScript-based graphical interface
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VPN_MANAGER="$SCRIPT_DIR/vpn-manager.sh"

# Check if credentials exist
if [ "$("$VPN_MANAGER" credentials-exist)" = "no" ]; then
    # Show setup dialog
    setup_result=$(osascript << 'EOF'
tell application "System Events"
    activate
    set dialogResult to display dialog "Welcome to TiosVPN Setup" & return & return & "Enter your VPN credentials:" & return & "Username:" default answer "" buttons {"Cancel", "Continue"} default button "Continue" with title "TiosVPN Setup"
    set username to text returned of dialogResult

    if username is "" then
        display dialog "Username cannot be empty" buttons {"OK"} default button "OK" with icon stop
        return "error"
    end if

    set dialogResult to display dialog "Enter your VPN password:" default answer "" buttons {"Cancel", "Save"} default button "Save" with title "TiosVPN Setup" with hidden answer
    set password to text returned of dialogResult

    if password is "" then
        display dialog "Password cannot be empty" buttons {"OK"} default button "OK" with icon stop
        return "error"
    end if

    return username & "|" & password
end tell
EOF
)

    if [ "$setup_result" = "error" ] || [ -z "$setup_result" ]; then
        exit 1
    fi

    # Parse username and password
    username=$(echo "$setup_result" | cut -d'|' -f1)
    password=$(echo "$setup_result" | cut -d'|' -f2-)

    # Save credentials
    "$VPN_MANAGER" save-credentials "$username" "$password"

    osascript -e 'tell app "System Events" to display dialog "✓ Credentials saved successfully!" & return & return & "You can now connect to VPN." buttons {"OK"} default button "OK" with title "TiosVPN Setup"'
fi

# Main menu loop
while true; do
    # Check connection status
    if [ "$("$VPN_MANAGER" is-connected)" = "yes" ]; then
        # Connected - show disconnect option
        choice=$(osascript << 'EOF'
tell application "System Events"
    activate
    set dialogResult to display dialog "TiosVPN Status: Connected ✓" buttons {"Disconnect", "Settings", "Quit"} default button "Disconnect" with title "TiosVPN" with icon note
    return button returned of dialogResult
end tell
EOF
)

        case "$choice" in
            "Disconnect")
                "$VPN_MANAGER" disconnect
                if [ $? -eq 0 ]; then
                    osascript -e 'tell app "System Events" to display dialog "✓ Disconnected from VPN" buttons {"OK"} default button "OK" with title "TiosVPN"'
                else
                    osascript -e 'tell app "System Events" to display dialog "✗ Failed to disconnect" buttons {"OK"} default button "OK" with icon stop with title "TiosVPN"'
                fi
                ;;
            "Settings")
                settings_choice=$(osascript << 'EOF'
tell application "System Events"
    activate
    set dialogResult to display dialog "TiosVPN Settings" buttons {"Update Credentials", "Delete Credentials", "Back"} default button "Back" with title "TiosVPN Settings"
    return button returned of dialogResult
end tell
EOF
)
                case "$settings_choice" in
                    "Update Credentials"|"Delete Credentials")
                        # Delete current credentials
                        "$VPN_MANAGER" delete-credentials
                        osascript -e 'tell app "System Events" to display dialog "Credentials removed. Please restart the app to set new credentials." buttons {"OK"} default button "OK" with title "TiosVPN"'
                        exit 0
                        ;;
                esac
                ;;
            "Quit")
                exit 0
                ;;
        esac

    else
        # Disconnected - show connect option
        # Ask for MFA code
        mfa_result=$(osascript << 'EOF'
tell application "System Events"
    activate
    set dialogResult to display dialog "TiosVPN Status: Disconnected" & return & return & "Enter your MFA code (6 digits):" default answer "" buttons {"Cancel", "Connect", "Settings"} default button "Connect" with title "TiosVPN"
    set buttonPressed to button returned of dialogResult
    set mfaCode to text returned of dialogResult
    return buttonPressed & "|" & mfaCode
end tell
EOF
)

        button=$(echo "$mfa_result" | cut -d'|' -f1)
        mfa_code=$(echo "$mfa_result" | cut -d'|' -f2)

        case "$button" in
            "Connect")
                # Validate MFA code
                if [ ${#mfa_code} -ne 6 ] || ! [[ "$mfa_code" =~ ^[0-9]+$ ]]; then
                    osascript -e 'tell app "System Events" to display dialog "Error: MFA code must be exactly 6 digits" buttons {"OK"} default button "OK" with icon stop with title "TiosVPN"'
                    continue
                fi

                # Show connecting message
                osascript -e 'tell app "System Events" to display notification "Connecting to VPN..." with title "TiosVPN"'

                # Connect in background and capture output
                connect_output=$("$VPN_MANAGER" connect "$mfa_code" 2>&1)
                connect_status=$?

                if [ $connect_status -eq 0 ]; then
                    osascript -e 'tell app "System Events" to display dialog "✓ Connected to VPN successfully!" buttons {"OK"} default button "OK" with title "TiosVPN"'
                else
                    error_msg=$(echo "$connect_output" | tail -1)
                    osascript -e "tell app \"System Events\" to display dialog \"✗ Connection failed:\" & return & return & \"$error_msg\" buttons {\"OK\"} default button \"OK\" with icon stop with title \"TiosVPN\""
                fi
                ;;
            "Settings")
                settings_choice=$(osascript << 'EOF'
tell application "System Events"
    activate
    set dialogResult to display dialog "TiosVPN Settings" buttons {"Update Credentials", "Delete Credentials", "Back"} default button "Back" with title "TiosVPN Settings"
    return button returned of dialogResult
end tell
EOF
)
                case "$settings_choice" in
                    "Update Credentials"|"Delete Credentials")
                        "$VPN_MANAGER" delete-credentials
                        osascript -e 'tell app "System Events" to display dialog "Credentials removed. Please restart the app to set new credentials." buttons {"OK"} default button "OK" with title "TiosVPN"'
                        exit 0
                        ;;
                esac
                ;;
            "Cancel")
                exit 0
                ;;
        esac
    fi
done
