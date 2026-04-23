//Created by Salty on 4/18/26.

#import "SONSWindowAuxSpawner.h"

@implementation SONSWindowAuxSpawner
+ (SONSWindowAux *)spawnAuxWindowForSiconWithURL:(NSURL *)url{
    SONSWindowAuxContextSicon * ctx = [SONSWindowAuxContextSicon siconViewerContextWithURL:url];
    
    if (!ctx)
        return nil;
    
    SONSWindowAux * wind = [[SONSWindowAux alloc] initWithContentRect:CGRectMake(CGRectGetMidX(NSScreen.mainScreen.frame) - 125,
                                                                                 CGRectGetMidY(NSScreen.mainScreen.frame) - 250,
                                                                                 250,
                                                                                 500)
                                                            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
                                                              backing:NSBackingStoreBuffered
                                                                defer:NO
                                                              context:ctx];
    
    if (!wind)
        return nil;

    [wind setContentMinSize:CGSizeMake(250, 500)];
    [wind makeKeyAndOrderFront:nil];
    
    return wind;
}

+ (SONSWindowAux *)spawnAuxWindowForSiconCreation{
    SONSWindowAuxContextSiconCreation * ctx = [SONSWindowAuxContextSiconCreation siconCreationContext];
    
    if (!ctx)
        return nil;
    
    SONSWindowAux * wind = [[SONSWindowAux alloc] initWithContentRect:CGRectMake(CGRectGetMidX(NSScreen.mainScreen.frame) - 500,
                                                                                 CGRectGetMidY(NSScreen.mainScreen.frame) - 1000,
                                                                                 1000,
                                                                                 2000)
                                                            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskClosable
                                                              backing:NSBackingStoreBuffered
                                                                defer:NO
                                                              context:ctx];
    
    if (!wind)
        return nil;
    
    [wind setContentMinSize:CGSizeMake(1000, 2000)];
    [wind makeKeyAndOrderFront:nil];
    
    return wind;
}
@end
