#!/bin/bash
# This script triggers all the steps necessary for building and packaging Ezra Bible App on Linux.

mkdir -p release/electron-installer-redhat
git clone https://github.com/electron-userland/electron-installer-redhat release/electron-installer-redhat

# Use specific version of electron-installer-redhat that adds support for OpenSuse 15.6 in terms of dependency setup
# See https://github.com/electron-userland/electron-installer-redhat/commit/0ca95554b2bdacd24da7942f459709df41336972
git -C release/electron-installer-redhat checkout 0ca955

# Remove dependency to atspi in case of OpenSuse 15.6
echo "Removing atspi dependency in electron-installer-redhat/src/dependencies.js"
sed -i '/atspi/d' release/electron-installer-redhat/src/dependencies.js

npm install --prefix release/electron-installer-redhat

npm run build-linux
npm run rpm_opensuse_leap
cp release/packages/*.rpm $GITHUB_WORKSPACE/ezra-bible-app_latest.rpm

if [ "$GITHUB_EVENT_NAME" = "release" ]; then
  node_modules/.bin/sentry-cli --auth-token $SENTRY_TOKEN \
    upload-dif -o tobias-klein -p ezra-bible-app \
    node_modules/node-sword-interface/build/Release/node_sword_interface.node
fi