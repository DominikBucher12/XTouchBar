#import "XCBRuntime.h"
#import <objc/message.h>
#import <objc/runtime.h>

id XCBObjectProperty(id object, const char *getter) {
    SEL selector = sel_registerName(getter);
    if (!object || ![object respondsToSelector:selector]) return nil;
    Method method = class_getInstanceMethod(object_getClass(object), selector);
    if (!method || method_getNumberOfArguments(method) != 2) return nil;
    char type[32] = {0};
    method_getReturnType(method, type, sizeof(type));
    if (type[0] != '@') return nil;
    return ((id (*)(id, SEL))objc_msgSend)(object, selector);
}

BOOL XCBIsVoidObjectAction(id object, SEL selector) {
    if (!object || ![object respondsToSelector:selector]) return NO;
    Method method = class_getInstanceMethod(object_getClass(object), selector);
    if (!method || method_getNumberOfArguments(method) != 3) return NO;
    char result[32] = {0}, argument[32] = {0};
    method_getReturnType(method, result, sizeof(result));
    method_getArgumentType(method, 2, argument, sizeof(argument));
    return result[0] == 'v' && argument[0] == '@';
}

NSArray<NSWindow *> *XCBWorkspaceWindows(void) {
    Class workspaceClass = objc_lookUpClass("IDEWorkspaceWindow");
    if (!workspaceClass) return @[];
    NSMutableArray *windows = [NSMutableArray array];
    for (NSWindow *window in NSApp.windows) {
        if ([window isKindOfClass:workspaceClass]) [windows addObject:window];
    }
    return windows;
}

NSWindow *XCBSelectedWorkspaceWindow(void) {
    NSArray<NSWindow *> *windows = XCBWorkspaceWindows();
    if ([windows containsObject:NSApp.keyWindow]) return NSApp.keyWindow;
    if ([windows containsObject:NSApp.keyWindow.sheetParent]) return NSApp.keyWindow.sheetParent;
    if ([windows containsObject:NSApp.mainWindow]) return NSApp.mainWindow;
    // Never search another workspace for a receiver. A missing editor in the active
    // project must not cause Fix All, Build, etc. to affect a different project.
    return windows.count == 1 ? windows.firstObject : nil;
}
