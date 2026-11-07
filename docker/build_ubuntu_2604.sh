#!/bin/bash
# Build and package Ezra Bible App on Ubuntu 26.04 LTS.
set -euo pipefail

npm run build-linux
npm run deb_2604

workspace=${GITHUB_WORKSPACE:-$PWD}
cp release/packages/*.deb "$workspace/ezra-bible-app_latest.deb"
echo "Package creation done. Listing package dependencies:"
dpkg-deb -f "$workspace/ezra-bible-app_latest.deb" Depends

if [ "${GITHUB_EVENT_NAME:-}" = "release" ]; then
  node_modules/.bin/sentry-cli --auth-token "${SENTRY_TOKEN:?SENTRY_TOKEN is required for releases}" \
    upload-dif -o tobias-klein -p ezra-bible-app \
    node_modules/node-sword-interface/build/Release/node_sword_interface.node
fi
