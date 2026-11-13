#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

guest_build=$(mktemp -d)
trap 'rm -rf "$guest_build"' EXIT

flutter build web --no-web-resources-cdn
flutter build web --no-web-resources-cdn --target lib/guest_main.dart \
  --base-href /guest/ --output "$guest_build"
mkdir -p build/web/guest
cp -R "$guest_build/." build/web/guest/
