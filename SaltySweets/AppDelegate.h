//Created by Salty on 1/31/26.

#import <Cocoa/Cocoa.h>
#import <SharedBundles/SharedBundles.h>

#import "SOViewPane.h"
#import "Auxiliary Windows/Controllers/SONSWindowAuxController.h"
#import "Auxiliary Windows/Controllers/SONSWindowAuxSiconCreationController.h"
#import "Controllers/SOWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSToolbarDelegate>
@property (strong) IBOutlet NSWindow *window;
@end
