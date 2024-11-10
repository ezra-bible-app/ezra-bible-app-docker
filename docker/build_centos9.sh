#!/bin/sh
# This script triggers all the steps necessary for building and packaging Ezra Bible App on Linux.

npm run build-linux
npm run rpm_centos
cp release/packages/*.rpm $GITHUB_WORKSPACE/ezra-bible-app_latest.rpm

if [ "$GITHUB_EVENT_NAME" = "release" ]; then
  node_modules/.bin/sentry-cli --auth-token $SENTRY_TOKEN \
    upload-dif -o tobias-klein -p ezra-bible-app \
    node_modules/node-sword-interface/build/Release/node_sword_interface.node
fi