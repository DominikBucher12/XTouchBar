#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <unistd.h>

// Read-only discovery. Run in the Xcode process on the main thread.
static NSString *XCBIdentifierForAction(SEL action) {
    if (!action) return nil;
    Class manager = objc_getClass("IDECommandManager");
    if (!manager) return nil;
    SEL mapping = sel_registerName("_commandDefinitionIdentifierForSelector:");
    Method method = class_getClassMethod(manager, mapping);
    if (!method || method_getNumberOfArguments(method) != 3) return nil;
    char returnType[32] = {0}, argumentType[32] = {0};
    method_getReturnType(method, returnType, sizeof(returnType));
    method_getArgumentType(method, 2, argumentType, sizeof(argumentType));
    if (returnType[0] != '@' || argumentType[0] != ':') return nil;
    @try {
        id (*call)(id, SEL, SEL) = (id (*)(id, SEL, SEL))method_getImplementation(method);
        id value = call((id)manager, mapping, action);
        return [value isKindOfClass:NSString.class] ? value : (value ? [value description] : nil);
    } @catch (__unused NSException *exception) { return nil; }
}

static void XCBWalkMenu(NSMenu *menu, NSString *prefix, NSMutableArray *output, NSUInteger depth) {
    if (!menu || depth > 16) return;
    for (NSMenuItem *item in menu.itemArray) {
        if (item.isSeparatorItem) continue;
        NSString *title = item.title ?: @"";
        NSString *path = prefix.length ? [prefix stringByAppendingFormat:@" > %@", title] : title;
        NSString *selectorName = item.action ? NSStringFromSelector(item.action) : @"";
        NSString *identifier = XCBIdentifierForAction(item.action);
        [output addObject:@{
            @"path": path,
            @"title": title,
            @"selector": selectorName,
            @"commandIdentifier": identifier ?: [NSNull null],
            @"enabled": @(item.isEnabled),
            @"hidden": @(item.isHidden),
            @"hasSubmenu": @(item.hasSubmenu),
            @"keyEquivalent": item.keyEquivalent ?: @""
        }];
        if (item.hasSubmenu) XCBWalkMenu(item.submenu, path, output, depth + 1);
    }
}

static NSArray *XCBCandidateMethods(void) {
    NSArray<NSString *> *classNames = @[
        @"IDEWorkspaceTabController", @"IDEWorkspaceWindowController",
        @"IDESourceCodeEditor", @"IDESourceCodeEditorView", @"IDESourceEditorView",
        @"DVTSourceTextView", @"IDEApplication"
    ];
    NSArray<NSString *> *needles = @[
        @"comment", @"fold", @"unfold", @"scope", @"fix", @"definition",
        @"jump", @"reveal", @"navigator", @"rename", @"editall", @"editAll"
    ];
    NSMutableArray *output = [NSMutableArray array];
    for (NSString *className in classNames) {
        Class cls = objc_getClass(className.UTF8String);
        if (!cls) continue;
        // Walk inherited instance methods too; guard duplicates.
        NSMutableSet *seen = [NSMutableSet set];
        for (Class cursor = cls; cursor; cursor = class_getSuperclass(cursor)) {
            unsigned int count = 0;
            Method *methods = class_copyMethodList(cursor, &count);
            for (unsigned int i = 0; i < count; i++) {
                NSString *name = NSStringFromSelector(method_getName(methods[i]));
                NSString *lower = name.lowercaseString;
                BOOL matches = NO;
                for (NSString *needle in needles) {
                    if ([lower containsString:needle.lowercaseString]) { matches = YES; break; }
                }
                if (matches && ![seen containsObject:name]) {
                    [seen addObject:name];
                    NSString *identifier = XCBIdentifierForAction(method_getName(methods[i]));
                    [output addObject:@{
                        @"queryClass": className,
                        @"declaringClass": NSStringFromClass(cursor),
                        @"selector": name,
                        @"typeEncoding": [NSString stringWithUTF8String:method_getTypeEncoding(methods[i]) ?: ""],
                        @"commandIdentifier": identifier ?: [NSNull null]
                    }];
                }
            }
            free(methods);
        }
    }
    return output;
}

__attribute__((visibility("default"))) NSString *XCBWriteCommandCatalog(void) {
    if (![NSThread isMainThread]) return @"ERROR: Call on Xcode main thread";
    @try {
        NSMutableArray *menuItems = [NSMutableArray array];
        XCBWalkMenu(NSApp.mainMenu, @"", menuItems, 0);
        NSDictionary *root = @{
            @"timestamp": [NSDate.date description],
            @"xcodeVersion": [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"unknown",
            @"xcodeBuild": [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"unknown",
            @"pid": @(getpid()),
            @"menuItems": menuItems,
            @"candidateMethods": XCBCandidateMethods(),
            @"notes": @"Command identifiers are inferred from the private IDECommandManager selector mapper. Menu availability and actions are context-sensitive; candidate runtime methods are not verified executable commands."
        };
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys error:&error];
        if (!data) return [@"ERROR: JSON: " stringByAppendingString:error.localizedDescription ?: @"unknown"];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"XcodeCommandCatalog-%d.json", getpid()]];
        if (![data writeToFile:path options:NSDataWritingAtomic error:&error])
            return [@"ERROR: WRITE: " stringByAppendingString:error.localizedDescription ?: @"unknown"];
        return path;
    } @catch (NSException *exception) {
        return [@"ERROR: EXCEPTION: " stringByAppendingString:exception.reason ?: exception.name];
    }
}
