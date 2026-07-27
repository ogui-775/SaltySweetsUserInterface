//Created by Salty on 7/24/26.

#import "SOHorizontalSplitPageController.h"

@implementation SOHorizontalSplitPageController
- (void)awakeFromNib{
    [super awakeFromNib];
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[NSColor colorWithRed:0.85 green:0.93 blue:0.98 alpha:1.0].CGColor];
}
@end
