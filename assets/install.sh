#!/bin/sh

APP_NAME='AppBox.app'
FILE_NAME='AppBox.tar.gz'
FILE_URL='https://github.com/vineetchoudhary/AppBox-iOSAppsWirelessInstallation/releases/download/2.7.2/AppBox.tar.gz'
APPLICATION_DIR='/Applications'

curl -OL $FILE_URL
tar -xf $FILE_NAME -C $APPLICATION_DIR
open $APPLICATION_DIR/$APP_NAME