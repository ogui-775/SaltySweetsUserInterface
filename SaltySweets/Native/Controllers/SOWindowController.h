//Created by Salty on 8/2/26.

#import <Cocoa/Cocoa.h>

@class SONavigatorBarMaster;

@interface SOWindowController : NSWindowController <NSWindowDelegate, NSToolbarDelegate>
@property (weak) IBOutlet SONavigatorBarMaster *navigatorBarMaster;
@property (weak) IBOutlet NSMenuItem *viewMenu;
@end
