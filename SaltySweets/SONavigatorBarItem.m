//Created by Salty on 7/31/26.

#import "SONavigatorBarItem.h"

@implementation SONavigatorBarItem
- (instancetype)initWithSymbolName:(NSString *)symbolName
                             title:(NSString *)title
                        controller:(NSViewController *)controller{
    self = [super init];
    if (self){
        _title = title;
        _image = [NSImage imageWithSystemSymbolName:symbolName
                           accessibilityDescription:nil];
        _boundController = controller;
    }
    return self;
}
@end
