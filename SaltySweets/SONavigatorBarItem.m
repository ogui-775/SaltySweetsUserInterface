//Created by Salty on 7/31/26.

#import "SONavigatorBarItem.h"

@implementation SONavigatorBarItem
- (instancetype)initWithSymbolName:(NSString *)symbolName
                             title:(NSString *)title
                        controller:(NSViewController *)controller{
    self = [super init];
    if (self){
        self.image = [NSImage imageWithSystemSymbolName:symbolName
                           accessibilityDescription:nil];
        self.viewController = controller;
        self.label = title;
    }
    return self;
}
@end
