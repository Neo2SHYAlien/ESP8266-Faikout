#!/bin/sh
# Build the ESP8266 Faikout firmware.
#
# The container only sees what is bind-mounted, and ESP-IDF derives
# PROJECT_VER from `git describe` in the project dir (ESP/). Running the
# container from ESP/ with only ESP/ mounted hides .git, so IDF falls back
# to PROJECT_VER="1" and freezes the app_desc build date.
#
# Run this from anywhere: it mounts the repository root (so .git is
# available, as documented in the Containerfile) and pins ESP/version.txt
# (ESP-IDF's documented PROJECT_VER override, watched for changes) plus
# rebuilds the cached app_desc object, so every build carries the real
# version hash and the current build time.
#
# Usage: ./build.sh [make-args...]
set -e
cd "$(dirname "$0")"                    # repository root
git describe --always --tags --dirty > ESP/version.txt
rm -f ESP/build/esp-idf/app_update/CMakeFiles/__idf_app_update.dir/esp_app_desc.c.obj
exec podman run --rm -v "$PWD":/repo -w /repo/ESP \
	"${FAIKOUT_BUILD_IMAGE:-localhost/faikin-8266-build:v3.4}" make "$@"
