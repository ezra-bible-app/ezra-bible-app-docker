#!/bin/sh
# This script triggers all the steps necessary for building and packaging Ezra Bible App on Linux.

mkdir release/electron-installer-redhat
git clone https://github.com/electron-userland/electron-installer-redhat release/electron-installer-redhat
npm install --prefix release/electron-installer-redhat

npm run build-linux
npm run rpm_opensuse_leap
cp release/packages/*.rpm $GITHUB_WORKSPACE/ezra-bible-app_latest.rpm

if [ "$GITHUB_EVENT_NAME" = "release" ]; then
  node_modules/.bin/sentry-cli --auth-token $SENTRY_TOKEN \
    upload-dif -o tobias-klein -p ezra-bible-app \
    node_modules/node-sword-interface/build/Release/node_sword_interface.node
fi