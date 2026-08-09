//Created by Salty on 7/31/26.

#import "SONavigatorBarItem.h"

@implementation SONavigatorBarItem
- (instancetype)initWithSymbolName:(NSString *)symbolName
                             title:(NSString *)title
                        controller:(NSViewController *)controller{
    self = [super initWithIdentifier:title];
    if (self){
        self.image = [NSImage imageWithSystemSymbolName:symbolName
                           accessibilityDescription:nil];
        self.viewController = controller;
        self.label = title;
    }
    return self;
}

- (instancetype)initWithFallbackSymbolName:(NSString *)symbolName
                       preferredImageNamed:(NSString *)assetImage
                                     title:(NSString *)title
                                controller:(NSViewController *)controller{
    self = [self initWithSymbolName:symbolName
                              title:title
                         controller:controller];
    if (self){
        NSImage *preference = [NSImage imageNamed:assetImage];
        if (preference)
            self.image = preference;
    }
    return self;
}
@end
