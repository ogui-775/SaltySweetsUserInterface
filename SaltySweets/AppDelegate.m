//Created by Salty on 1/31/26.

#import "AppDelegate.h"

static __strong AppDelegate *_instance;

@interface AppDelegate ()
@property (strong) NSMutableDictionary<NSURL *, SONSWindowAuxController *> * urlToAuxController;
@property (strong) SONSWindowAuxController *creationStudioController;
@property (strong) IBOutlet NSMenu *mainMenu;
@end

@implementation AppDelegate

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
    if (!self.urlToAuxController)
        self.urlToAuxController = [NSMutableDictionary dictionary];
    
    for (NSURL * url in urls){
        if ([[url pathExtension] isEqualToString:@"sicon"]){
            SONSWindowAuxController * controller = nil;
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

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

- (IBAction)siconStudioMenuWasClicked:(NSMenuItem *)sender{
    if (!self.creationStudioController)
        self.creationStudioController = [[SONSWindowAuxController alloc] initControllerForSiconCreationContext];
    

    [self.creationStudioController.window makeKeyAndOrderFront:nil];
}

- (IBAction)newSiconWasClicked:(id)sender{
    if (!self.creationStudioController)
        self.creationStudioController = [[SONSWindowAuxController alloc] initControllerForSiconCreationContext];
    
    [self.creationStudioController.window makeKeyAndOrderFront:nil];
    
    [(SONSWindowAuxSiconCreationController *)self.creationStudioController.contentViewController newSiconWasClicked:sender];
}

- (IBAction)openSiconWasClicked:(id)sender{
    if (!self.creationStudioController)
        self.creationStudioController = [[SONSWindowAuxController alloc] initControllerForSiconCreationContext];
    

    [self.creationStudioController.window makeKeyAndOrderFront:nil];
    
    [(SONSWindowAuxSiconCreationController *)self.creationStudioController.contentViewController openSiconWasClicked:sender];
}

@end
