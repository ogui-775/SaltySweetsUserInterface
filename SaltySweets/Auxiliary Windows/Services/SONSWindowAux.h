//Created by Salty on 4/18/26.

#import <AppKit/AppKit.h>

#import "SONSWindowAuxContext.h"

@interface SONSWindowAux : NSWindow
@property (strong) SONSWindowAuxContext * auxiliaryContext;

- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSWindowStyleMask)style
                            backing:(NSBackingStoreType)backingStoreType
                              defer:(BOOL)flag
                            context:(SONSWindowAuxContext *)ctx;

@end
