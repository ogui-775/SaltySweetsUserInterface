//Created by Salty on 9/18/26.

#import "SOTagPopoverController.h"
#import "SOPackViewItem.h"

@interface SOTagPopoverController ()
@property (weak) SOPackViewItem *parentItem;
@end

@implementation SOTagPopoverController
- (instancetype)initWithSourceItem:(SOPackViewItem *)item{
    self = [super initWithNibName:@"SOTagPopoverView"
                           bundle:nil];
    if (self){
        self.parentItem = item;
    }
    return self;
}

- (void)popoverWillShow:(NSNotification *)notification{
    self.view.window.level = NSFloatingWindowLevel;
}
@end
