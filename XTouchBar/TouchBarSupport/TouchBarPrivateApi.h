
#import <AppKit/AppKit.h>

extern void DFRElementSetControlStripPresenceForIdentifier(NSTouchBarItemIdentifier, BOOL);
extern void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL);

@interface NSTouchBarItem (PrivateMethods)

+ (void)addSystemTrayItem:(NSTouchBarItem *)item;
+ (void)removeSystemTrayItem:(NSTouchBarItem *)item;

@end


@interface NSTouchBar (PrivateMethods)

// macOS 10.14
/// This function replaces the current touchbar with custom implementation, keep in mind it should be the same touchbar as
/// `TouchBarController.shared.touchbar` otherwise you will have a bad time.
/// - Parameters:
///   - touchBar: Touchbar instance which to present
///   - identifier: The touchbar identifier, should be no other than the app identifier revers dns+touchbar 👮🏻‍♂️
+ (void)presentSystemModalTouchBar:(NSTouchBar *)touchBar placement:(long long)placement systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier;
+ (void)presentSystemModalTouchBar:(NSTouchBar *)touchBar systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier;
+ (void)dismissSystemModalTouchBar:(NSTouchBar *)touchBar;
+ (void)minimizeSystemModalTouchBar:(NSTouchBar *)touchBar;

@end

