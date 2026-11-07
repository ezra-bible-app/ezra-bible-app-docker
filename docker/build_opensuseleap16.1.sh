#!/bin/bash
# Build and package Ezra Bible App on openSUSE Leap 16.1.
set -euo pipefail

installer=release/electron-installer-redhat
git clone https://github.com/electron-userland/electron-installer-redhat "$installer"
git -C "$installer" checkout 0ca95554b2bdacd24da7942f459709df41336972

# Fix the staging path and declare Electron's audio library for Leap 16.1.
node - "$installer/resources/spec.ejs" <<'NODE'
const fs = require('fs');
const path = process.argv[2];
let template = fs.readFileSync(path, 'utf8');
const replacements = [
  ['usr/* %{buildroot}/usr/', '%{_topdir}/BUILD/usr/* %{buildroot}/usr/'],
  ["Requires: <%= requires.join(', ') %>", "Requires: <%= requires.join(', ') %>, libasound2"]
];
for (const [original, replacement] of replacements) {
  if (template.split(original).length !== 2) {
    throw new Error(`Expected exactly one '${original}' in ${path}`);
  }
  template = template.replace(original, replacement);
}
fs.writeFileSync(path, template);
NODE

npm install --prefix "$installer"
npm run build-linux
npm run rpm_opensuse_leap

workspace=${GITHUB_WORKSPACE:-$PWD}
cp release/packages/*.rpm "$workspace/ezra-bible-app_latest.rpm"
echo "Package creation done. Listing package dependencies:"
rpm -qpR "$workspace/ezra-bible-app_latest.rpm"

if [ "${GITHUB_EVENT_NAME:-}" = "release" ]; then
  node_modules/.bin/sentry-cli --auth-token "${SENTRY_TOKEN:?SENTRY_TOKEN is required for releases}" \
    upload-dif -o tobias-klein -p ezra-bible-app \
    node_modules/node-sword-interface/build/Release/node_sword_interface.node
fi
