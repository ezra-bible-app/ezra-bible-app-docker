#!/bin/sh
# This script triggers all the steps necessary for building and packaging Ezra Bible App on Linux.

npm run build-linux
chmod a+rw -R release