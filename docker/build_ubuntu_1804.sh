#!/bin/sh
# This script triggers all the steps necessary for building and packaging Ezra Project on Linux.

npm run build-linux
npm run deb_1804
cp release/packages/*.deb $GITHUB_WORKSPACE/ezra-project_latest.deb

if [ "$GITHUB_EVENT_NAME" = "release" ]; then
  node_modules/.bin/sentry-cli --auth-token $SENTRY_TOKEN \
    upload-dif -o tobias-klein -p ezra-project \
    node_modules/node-sword-interface/build/Release/node_sword_interface.node
fi