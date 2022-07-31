#!/bin/sh

VERSION="3.1.0"
APP_NAME="AppBox.app"
FILE_NAME="AppBox.tar.gz"
FILE_URL="https://github.com/vineetchoudhary/AppBox-iOSAppsWirelessInstallation/releases/download/$VERSION/AppBox.tar.gz"
APPLICATION_DIR='/Applications'

echo "Downloading AppBox $VERSION..."
curl -OL $FILE_URL

echo "Uninstalling existing AppBox..."
rm -rf $APPLICATION_DIR/$APP_NAME

echo "Installing AppBox $VERSION..."
tar -xf $FILE_NAME -C $APPLICATION_DIR

echo "Starting AppBox..."
open $APPLICATION_DIR/$APP_NAME
