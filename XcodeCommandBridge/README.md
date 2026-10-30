# XcodeCommandBridge

The direct-command backend for XTouchBar on `feature/true_power`. Restored from the
[Xcode research conversation](https://chatgpt.com/share/6ae3d047-0590-83ed-a96c-333f689324b1)
and its downloaded `XcodeCommandBridge-3.zip`, then integrated and tested on Intel macOS.

The host runs **inside Xcode**. XTouchBar sends a command identifier over a local
CFMessagePort; the host finds the existing editor responder or workspace controller,
checks the Objective-C method signature, and calls the action on Xcode's main thread.
There is no need to recreate IDEKit state or simulate keystrokes.

## Use with XTouchBar

1. Open the repository's `XTouchBar.xcworkspace` and build the XTouchBar scheme. The
   local Swift package is already connected. CocoaPods provides the existing SwiftLint
   build tool; if its files are missing, run `pod install --no-repo-update`.
2. Build the host from the repository root:

   ```sh
   bash XcodeCommandBridge/Host/build.sh
   ```

   This produces `XcodeCommandBridge/Host/build/libXcodeCommandBridge.dylib` for the
   current Mac architecture. Set `XCB_ARCH=x86_64` or `XCB_ARCH=arm64` to cross-compile;
   the library architecture must match the target Xcode process. Intel is tested.
3. Load the bridge into the prepared **XcodeResearch** copy and verify it in one step:

   ```sh
   bash XcodeCommandBridge/Host/load-into-research.sh
   ```

   The helper builds the library for this Mac, opens the workspace in XcodeResearch,
   attaches LLDB, loads the library, and prints diagnostics. To do those steps manually,
   attach LLDB to the XcodeResearch PID and use the absolute library path:

   ```lldb
   process attach --pid <XCODE_RESEARCH_PID>
   expr -l objc++ -- @import Darwin;
   expr -l objc++ -O -- (void *)dlopen("/ABSOLUTE/REPOSITORY/PATH/XcodeCommandBridge/Host/build/libXcodeCommandBridge.dylib", 2)
   continue
   ```

   `dlopen` must return a nonzero handle. The listener starts after Xcode resumes.
   A host must be loaded again after every Xcode restart; rebuilds require restarting
   the host process before loading the new library. This repository does not modify
   Xcode's signature, change security settings, or install an automatic loader.
4. Select **Bridge Status…** in XTouchBar's menu to verify the connection. The default
   **Command Backend → Direct Xcode Commands** routes the existing Touch Bar actions
   through the bridge. Build, Run, Test, Stop and Show in Navigator can be added using
   the Touch Bar customization palette.
5. Select **All Xcode Commands…** to search the full 512-command snapshot by title,
   menu path, selector, or identifier. Select a row and choose **Run in Xcode** (or
   double-click it) to dispatch that command through the loaded bridge.

**Keyboard Shortcuts (Legacy)** is an explicit alternative in that same menu.
Direct-command failures never automatically retry as keyboard events: a timed-out
request might already have executed. Only the legacy backend changes keyboard layouts
and needs the keyboard-event permissions described in the original project README.

## Catalog, audit and execution

The recovered snapshot contains **512 command identifiers** discovered in Xcode 26.5
(build 24943). It is a versioned snapshot, not a claim that every command is executable
or enabled in the current context.

The package also includes a command-line client:

```sh
swift run --package-path XcodeCommandBridge xcb --pid <PID> diagnostics
swift run --package-path XcodeCommandBridge xcb --pid <PID> commands Navigator
swift run --package-path XcodeCommandBridge xcb --pid <PID> audit Fold
swift run --package-path XcodeCommandBridge xcb --pid <PID> execute Xcode.IDEPegasusSourceEditor.CmdDefinition.CommentUncomment
```

`commands` reads the catalog. `audit` resolves compatible handlers without invoking
any action; `available: true` does not mean the command is enabled or has been tested.
A successful execution response means `status: dispatched`, not operation completion.
All replies are JSON.

Swift clients use the same API on a background queue:

```swift
import XcodeCommandBridgeClient

let bridge = XcodeCommandBridgeClient()
try bridge.execute(identifier: "Xcode.IDEPegasusSourceEditor.CmdDefinition.CommentUncomment")
let report = try bridge.audit(filter: "Fold")
let catalog = try bridge.commands(filter: "Navigator")
```

`execute(.build)` and the original Build/Run/Test compatibility API remain available.
`execute(action: "toggleComments:")` supports legacy XTouchBar selector names, but
only selectors already present in the catalog are accepted. The app supplies explicit
modern command IDs where older names changed, such as Find in Selected Group and
font size changes.

Pass `xcodePID:` to any of these APIs to select a process explicitly. Otherwise, the
client uses the active Xcode process, or the only running bridge when Xcode isn't
active. Multiple ready bridges without an active Xcode produce an ambiguity error.
Within that process the host selects the key/main workspace, or the only workspace;
it never searches another project when the selected project's handler is absent.
If several workspaces are open and none is selected, focus the intended workspace.

## Runtime discovery

`Host/XCBCommandCatalog.m` exports `XCBWriteCommandCatalog()` to capture the main menu
and relevant runtime methods from another Xcode version. With the library loaded,
on Xcode's main thread in LLDB:

```lldb
expr -l objc++ -O -- ({ @import Foundation; ((id (*)(void))dlsym((void *)dlopen("/ABSOLUTE/PATH/libXcodeCommandBridge.dylib", 2), "XCBWriteCommandCatalog"))(); })
```

It returns the path to `XcodeCommandCatalog-<PID>.json` in Xcode's temporary directory.
Discovery does not execute actions. Refreshing this report does not automatically
replace the embedded snapshot; review and regenerate the snapshot before using new IDs.

## Validation

From the repository root:

```sh
bash XcodeCommandBridge/Host/build.sh
swift test --package-path XcodeCommandBridge
bash XcodeCommandBridge/Tests/test-host.sh
# Include a real Swift → CFMessagePort → Objective-C round trip:
swift build --package-path XcodeCommandBridge
bash XcodeCommandBridge/Tests/test-host.sh "$PWD/XcodeCommandBridge/.build/debug/xcb"
xcodebuild -workspace XTouchBar.xcworkspace -scheme XTouchBar -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

The host fixture uses an isolated AppKit application with fake editor and workspace
objects; it does not open or edit any real project. Host checks cover registry size,
editor/workspace routing, incompatible signatures, responder cycles, thread affinity,
workspace ambiguity, and audits that never execute commands. Client tests exercise
transport errors, malformed replies, timeouts without retries, and command encoding.

The original conversation manually verified Build, Comment/Uncomment, Edit All in
Scope, Fix All in Scope and Jump to Definition against a real Intel Xcode process.
Automated fixture coverage does not establish that the other snapshot commands work
in every Xcode version. Private APIs and nil-sender semantics remain context-dependent.
The local CFMessagePort transport is intended for this research setup and does not
authenticate other local clients.
