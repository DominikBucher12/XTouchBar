import Foundation
import XcodeCommandBridgeClient

// Inside your existing XTouchBar button action:
func buildButtonTapped() {
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            let reply = try XcodeCommandBridgeClient().execute(.build)
            print("Xcode bridge:", reply)
        } catch {
            NSLog("XcodeCommandBridge failed: %@", error.localizedDescription)
            // Never retry via keyboard after an IPC timeout: the action may have run.
        }
    }
}
