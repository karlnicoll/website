#!/usr/bin/env sh
#
# This script builds the example site for deployment.
#

set -e

echo "Building..."
bundle exec jekyll build
