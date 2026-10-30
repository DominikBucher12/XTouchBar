import AppKit
import XcodeCommandBridgeClient

/// Serial IPC keeps rapid Touch Bar taps in order without blocking the app's UI.
final class XcodeCommandDispatcher {
  enum Backend: String {
    case direct
    case keyboard
  }

  static let shared = XcodeCommandDispatcher()
  private let queue = DispatchQueue(label: "com.dominikbucher.XTouchBar.commands", qos: .userInitiated)
  private let bridge = XcodeCommandBridgeClient()
  private var showingError = false

  var backend: Backend {
    get { Backend(rawValue: UserDefaults.standard.string(forKey: "CommandBackend") ?? "") ?? .direct }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: "CommandBackend") }
  }

  func perform(_ shortcut: Shortcut) {
    if backend == .keyboard {
      MasterMind.perform(shortcut)
      return
    }
    queue.async {
      do {
        if let identifier = shortcut.commandIdentifier {
          try self.bridge.execute(identifier: identifier)
        } else {
          try self.bridge.execute(action: shortcut.id)
        }
      } catch {
        NSLog("Xcode command %@ failed: %@", shortcut.id, error.localizedDescription)
        DispatchQueue.main.async { self.showError(error, command: shortcut.itemDescription) }
      }
    }
  }

  func showBridgeStatus() {
    queue.async {
      do {
        let reply = try self.bridge.execute(.diagnostics)
        DispatchQueue.main.async {
          let alert = NSAlert()
          alert.messageText = "Xcode Command Bridge"
          let version = reply["version"] ?? "unknown"
          let pid = reply["pid"] ?? "unknown"
          let windows = reply["workspaceWindows"] ?? 0
          alert.informativeText = "Connected to Xcode \(version) (PID \(pid)).\nWorkspace windows: \(windows)."
          alert.runModal()
        }
      } catch {
        DispatchQueue.main.async { self.showError(error, command: "Connect to Xcode") }
      }
    }
  }

  private func showError(_ error: Error, command: String) {
    guard !showingError else { return }
    showingError = true
    defer { showingError = false }
    let alert = NSAlert()
    alert.messageText = "Could not run \(command)"
    alert.informativeText = error.localizedDescription
    if case XcodeBridgeError.bridgeNotLoaded = error {
      alert.informativeText += "\n\nLoad the host library into XcodeResearch as described in XcodeCommandBridge/README.md."
    }
    alert.runModal()
  }
}
