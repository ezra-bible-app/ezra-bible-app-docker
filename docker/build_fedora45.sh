#!/bin/bash
# Build and package Ezra Bible App on Fedora 45.
set -euo pipefail

npm run build-linux
npm install --no-save electron-installer-redhat@3.4.0
node build_scripts/linux/patch_electron_installer_redhat.js
npm run rpm_fedora45

workspace=${GITHUB_WORKSPACE:-$PWD}
cp release/packages/*.rpm "$workspace/ezra-bible-app_latest.rpm"
echo "Package creation done. Listing package dependencies:"
rpm -qpR "$workspace/ezra-bible-app_latest.rpm"

if [ "${GITHUB_EVENT_NAME:-}" = "release" ]; then
  node_modules/.bin/sentry-cli --auth-token "${SENTRY_TOKEN:?SENTRY_TOKEN is required for releases}" \
    upload-dif -o tobias-klein -p ezra-bible-app \
    node_modules/node-sword-interface/build/Release/node_sword_interface.node
fi
