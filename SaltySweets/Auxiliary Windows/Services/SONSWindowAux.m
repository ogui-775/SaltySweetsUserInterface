//Created by Salty on 4/18/26.

#import "SONSWindowAux.h"

@implementation SONSWindowAux
- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSWindowStyleMask)style
                            backing:(NSBackingStoreType)backingStoreType
                              defer:(BOOL)flag
                            context:(SONSWindowAuxContext *)ctx{
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]){
        _auxiliaryContext = ctx;
        self.releasedWhenClosed = NO;
    }
    return self;
}

- (void)makeKeyAndOrderFront:(id)sender{
    if (self)
        [super makeKeyAndOrderFront:sender];
}
@end
