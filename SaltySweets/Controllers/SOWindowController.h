//Created by Salty on 8/2/26.

#import <Cocoa/Cocoa.h>

@class SONavigatorBarMaster;
@class SOBundleViewerController;
@class SOAboutController;

@interface SOWindowController : NSWindowController <NSWindowDelegate, NSToolbarDelegate>
@property (weak) IBOutlet SONavigatorBarMaster *navigatorBarMaster;
@property (weak) IBOutlet NSMenuItem *viewMenu;
@property (strong) SOBundleViewerController *packViewController;
@property (strong) SOAboutController *aboutController;
@end
