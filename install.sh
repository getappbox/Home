#!/bin/sh

APP_NAME="AppBox.app"
FILE_NAME="AppBox.app.zip"
APPLICATION_DIR="/Applications"
GITHUB_REPO="getappbox/AppBox-iOSAppsWirelessInstallation"
LATEST_URL="https://github.com/$GITHUB_REPO/releases/latest/download/$FILE_NAME"

WORK_DIR=$(mktemp -d) || { echo "Error: Unable to create a temporary directory."; exit 1; }
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT INT TERM

echo "Checking for latest version..."
VERSION=$(curl -fsS "https://api.github.com/repos/$GITHUB_REPO/releases/latest" 2>/dev/null \
    | grep '"tag_name"' \
    | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')

if [ -n "$VERSION" ]; then
    FILE_URL="https://github.com/$GITHUB_REPO/releases/download/$VERSION/$FILE_NAME"
    echo "Latest version: $VERSION"
else
    FILE_URL="$LATEST_URL"
    echo "Could not reach the GitHub API (rate limited?) — downloading the latest release directly."
fi

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
ARCHIVE="$WORK_DIR/$FILE_NAME"
echo "Downloading AppBox${VERSION:+ $VERSION}..."
if ! curl -fL --progress-bar -o "$ARCHIVE" "$FILE_URL"; then
    if [ "$FILE_URL" != "$LATEST_URL" ]; then
        echo "Download failed, retrying with the latest release URL..."
        if ! curl -fL --progress-bar -o "$ARCHIVE" "$LATEST_URL"; then
            echo "Error: Download failed."
            exit 1
        fi
    else
        echo "Error: Download failed."
        exit 1
    fi
fi

# Check if the downloaded file is a valid tar.gz archive
if [ ! -s "$ARCHIVE" ] || ! tar -tzf "$ARCHIVE" > /dev/null 2>&1; then
    echo "Error: The downloaded file is not a valid AppBox archive."
    exit 1
fi

# Unpack somewhere safe first. The previous version is only removed once the new
# one is on disk, so a bad download can never leave the machine with no AppBox.
STAGING="$WORK_DIR/staging"
mkdir -p "$STAGING"
if ! ditto -x -k "$ARCHIVE" "$STAGING" || [ ! -d "$STAGING/$APP_NAME" ]; then
    echo "Error: Installation failed."
    exit 1
fi

echo "Installing AppBox${VERSION:+ $VERSION}..."
rm -rf "$APPLICATION_DIR/$APP_NAME"
if ! mv "$STAGING/$APP_NAME" "$APPLICATION_DIR/$APP_NAME"; then
    echo "Error: Unable to move AppBox into $APPLICATION_DIR."
    exit 1
fi

# Launch
echo "Starting AppBox..."
open "$APPLICATION_DIR/$APP_NAME"
echo "AppBox${VERSION:+ $VERSION} installed successfully!"
