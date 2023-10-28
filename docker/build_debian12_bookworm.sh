#!/bin/bash
# This script triggers all the steps necessary for building and packaging Ezra Bible App on Linux.

# Use Python 3.10.0, because with 3.11 there are issues with node-gyp
# See https://stackoverflow.com/questions/74715990/node-gyp-err-invalid-mode-ru-while-trying-to-load-binding-gyp
curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
export PATH=$PATH:$HOME/.pyenv/bin
pyenv install 3.10.0
pyenv global 3.10.0
pyenv init -
pyenv virtualenv-init -
pyenv exec python -m venv .venv
pyenv activate venv

npm run build-linux
npm run deb_bookworm
cp release/packages/*.deb $GITHUB_WORKSPACE/ezra-bible-app_latest.deb

if [ "$GITHUB_EVENT_NAME" = "release" ]; then
  node_modules/.bin/sentry-cli --auth-token $SENTRY_TOKEN \
    upload-dif -o tobias-klein -p ezra-bible-app \
    node_modules/node-sword-interface/build/Release/node_sword_interface.node
fi
