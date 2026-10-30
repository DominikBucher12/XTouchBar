#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <unistd.h>
#import "XCBRuntime.h"

extern NSDictionary *XCBHandleUniversalCommand(NSString *command);

// Loaded inside the Xcode process. No changes to the Xcode app binary required.
// All IDEKit selectors are resolved dynamically. Never link against private frameworks.

static CFMessagePortRef XCBPort = NULL;
static CFRunLoopSourceRef XCBSource = NULL;
static NSString * const XCBPrefix = @"com.xtouchbar.commandbridge.";

typedef void (*XCBAction)(id, SEL, id);

static id XCBResolveTab(void) {
    NSWindow *window = XCBSelectedWorkspaceWindow();
    id controller = XCBObjectProperty(window, "windowController");
    return XCBObjectProperty(controller, "activeWorkspaceTabController");
}

static NSDictionary *XCBError(NSString *code, NSString *detail) {
    return @{ @"ok": @NO, @"error": code, @"detail": detail ?: @"" };
}

static NSDictionary *XCBProcessCommandOnMainThread(NSString *command) {
    NSBundle *bundle = NSBundle.mainBundle;
    NSString *bundleID = bundle.bundleIdentifier ?: @"";
    if (![bundleID isEqualToString:@"com.apple.dt.Xcode"]) {
        // A re-signed research copy normally retains the same bundle identifier.
        return XCBError(@"wrong_process", [NSString stringWithFormat:@"bundle identifier: %@", bundleID]);
    }
    NSArray *windows = XCBWorkspaceWindows();
    id tab = XCBResolveTab();
    if ([command isEqualToString:@"diagnostics"]) {
        return @{ @"ok": @YES, @"pid": @(getpid()),
                  @"version": [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"unknown",
                  @"build": [bundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"unknown",
                  @"workspaceWindows": @(windows.count), @"hasActiveTab": tab ? @YES : @NO,
                  @"tabClass": tab ? NSStringFromClass([tab class]) : @"none",
                  @"selectedWindow": XCBSelectedWorkspaceWindow() ? @(XCBSelectedWorkspaceWindow().windowNumber) : [NSNull null],
                  @"protocolVersion": @1 };
    }
    if ([command isEqualToString:@"audit"] || [command hasPrefix:@"audit:"] ||
        [command isEqualToString:@"commands"] || [command hasPrefix:@"commands:"] ||
        [command hasPrefix:@"id:"] || [command hasPrefix:@"action:"]) return XCBHandleUniversalCommand(command);
    // Build verified experimentally. Other selectors were observed in the Xcode menu,
    // but their direct invocation through this bridge has NOT been validated.
    static NSDictionary<NSString *, NSString *> *actions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{ @"build": @"buildActiveRunContext:",
                     @"run": @"runActiveRunContext:",
                     @"test": @"testActiveRunContext:",
                     @"analyze": @"analyzeActiveRunContext:",
                     @"archive": @"buildAndArchiveActiveRunContext:",
                     @"clean": @"cleanActiveRunContext:",
                     @"stop": @"cancelCurrentExecution:" };
    });
    NSString *selectorName = actions[command];
    if (!selectorName) return XCBError(@"unknown_command", command);
    if (!tab) {
        if (!XCBSelectedWorkspaceWindow() && windows.count > 1)
            return XCBError(@"ambiguous_workspace", @"Focus the intended Xcode workspace window and retry.");
        return XCBError(@"no_workspace_tab", @"Open an Xcode workspace/project and select its window.");
    }
    SEL action = NSSelectorFromString(selectorName);
    if (![tab respondsToSelector:action]) return XCBError(@"unavailable", selectorName);
    if (!XCBIsVoidObjectAction(tab, action)) return XCBError(@"signature_mismatch", selectorName);
    @try {
        ((XCBAction)objc_msgSend)(tab, action, nil);
        // Dispatch succeeded; this does not assert that the build/run completed.
        return @{ @"ok": @YES, @"command": command, @"selector": selectorName,
                  @"status": @"dispatched", @"experimental": [command isEqualToString:@"build"] ? @NO : @YES };
    } @catch (NSException *exception) {
        return XCBError(@"objc_exception", exception.reason ?: exception.name);
    }
}

NSDictionary *XCBProcessCommand(NSString *command) {
    if (![NSThread isMainThread]) return XCBError(@"wrong_thread", @"Host requests must execute on Xcode main thread.");
    @try {
        return XCBProcessCommandOnMainThread(command);
    } @catch (NSException *exception) {
        return XCBError(@"objc_exception", exception.reason ?: exception.name);
    }
}

static CFDataRef XCBMessageHandler(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info) {
    @autoreleasepool {
        (void)local; (void)info;
        NSDictionary *reply;
        if (msgid != 1 || !data || CFDataGetLength(data) > 8192) {
            reply = XCBError(@"invalid_request", @"Expected UTF-8 command with message ID 1.");
        } else {
            NSString *cmd = [[NSString alloc] initWithData:(__bridge NSData *)data encoding:NSUTF8StringEncoding];
            reply = cmd ? XCBProcessCommand(cmd) : XCBError(@"invalid_encoding", @"UTF-8 required");
        }
        NSData *json = [NSJSONSerialization dataWithJSONObject:reply options:0 error:NULL];
        return json ? CFBridgingRetain(json) : NULL;
    }
}

static void XCBStart(void) {
    if (XCBPort) return;
    NSString *portName = [XCBPrefix stringByAppendingFormat:@"%d", getpid()];
    CFMessagePortContext context = {0, NULL, NULL, NULL, NULL};
    Boolean shouldFreeInfo = false;
    XCBPort = CFMessagePortCreateLocal(kCFAllocatorDefault, (__bridge CFStringRef)portName,
                                       XCBMessageHandler, &context, &shouldFreeInfo);
    if (!XCBPort) { NSLog(@"[XcodeCommandBridge] Failed to create port %@", portName); return; }
    XCBSource = CFMessagePortCreateRunLoopSource(kCFAllocatorDefault, XCBPort, 0);
    if (!XCBSource) {
        CFMessagePortInvalidate(XCBPort); CFRelease(XCBPort); XCBPort = NULL;
        NSLog(@"[XcodeCommandBridge] Failed to create run loop source"); return;
    }
    CFRunLoopAddSource(CFRunLoopGetMain(), XCBSource, kCFRunLoopCommonModes);
    NSLog(@"[XcodeCommandBridge] Ready on %@", portName);
}

__attribute__((constructor)) static void XCBInitialize(void) {
    // The constructor can execute on a debugger-selected thread. UI objects must be
    // inspected on the main thread. dispatch_async avoids deadlocking LLDB evaluation.
    dispatch_async(dispatch_get_main_queue(), ^{ XCBStart(); });
}

// Optional for testing from LLDB; starts port without needing a constructor callback.
__attribute__((visibility("default"))) void XCBStartBridge(void) {
    if ([NSThread isMainThread]) XCBStart();
    else dispatch_async(dispatch_get_main_queue(), ^{ XCBStart(); });
}

__attribute__((visibility("default"))) void XCBStopBridge(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (XCBSource) { CFRunLoopRemoveSource(CFRunLoopGetMain(), XCBSource, kCFRunLoopCommonModes); CFRelease(XCBSource); XCBSource = NULL; }
        if (XCBPort) { CFMessagePortInvalidate(XCBPort); CFRelease(XCBPort); XCBPort = NULL; }
    });
}
