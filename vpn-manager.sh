#!/bin/bash
#
# TiosVPN Manager - Core VPN management functions
#

set -e

# Configuration
CONFIG_URL="https://tios-packages.s3.us-east-1.amazonaws.com/macbook-laptops/downloaded-client-config.ovpn"
APP_DIR="$HOME/Library/Application Support/TiosVPN"
CONFIG_FILE="$APP_DIR/client-config.ovpn"
KEYCHAIN_SERVICE="TiosVPN"
KEYCHAIN_ACCOUNT_USER="vpn-username"
KEYCHAIN_ACCOUNT_PASS="vpn-password"
PID_FILE="$APP_DIR/vpn.pid"

# Create app directory
mkdir -p "$APP_DIR"

# Function: Download VPN config
download_config() {
    echo "Downloading VPN configuration..."
    if curl -f -o "$CONFIG_FILE" "$CONFIG_URL" 2>/dev/null; then
        echo "✓ Config downloaded successfully"
        return 0
    else
        echo "✗ Failed to download config"
        return 1
    fi
}

# Function: Check if config exists
config_exists() {
    [ -f "$CONFIG_FILE" ]
}

# Function: Save credentials to Keychain
save_credentials() {
    local username="$1"
    local password="$2"

    if [ -z "$username" ] || [ -z "$password" ]; then
        echo "Error: Username and password required"
        return 1
    fi

    # Save username
    security add-generic-password \
        -a "$KEYCHAIN_ACCOUNT_USER" \
        -s "$KEYCHAIN_SERVICE" \
        -w "$username" \
        -U 2>/dev/null

    # Save password
    security add-generic-password \
        -a "$KEYCHAIN_ACCOUNT_PASS" \
        -s "$KEYCHAIN_SERVICE" \
        -w "$password" \
        -U 2>/dev/null

    echo "✓ Credentials saved to Keychain"
    return 0
}

# Function: Get credentials from Keychain
get_username() {
    security find-generic-password \
        -a "$KEYCHAIN_ACCOUNT_USER" \
        -s "$KEYCHAIN_SERVICE" \
        -w 2>/dev/null || echo ""
}

get_password() {
    security find-generic-password \
        -a "$KEYCHAIN_ACCOUNT_PASS" \
        -s "$KEYCHAIN_SERVICE" \
        -w 2>/dev/null || echo ""
}

# Function: Check if credentials exist
credentials_exist() {
    local username=$(get_username)
    [ -n "$username" ]
}

# Function: Delete credentials
delete_credentials() {
    security delete-generic-password \
        -a "$KEYCHAIN_ACCOUNT_USER" \
        -s "$KEYCHAIN_SERVICE" 2>/dev/null || true

    security delete-generic-password \
        -a "$KEYCHAIN_ACCOUNT_PASS" \
        -s "$KEYCHAIN_SERVICE" 2>/dev/null || true

    echo "✓ Credentials deleted"
}

# Function: Check if VPN is connected
is_connected() {
    pgrep -f "openvpn.*client-config.ovpn" >/dev/null 2>&1
}

# Function: Connect to VPN
connect_vpn() {
    local mfa_code="$1"

    if [ -z "$mfa_code" ]; then
        echo "Error: MFA code required"
        return 1
    fi

    # Check if already connected
    if is_connected; then
        echo "Already connected to VPN"
        return 0
    fi

    # Download config if needed
    if ! config_exists; then
        if ! download_config; then
            return 1
        fi
    fi

    # Get credentials
    local username=$(get_username)
    local password=$(get_password)

    if [ -z "$username" ] || [ -z "$password" ]; then
        echo "Error: No credentials found. Please run setup first."
        return 1
    fi

    # Create temporary auth file
    local auth_file=$(mktemp)
    echo "$username" > "$auth_file"
    echo "$password" >> "$auth_file"

    echo "Connecting to VPN..."

    # Create expect script
    local expect_script=$(mktemp)
    cat > "$expect_script" << 'EXPECT_EOF'
#!/usr/bin/expect -f
set timeout 30
set config_file [lindex $argv 0]
set auth_file [lindex $argv 1]
set mfa_code [lindex $argv 2]

spawn sudo openvpn --config $config_file --auth-user-pass $auth_file

expect {
    "Password:" {
        puts "\nError: Need sudo password"
        exit 1
    }
    "CHALLENGE:" {
        send "$mfa_code\r"
        expect {
            "Initialization Sequence Completed" {
                puts "\n✓ Connected successfully!"
                puts "VPN is now active. Press Ctrl+C to disconnect.\n"
                interact
            }
            "AUTH_FAILED" {
                puts "\nError: Authentication failed"
                exit 1
            }
            timeout {
                puts "\nError: Connection timeout"
                exit 1
            }
        }
    }
    timeout {
        puts "\nError: Timeout waiting for MFA prompt"
        exit 1
    }
    eof {
        puts "\nError: Unexpected disconnection"
        exit 1
    }
}
EXPECT_EOF

    chmod +x "$expect_script"

    # Run expect script
    "$expect_script" "$CONFIG_FILE" "$auth_file" "$mfa_code"
    local exit_code=$?

    # Cleanup
    rm -f "$auth_file" "$expect_script"

    return $exit_code
}

# Function: Disconnect VPN
disconnect_vpn() {
    if ! is_connected; then
        echo "VPN is not connected"
        return 0
    fi

    echo "Disconnecting from VPN..."
    sudo pkill -f "openvpn.*client-config.ovpn"
    sleep 1

    if ! is_connected; then
        echo "✓ Disconnected successfully"
        return 0
    else
        echo "✗ Failed to disconnect"
        return 1
    fi
}

# Function: Get status
get_status() {
    echo "=== TiosVPN Status ==="

    if is_connected; then
        echo "Connection:   ✓ Connected"
    else
        echo "Connection:   ✗ Not connected"
    fi

    if credentials_exist; then
        echo "Credentials:  ✓ Configured"
    else
        echo "Credentials:  ✗ Not configured"
    fi

    if config_exists; then
        echo "Config:       ✓ Downloaded"
    else
        echo "Config:       ✗ Not downloaded"
    fi
}

# Main function for command-line usage
main() {
    case "${1:-}" in
        save-credentials)
            save_credentials "$2" "$3"
            ;;
        get-username)
            get_username
            ;;
        get-password)
            get_password
            ;;
        credentials-exist)
            credentials_exist && echo "yes" || echo "no"
            ;;
        delete-credentials)
            delete_credentials
            ;;
        is-connected)
            is_connected && echo "yes" || echo "no"
            ;;
        connect)
            connect_vpn "$2"
            ;;
        disconnect)
            disconnect_vpn
            ;;
        status)
            get_status
            ;;
        download-config)
            download_config
            ;;
        *)
            echo "Usage: $0 {save-credentials|get-username|credentials-exist|delete-credentials|is-connected|connect|disconnect|status|download-config}"
            exit 1
            ;;
    esac
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    main "$@"
fi
