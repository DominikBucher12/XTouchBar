#!/usr/bin/env bash
set -euo pipefail
bridge_root="$(cd "$(dirname "$0")/.." && pwd)"
test_output="$(mktemp -d "${TMPDIR:-/tmp}/xtouchbar-host-tests.XXXXXX")"
test_app="$test_output/BridgeFixture.app"
mkdir -p "$test_app/Contents/MacOS"
cat > "$test_app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.apple.dt.Xcode</string>
<key>CFBundleExecutable</key><string>BridgeFixture</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
xcrun clang -fobjc-arc -Wall -Wextra -Werror -I "$bridge_root/Host" \
  -framework AppKit -framework Foundation -framework CoreFoundation \
  "$bridge_root/Tests/Host/HostTests.m" "$bridge_root/Host/XcodeCommandBridge.m" \
  "$bridge_root/Host/XCBRuntime.m" "$bridge_root/Host/XCBUniversal.m" \
  "$bridge_root/Host/XCBRegistrySnapshot.m" \
  -o "$test_app/Contents/MacOS/BridgeFixture"
"$test_app/Contents/MacOS/BridgeFixture"
if [[ $# -gt 0 ]]; then
  python3 "$bridge_root/Tests/test-ipc.py" "$test_app/Contents/MacOS/BridgeFixture" "$1"
fi
printf 'Fixture for IPC checks: %s\n' "$test_app/Contents/MacOS/BridgeFixture"
