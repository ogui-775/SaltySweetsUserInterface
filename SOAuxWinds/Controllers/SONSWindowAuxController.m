//Created by Salty on 4/18/26.

#import "SONSWindowAuxController.h"

@implementation SONSWindowAuxController
- (instancetype)initControllerForSiconContextWithURL:(NSURL *)url{
    if (self = [super init]){
        self.window = [SONSWindowAuxSpawner spawnAuxWindowForSiconWithURL:url];
        if (self.window){
            SONSWindowAuxContextSicon * ctx = (SONSWindowAuxContextSicon *)[(SONSWindowAux *)self.window auxiliaryContext];
            self.window.contentViewController = [[SONSWindowAuxSiconController alloc] initWithNibName:@"SONSWindowAuxSiconView" bundle:nil context:ctx];
            self.window.title = [ctx.loadedSicon.bundleURL lastPathComponent];
            self.window.titlebarAppearsTransparent = YES;
            CGRect windowBounds = CGRectMake(0,
                                             0,
                                             self.window.frame.size.width,
                                             self.window.frame.size.height);
            
            NSVisualEffectView * vev = [[NSVisualEffectView alloc] initWithFrame:windowBounds];
            vev.blendingMode = NSVisualEffectBlendingModeBehindWindow;
            vev.material = NSVisualEffectMaterialHUDWindow;
            vev.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
            [self.window.contentView addSubview:vev positioned:NSWindowBelow relativeTo:nil];
        }
    }
    return self;
}
@end
