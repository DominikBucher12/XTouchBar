import Foundation
import XcodeCommandBridgeClient

// A small client for inspecting the entire registry without adding hundreds of UI buttons.
var arguments = Array(CommandLine.arguments.dropFirst())
var pid: pid_t?
if let index = arguments.firstIndex(of: "--pid") {
    guard arguments.indices.contains(index + 1), let value = Int32(arguments[index + 1]), value > 0 else {
        fputs("--pid requires a positive process ID\n", stderr)
        exit(2)
    }
    pid = value
    arguments.removeSubrange(index...index + 1)
}

do {
    let bridge = XcodeCommandBridgeClient()
    let reply: [String: Any]
    switch arguments.first ?? "diagnostics" {
    case "diagnostics":
        if let pid { reply = try bridge.execute(.diagnostics, xcodePID: pid) } else { reply = try bridge.execute(.diagnostics) }
    case "commands": reply = try bridge.commands(filter: arguments.dropFirst().joined(separator: " "), xcodePID: pid)
    case "audit": reply = try bridge.audit(filter: arguments.dropFirst().joined(separator: " "), xcodePID: pid)
    case "execute" where arguments.count == 2:
        reply = try bridge.execute(identifier: arguments[1], xcodePID: pid)
    case "action" where arguments.count == 2:
        reply = try bridge.execute(action: arguments[1], xcodePID: pid)
    default:
        fputs("Usage: xcb [--pid PID] diagnostics|commands [filter]|audit [filter]|execute IDENTIFIER|action SELECTOR\n", stderr)
        exit(2)
    }
    let data = try JSONSerialization.data(withJSONObject: reply, options: [.prettyPrinted, .sortedKeys])
    print(String(decoding: data, as: UTF8.self))
} catch {
    fputs("\(error.localizedDescription)\n", stderr)
    exit(1)
}
