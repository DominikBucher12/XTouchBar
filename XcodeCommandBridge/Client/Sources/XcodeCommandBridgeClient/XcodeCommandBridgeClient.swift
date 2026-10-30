import AppKit
import CoreFoundation
import Foundation

public enum XcodeCommand: String, Sendable {
    case build, run, test, analyze, archive, clean, stop, diagnostics
}

public enum XcodeBridgeError: Error, LocalizedError {
    case xcodeNotRunning
    case ambiguousXcodeProcesses([pid_t])
    case bridgeNotLoaded(pid: pid_t)
    case transportFailure(Int32)
    case invalidResponse
    case commandFailed(code: String, detail: String)

    public var errorDescription: String? {
        switch self {
        case .xcodeNotRunning: return "Xcode is not running."
        case let .ambiguousXcodeProcesses(pids):
            return "Multiple Xcode bridges are running (\(pids)). Focus the intended Xcode window or specify its PID."
        case let .bridgeNotLoaded(pid): return "Bridge is not loaded in Xcode process \(pid)."
        case let .transportFailure(status): return "CFMessagePort error \(status)."
        case .invalidResponse: return "Invalid bridge response."
        case let .commandFailed(code, detail): return "\(code): \(detail)"
        }
    }
}

/// Synchronous IPC; invoke from a background queue if called by Touch Bar UI.
public struct XcodeCommandBridgeClient: Sendable {
    private let sendTimeout: CFTimeInterval
    private let receiveTimeout: CFTimeInterval

    public init(sendTimeout: CFTimeInterval = 2, receiveTimeout: CFTimeInterval = 10) {
        self.sendTimeout = sendTimeout
        self.receiveTimeout = receiveTimeout
    }

    @discardableResult
    public func execute(_ command: XcodeCommand) throws -> [String: Any] {
        try send(command.rawValue, xcodePID: nil)
    }

    @discardableResult
    public func execute(_ command: XcodeCommand, xcodePID: pid_t) throws -> [String: Any] {
        try send(command.rawValue, xcodePID: xcodePID)
    }

    /// Dispatch any command identifier present in the versioned registry snapshot.
    /// Dispatch success does not guarantee Xcode completed the action.
    @discardableResult
    public func execute(identifier: String, xcodePID: pid_t? = nil) throws -> [String: Any] {
        guard identifier.hasPrefix("Xcode."), !identifier.contains("\n") else {
            throw XcodeBridgeError.commandFailed(code: "invalid_identifier", detail: identifier)
        }
        return try send("id:" + identifier, xcodePID: xcodePID)
    }

    /// Compatibility with XTouchBar's existing action names. The host only accepts
    /// selectors already present in its command registry, never arbitrary messages.
    @discardableResult
    public func execute(action: String, xcodePID: pid_t? = nil) throws -> [String: Any] {
        guard action.hasSuffix(":"), action.filter({ $0 == ":" }).count == 1,
              !action.contains(where: { $0.isWhitespace }) else {
            throw XcodeBridgeError.commandFailed(code: "invalid_action", detail: action)
        }
        return try send("action:" + action, xcodePID: xcodePID)
    }

    /// Performs metadata inspection only. No commands are executed.
    public func audit(filter: String = "", xcodePID: pid_t? = nil) throws -> [String: Any] {
        try send(filter.isEmpty ? "audit" : "audit:" + filter, xcodePID: xcodePID, receiveTimeout: 30)
    }

    /// Returns catalog entries without resolving live handlers.
    public func commands(filter: String = "", xcodePID: pid_t? = nil) throws -> [String: Any] {
        try send(filter.isEmpty ? "commands" : "commands:" + filter, xcodePID: xcodePID)
    }

    @discardableResult
    private func send(_ command: String, xcodePID: pid_t?, receiveTimeout: CFTimeInterval? = nil) throws -> [String: Any] {
        let pid: pid_t
        if let xcodePID {
            pid = xcodePID
        } else {
            let apps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dt.Xcode")
                .filter { !$0.isTerminated }
            guard !apps.isEmpty else { throw XcodeBridgeError.xcodeNotRunning }
            if let active = apps.first(where: { $0.isActive }) {
                pid = active.processIdentifier
            } else {
                let ready = apps.filter {
                    CFMessagePortCreateRemote(kCFAllocatorDefault, portName($0.processIdentifier)) != nil
                }
                if ready.count > 1 {
                    throw XcodeBridgeError.ambiguousXcodeProcesses(ready.map(\.processIdentifier))
                }
                guard let app = ready.first ?? apps.first else { throw XcodeBridgeError.xcodeNotRunning }
                pid = app.processIdentifier
            }
        }
        guard let remote = CFMessagePortCreateRemote(kCFAllocatorDefault, portName(pid)) else {
            throw XcodeBridgeError.bridgeNotLoaded(pid: pid)
        }
        // Core Foundation objects returned by imported APIs are ARC-managed in Swift.
        let payload = Data(command.utf8) as CFData
        var response: Unmanaged<CFData>?
        let status = CFMessagePortSendRequest(
            remote, 1, payload, sendTimeout, receiveTimeout ?? self.receiveTimeout, CFRunLoopMode.defaultMode.rawValue, &response
        )
        guard status == kCFMessagePortSuccess else { throw XcodeBridgeError.transportFailure(status) }
        guard let returned = response?.takeRetainedValue() else { throw XcodeBridgeError.invalidResponse }
        let data = returned as Data
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let ok = json["ok"] as? Bool else { throw XcodeBridgeError.invalidResponse }
        if !ok {
            throw XcodeBridgeError.commandFailed(code: json["error"] as? String ?? "unknown",
                                                 detail: json["detail"] as? String ?? "")
        }
        return json
    }

    private func portName(_ pid: pid_t) -> CFString {
        "com.xtouchbar.commandbridge.\(pid)" as CFString
    }
}
