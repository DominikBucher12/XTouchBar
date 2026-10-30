#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
xcrun clang -arch "${XCB_ARCH:-$(uname -m)}" -mmacosx-version-min=10.15 -fobjc-arc -O1 -Wall -Wextra \
  -dynamiclib -framework Foundation -framework AppKit -framework CoreFoundation \
  -install_name @rpath/libXcodeCommandBridge.dylib \
  XcodeCommandBridge.m XCBRuntime.m XCBCommandCatalog.m XCBUniversal.m XCBRegistrySnapshot.m \
  -o build/libXcodeCommandBridge.dylib
printf 'Built: %s\n' "$(pwd)/build/libXcodeCommandBridge.dylib"
