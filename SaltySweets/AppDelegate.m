//Created by Salty on 1/31/26.

#import "AppDelegate.h"

static __strong AppDelegate *_instance;

@interface AppDelegate ()
@property (strong) NSMutableDictionary<NSURL *, SONSWindowAuxController *> *urlToAuxController;
@property (strong) SONSWindowAuxController *creationStudioController;
@property (strong) IBOutlet NSMenu *mainMenu;
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)notification{
    self.window.title = @"SaltySweets";
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
    if (!self.urlToAuxController)
        self.urlToAuxController = [NSMutableDictionary dictionary];
    
    for (NSURL *url in urls){
        if ([[url pathExtension] isEqualToString:@"sicon"]){
            SONSWindowAuxController *controller = nil;
            if (![self.urlToAuxController objectForKey:url])
                controller = [[SONSWindowAuxController alloc] initControllerForSiconContextWithURL:url];
            
            if (controller)
                [self.urlToAuxController setObject:controller forKey:url];
            
            if ([self.urlToAuxController objectForKey:url]){
                controller = [self.urlToAuxController objectForKey:url];
                [controller.window makeKeyAndOrderFront:nil];
            }
        }
    }
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender
                    hasVisibleWindows:(BOOL)flag{
    if (!flag) {
        [self.window makeKeyAndOrderFront:nil];
    }

    return YES;
}
@end
