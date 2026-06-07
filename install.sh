#!/bin/sh

APP_NAME="AppBox.app"
FILE_NAME="AppBox.tar.gz"
APPLICATION_DIR="/Applications"
GITHUB_REPO="getappbox/AppBox-iOSAppsWirelessInstallation"

# Fetch latest version from GitHub
echo "Checking for latest version..."
VERSION=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
if [ -z "$VERSION" ]; then
    echo "Error: Failed to fetch latest version from GitHub."
    exit 1
fi

FILE_URL="https://github.com/$GITHUB_REPO/releases/download/$VERSION/$FILE_NAME"
echo "Latest version: $VERSION"

# Check if AppBox is running and offer to quit
if pgrep -x "AppBox" > /dev/null 2>&1; then
    printf "AppBox is currently running. Quit AppBox to continue update? (y/n): "
    read -r answer < /dev/tty
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        echo "Quitting AppBox..."
        osascript -e 'quit app "AppBox"'
        sleep 2
        # Force kill if still running
        if pgrep -x "AppBox" > /dev/null 2>&1; then
            killall "AppBox" 2>/dev/null
            sleep 1
        fi
    else
        echo "Update cancelled."
        exit 0
    fi
fi

# Download
echo "Downloading AppBox $VERSION..."
curl -L --progress-bar -o "$FILE_NAME" "$FILE_URL"
if [ $? -ne 0 ] || [ ! -f "$FILE_NAME" ]; then
    echo "Error: Download failed."
    exit 1
fi

# Install
echo "Installing AppBox $VERSION..."
rm -rf "$APPLICATION_DIR/$APP_NAME"
tar -xf "$FILE_NAME" -C "$APPLICATION_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Installation failed."
    rm -f "$FILE_NAME"
    exit 1
fi

# Cleanup
rm -f "$FILE_NAME"

# Launch
echo "Starting AppBox..."
open "$APPLICATION_DIR/$APP_NAME"
echo "AppBox $VERSION installed successfully!"
