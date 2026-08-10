//Created by Salty on 8/2/26.

#import "SOWindowController.h"

@implementation SOWindowController
- (void)awakeFromNib{
    [super awakeFromNib];
    [self.window.toolbar setAllowsDisplayModeCustomization:NO];
}
@end
