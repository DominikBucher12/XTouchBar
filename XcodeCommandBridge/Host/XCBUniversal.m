#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "XCBRuntime.h"

extern NSArray<NSDictionary *> *XCBRegistrySnapshot(void);

typedef void (*XCBVoidAction)(id, SEL, id);

static NSDictionary *XCBFailure(NSString *code, NSString *detail) {
    return @{ @"ok": @NO, @"error": code ?: @"error", @"detail": detail ?: @"" };
}

// Captures where the action will actually be delivered. Do not mutate focus or enumerate unrelated windows.
static NSDictionary *XCBResolveTarget(NSString *selectorName) {
    SEL sel = NSSelectorFromString(selectorName);
    NSWindow *selected = XCBSelectedWorkspaceWindow();
    for (NSWindow *window in selected ? @[selected] : @[]) {
        id responder = window.firstResponder;
        NSMutableSet<NSValue *> *visited = [NSMutableSet set];
        NSUInteger n = 0;
        while (responder && n++ < 128) {
            NSValue *ptr = [NSValue valueWithPointer:(__bridge void *)responder];
            if ([visited containsObject:ptr]) break;
            [visited addObject:ptr];
            if (XCBIsVoidObjectAction(responder, sel)) {
                return @{ @"target": responder, @"route": @"responder", @"window": window };
            }
            responder = XCBObjectProperty(responder, "nextResponder");
        }
        id controller = XCBObjectProperty(window, "windowController");
        id tab = XCBObjectProperty(controller, "activeWorkspaceTabController");
        if (XCBIsVoidObjectAction(tab, sel)) {
            return @{ @"target": tab, @"route": @"workspaceTab", @"window": window };
        }
        if (XCBIsVoidObjectAction(controller, sel)) {
            return @{ @"target": controller, @"route": @"workspaceController", @"window": window };
        }
        if (XCBIsVoidObjectAction(window, sel)) {
            return @{ @"target": window, @"route": @"workspaceWindow", @"window": window };
        }
    }
    if (XCBIsVoidObjectAction(NSApp, sel)) {
        return @{ @"target": NSApp, @"route": @"application" };
    }
    return nil;
}

static NSDictionary *XCBEntryForIdentifier(NSString *identifier) {
    for (NSDictionary *entry in XCBRegistrySnapshot()) {
        if ([entry[@"id"] isEqualToString:identifier]) return entry;
    }
    return nil;
}

static NSDictionary *XCBAuditEntry(NSDictionary *entry) {
    NSString *selector = entry[@"selector"];
    NSDictionary *resolved = XCBResolveTarget(selector);
    id target = resolved[@"target"];
    NSMutableDictionary *result = [entry mutableCopy];
    result[@"available"] = target ? @YES : @NO;
    result[@"route"] = resolved[@"route"] ?: [NSNull null];
    result[@"targetClass"] = target ? NSStringFromClass([target class]) : [NSNull null];
    // Available means ONLY: a receiver with a compatible ABI was found.
    // It does not mean enabled, safe, or semantically valid in the editor.
    result[@"enabled"] = [NSNull null];
    return result;
}

NSDictionary *XCBHandleUniversalCommand(NSString *rawCommand) {
    if (![NSThread isMainThread]) return XCBFailure(@"wrong_thread", @"Host requests must execute on Xcode main thread");
    if ([rawCommand isEqualToString:@"audit"] || [rawCommand hasPrefix:@"audit:"]) {
        NSString *filter = [rawCommand hasPrefix:@"audit:"] ? [rawCommand substringFromIndex:6] : @"";
        NSMutableArray *results = [NSMutableArray array];
        NSUInteger total = 0;
        for (NSDictionary *entry in XCBRegistrySnapshot()) {
            NSString *searchable = [NSString stringWithFormat:@"%@ %@ %@ %@", entry[@"id"], entry[@"selector"], entry[@"title"], entry[@"path"]];
            if (filter.length && [searchable rangeOfString:filter options:NSCaseInsensitiveSearch].location == NSNotFound) continue;
            total++;
            [results addObject:XCBAuditEntry(entry)];
        }
        return @{ @"ok": @YES, @"snapshotVersion": @"26.5", @"snapshotBuild": @"24943",
                  @"matchingCount": @(total), @"entries": results,
                  @"disclaimer": @"availability means compatible handler found, not command enabled or execution verified" };
    }
    if ([rawCommand isEqualToString:@"commands"] || [rawCommand hasPrefix:@"commands:"]) {
        NSString *filter = [rawCommand hasPrefix:@"commands:"] ? [rawCommand substringFromIndex:9] : @"";
        NSMutableArray *matches = [NSMutableArray array];
        for (NSDictionary *entry in XCBRegistrySnapshot()) {
            NSString *searchable = [NSString stringWithFormat:@"%@ %@ %@", entry[@"id"], entry[@"title"], entry[@"path"]];
            if (!filter.length || [searchable rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) [matches addObject:entry];
        }
        return @{ @"ok": @YES, @"entries": matches, @"count": @(matches.count) };
    }
    NSDictionary *entry = nil;
    if ([rawCommand hasPrefix:@"id:"]) {
        entry = XCBEntryForIdentifier([rawCommand substringFromIndex:3]);
    } else if ([rawCommand hasPrefix:@"action:"]) {
        NSString *action = [rawCommand substringFromIndex:7];
        for (NSDictionary *candidate in XCBRegistrySnapshot()) {
            if ([candidate[@"selector"] isEqualToString:action]) { entry = candidate; break; }
        }
    } else {
        return XCBFailure(@"unknown_command", rawCommand);
    }
    if (!entry) return XCBFailure(@"unknown_identifier", rawCommand);
    NSString *identifier = entry[@"id"];
    NSString *selectorName = entry[@"selector"];
    NSDictionary *resolved = XCBResolveTarget(selectorName);
    id target = resolved[@"target"];
    if (!target) {
        if (!XCBSelectedWorkspaceWindow() && XCBWorkspaceWindows().count > 1)
            return XCBFailure(@"ambiguous_workspace", @"Focus the intended Xcode workspace window and retry.");
        return XCBFailure(@"handler_unavailable", [NSString stringWithFormat:@"No compatible handler for %@ in the selected workspace", selectorName]);
    }
    @try {
        ((XCBVoidAction)objc_msgSend)(target, NSSelectorFromString(selectorName), nil);
        return @{ @"ok": @YES, @"status": @"dispatched", @"identifier": identifier,
                  @"selector": selectorName, @"route": resolved[@"route"],
                  @"targetClass": NSStringFromClass([target class]),
                  @"warning": @"Dispatch does not guarantee action succeeded" };
    } @catch (NSException *exception) {
        return XCBFailure(@"objc_exception", exception.reason ?: exception.name);
    }
}

// Useful for manually inspecting results without an IPC client.
__attribute__((visibility("default"))) NSDictionary *XCBLLDBRequest(NSString *request) {
    return XCBProcessCommand(request);
}
