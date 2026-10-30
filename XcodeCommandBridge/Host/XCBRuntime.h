#import <AppKit/AppKit.h>

NSArray<NSWindow *> *XCBWorkspaceWindows(void);
NSWindow *XCBSelectedWorkspaceWindow(void);
id XCBObjectProperty(id object, const char *getter);
BOOL XCBIsVoidObjectAction(id object, SEL selector);
NSDictionary *XCBProcessCommand(NSString *command);
