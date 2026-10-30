#import <AppKit/AppKit.h>
#import "XCBRuntime.h"
extern void XCBStartBridge(void);

// In-memory doubles model the live object graph. No Xcode project is opened or edited.
@interface FixtureResponder : NSObject
@property(nonatomic, strong) id nextResponder;
@end
@implementation FixtureResponder
@end

@interface FixtureEditor : FixtureResponder
@property(nonatomic) NSUInteger comments;
- (void)toggleComments:(id)sender;
@end
@implementation FixtureEditor
- (void)toggleComments:(id)sender { (void)sender; self.comments++; }
@end

@interface FixtureBadEditor : FixtureResponder
@property(nonatomic) BOOL invoked;
- (BOOL)toggleComments:(id)sender;
@end
@implementation FixtureBadEditor
- (BOOL)toggleComments:(id)sender { (void)sender; self.invoked = YES; return YES; }
@end

@interface FixtureTab : NSObject
@property(nonatomic) NSUInteger builds;
- (void)buildActiveRunContext:(id)sender;
@end
@implementation FixtureTab
- (void)buildActiveRunContext:(id)sender { (void)sender; self.builds++; }
@end

@interface FixtureController : NSObject
@property(nonatomic, strong) FixtureTab *activeWorkspaceTabController;
@end
@implementation FixtureController
@end

@interface IDEWorkspaceWindow : NSObject
@property(nonatomic, strong) id firstResponder;
@property(nonatomic, strong) FixtureController *windowController;
@property(nonatomic) NSInteger windowNumber;
@property(nonatomic, strong) id sheetParent;
@end
@implementation IDEWorkspaceWindow
@end

@interface FixtureApplication : NSApplication
@property(nonatomic, copy) NSArray<NSWindow *> *windows;
@property(nonatomic, strong) NSWindow *keyWindow;
@property(nonatomic, strong) NSWindow *mainWindow;
@end
@implementation FixtureApplication
@synthesize windows = _windows;
@synthesize keyWindow = _keyWindow;
@synthesize mainWindow = _mainWindow;
@end

static void Check(BOOL condition, NSString *description) {
    if (!condition) { NSLog(@"FAIL: %@", description); exit(1); }
    printf("PASS: %s\n", description.UTF8String);
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        FixtureApplication *app = [FixtureApplication sharedApplication];
        FixtureTab *tab = [FixtureTab new];
        FixtureController *controller = [FixtureController new];
        controller.activeWorkspaceTabController = tab;
        FixtureEditor *editor = [FixtureEditor new];
        IDEWorkspaceWindow *window = [IDEWorkspaceWindow new];
        window.windowNumber = 1;
        window.windowController = controller;
        window.firstResponder = editor;
        app.windows = (id)@[window];
        app.keyWindow = (id)window;

        if (argc > 1 && strcmp(argv[1], "--serve") == 0) {
            XCBStartBridge();
            puts("READY"); fflush(stdout);
            CFRunLoopRun();
            return 0;
        }

        NSDictionary *reply = XCBProcessCommand(@"diagnostics");
        Check([reply[@"ok"] boolValue] && [reply[@"hasActiveTab"] boolValue], @"diagnostics finds workspace tab");
        reply = XCBProcessCommand(@"commands");
        Check([reply[@"count"] unsignedIntegerValue] == 512, @"all 512 registry entries are present");
        reply = XCBProcessCommand(@"audit:CommentUncomment");
        Check([reply[@"entries"] count] == 1 && [reply[@"entries"][0][@"available"] boolValue], @"audit resolves editor handler");
        Check(editor.comments == 0 && tab.builds == 0, @"catalog and audit never execute actions");
        reply = XCBProcessCommand(@"id:Xcode.IDEPegasusSourceEditor.CmdDefinition.CommentUncomment");
        Check([reply[@"ok"] boolValue] && editor.comments == 1, @"identifier dispatch reaches editor");
        reply = XCBProcessCommand(@"action:toggleComments:");
        Check([reply[@"ok"] boolValue] && editor.comments == 2, @"existing XTouchBar action names use registry");
        reply = XCBProcessCommand(@"id:Xcode.IDEKit.CmdDefinition.Build");
        Check([reply[@"ok"] boolValue] && tab.builds == 1 && [reply[@"route"] isEqual:@"workspaceTab"], @"universal Build reaches tab controller");
        reply = XCBProcessCommand(@"build");
        Check([reply[@"ok"] boolValue] && tab.builds == 2, @"compatibility Build uses same selected workspace");
        reply = XCBProcessCommand(@"action:arbitraryMethod:");
        Check([reply[@"error"] isEqual:@"unknown_identifier"], @"arbitrary selectors are rejected");

        FixtureBadEditor *bad = [FixtureBadEditor new];
        window.firstResponder = bad;
        reply = XCBProcessCommand(@"action:toggleComments:");
        Check(![reply[@"ok"] boolValue] && !bad.invoked, @"incompatible return type is never invoked");

        FixtureResponder *cycle = [FixtureResponder new];
        cycle.nextResponder = cycle;
        window.firstResponder = cycle;
        reply = XCBProcessCommand(@"action:toggleComments:");
        Check(![reply[@"ok"] boolValue], @"responder cycle terminates without dispatch");
        cycle.nextResponder = nil;

        IDEWorkspaceWindow *other = [IDEWorkspaceWindow new];
        other.firstResponder = editor;
        other.windowNumber = 2;
        app.windows = (id)@[window, other];
        reply = XCBProcessCommand(@"action:toggleComments:");
        Check(![reply[@"ok"] boolValue] && editor.comments == 2, @"missing handler never falls through to a different workspace");
        app.keyWindow = nil;
        reply = XCBProcessCommand(@"action:toggleComments:");
        Check([reply[@"error"] isEqual:@"ambiguous_workspace"], @"ambiguous workspace selection fails explicitly");

        app.windows = @[];
        reply = XCBProcessCommand(@"build");
        Check([reply[@"error"] isEqual:@"no_workspace_tab"], @"missing workspace returns diagnostic error");
        dispatch_semaphore_t completed = dispatch_semaphore_create(0);
        __block NSDictionary *backgroundReply;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            backgroundReply = XCBProcessCommand(@"build");
            dispatch_semaphore_signal(completed);
        });
        dispatch_semaphore_wait(completed, DISPATCH_TIME_FOREVER);
        Check([backgroundReply[@"error"] isEqual:@"wrong_thread"], @"UI dispatch from a background thread is rejected");
        puts("Host tests passed.");
    }
    return 0;
}
