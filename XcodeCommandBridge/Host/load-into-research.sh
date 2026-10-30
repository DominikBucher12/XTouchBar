#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
research_app="/Applications/XcodeResearch.app"
workspace="$repo_root/XTouchBar.xcworkspace"
dylib="$repo_root/XcodeCommandBridge/Host/build/libXcodeCommandBridge.dylib"

if [[ ! -d "$research_app" ]]; then
  echo "XcodeResearch was not found at $research_app" >&2
  exit 1
fi

bash "$repo_root/XcodeCommandBridge/Host/build.sh"
open -a "$research_app" "$workspace"

pid=""
for _ in $(seq 1 120); do
  pid="$(pgrep -f "^$research_app/Contents/MacOS/Xcode$" | head -1 || true)"
  [[ -n "$pid" ]] && break
  sleep 1
done
if [[ -z "$pid" ]]; then
  echo "XcodeResearch did not start." >&2
  exit 1
fi

lldb_output="$(lldb -b \
  -o "process attach --pid $pid" \
  -o 'expr -l objc++ -- @import Darwin;' \
  -o "expr -l objc++ -O -- (void *)dlopen(\"$dylib\", 2)" \
  -o "expr -l objc++ -O -- ((void (*)(void))dlsym(RTLD_DEFAULT, \"XCBStartBridge\"))()" \
  -o detach -o quit 2>&1)" || {
    printf '%s\n' "$lldb_output" >&2
    exit 1
  }
printf '%s\n' "$lldb_output"
if [[ "$lldb_output" != *"Process $pid detached"* ]]; then
  echo "LLDB did not confirm that it detached from XcodeResearch." >&2
  exit 1
fi

swift run --package-path "$repo_root/XcodeCommandBridge" xcb --pid "$pid" diagnostics
