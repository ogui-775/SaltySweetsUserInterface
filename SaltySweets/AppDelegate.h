//Created by Salty on 1/31/26.

#import <Cocoa/Cocoa.h>
#import <SharedBundles/SharedBundles.h>

#import "SOViewPane.h"
#import "../SOAuxWinds/Controllers/SONSWindowAuxController.h"
#import "../SOAuxWinds/Controllers/SONSWindowAuxSiconCreationController.h"
#import "Native/Controllers/SOWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSToolbarDelegate>
@property (strong) IBOutlet NSWindow *window;
@end
