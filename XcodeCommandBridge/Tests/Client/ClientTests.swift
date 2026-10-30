import CoreFoundation
import Foundation
import XCTest
@testable import XcodeCommandBridgeClient

private final class PortFixture: @unchecked Sendable {
    let pid = Int32.random(in: 100_000...1_000_000)
    private let ready = DispatchSemaphore(value: 0)
    private let done = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var runLoop: CFRunLoop?
    private var received: [String] = []
    var response = Data("{\"ok\":true,\"status\":\"dispatched\"}".utf8)
    var delay: TimeInterval = 0

    var commands: [String] {
        lock.lock()
        defer { lock.unlock() }
        return received
    }

    func start() {
        Thread.detachNewThread {
            var context = CFMessagePortContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
            let port = CFMessagePortCreateLocal(
                kCFAllocatorDefault, "com.xtouchbar.commandbridge.\(self.pid)" as CFString,
                { _, _, data, info in
                    let fixture = Unmanaged<PortFixture>.fromOpaque(info!).takeUnretainedValue()
                    fixture.lock.lock()
                    fixture.received.append(String(decoding: data! as Data, as: UTF8.self))
                    fixture.lock.unlock()
                    if fixture.delay > 0 { Thread.sleep(forTimeInterval: fixture.delay) }
                    return Unmanaged.passRetained(fixture.response as CFData)
                }, &context, nil
            )!
            let source = CFMessagePortCreateRunLoopSource(kCFAllocatorDefault, port, 0)!
            self.runLoop = CFRunLoopGetCurrent()
            CFRunLoopAddSource(self.runLoop, source, .defaultMode)
            self.ready.signal()
            CFRunLoopRun()
            CFMessagePortInvalidate(port)
            CFRunLoopRemoveSource(self.runLoop, source, .defaultMode)
            self.done.signal()
        }
        XCTAssertEqual(ready.wait(timeout: .now() + 5), .success)
    }

    func stop() {
        if let runLoop {
            CFRunLoopStop(runLoop)
            CFRunLoopWakeUp(runLoop)
        }
        XCTAssertEqual(done.wait(timeout: .now() + 5), .success)
    }
}

final class ClientTests: XCTestCase {
    private var fixture: PortFixture!
    private let client = XcodeCommandBridgeClient()

    override func setUp() {
        fixture = PortFixture()
        fixture.start()
    }

    override func tearDown() {
        fixture.stop()
        fixture = nil
    }

    func testIdentifiersAndLegacySelectorsUseSameTransport() throws {
        try client.execute(identifier: "Xcode.IDEPegasusSourceEditor.CmdDefinition.CommentUncomment", xcodePID: fixture.pid)
        try client.execute(action: "toggleComments:", xcodePID: fixture.pid)
        XCTAssertEqual(fixture.commands, ["id:Xcode.IDEPegasusSourceEditor.CmdDefinition.CommentUncomment", "action:toggleComments:"])
    }

    func testAuditAndCatalogDoNotSendExecutionRequests() throws {
        _ = try client.commands(filter: "Navigator", xcodePID: fixture.pid)
        _ = try client.audit(filter: "Fold", xcodePID: fixture.pid)
        XCTAssertEqual(fixture.commands, ["commands:Navigator", "audit:Fold"])
    }

    func testHostFailuresPreserveCodeAndDetail() {
        fixture.response = Data("{\"ok\":false,\"error\":\"handler_unavailable\",\"detail\":\"No source editor\"}".utf8)
        XCTAssertThrowsError(try client.execute(.build, xcodePID: fixture.pid)) {
            guard case let XcodeBridgeError.commandFailed(code, detail) = $0 else { return XCTFail("\($0)") }
            XCTAssertEqual(code, "handler_unavailable")
            XCTAssertEqual(detail, "No source editor")
        }
        XCTAssertEqual(fixture.commands.count, 1)
    }

    func testInvalidResponseIsRejected() {
        fixture.response = Data("not json".utf8)
        XCTAssertThrowsError(try client.execute(.diagnostics, xcodePID: fixture.pid)) {
            guard case XcodeBridgeError.invalidResponse = $0 else { return XCTFail("\($0)") }
        }
    }

    func testMissingPortReturnsActionableError() {
        XCTAssertThrowsError(try client.execute(.build, xcodePID: Int32.max)) {
            guard case XcodeBridgeError.bridgeNotLoaded(pid: Int32.max) = $0 else { return XCTFail("\($0)") }
        }
    }

    func testTimeoutDoesNotRetryPotentiallyExecutedAction() {
        fixture.delay = 0.2
        let impatient = XcodeCommandBridgeClient(sendTimeout: 1, receiveTimeout: 0.02)
        XCTAssertThrowsError(try impatient.execute(.build, xcodePID: fixture.pid)) {
            guard case XcodeBridgeError.transportFailure = $0 else { return XCTFail("\($0)") }
        }
        XCTAssertEqual(fixture.commands, ["build"])
    }

    func testMalformedCommandsNeverReachHost() {
        XCTAssertThrowsError(try client.execute(identifier: "not-an-id", xcodePID: fixture.pid))
        XCTAssertThrowsError(try client.execute(action: "setValue:forKey:", xcodePID: fixture.pid))
        XCTAssertTrue(fixture.commands.isEmpty)
    }
}
