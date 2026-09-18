//Created by Salty on 9/11/26.

#import "SOPopoverResponderView.h"

@implementation SOPopoverResponderView
- (void)cancelOperation:(id)sender{
    [(NSPopover *)[self window] close];
}

- (BOOL)acceptsFirstResponder{
    return YES;
}
@end
