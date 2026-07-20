//Created by Salty on 7/19/26.

#import "SOFooterPageController.h"

@implementation SOFooterPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    
}

- (IBAction)createNewWasPressed:(NSButton *)sender{
    if (!self.createPopover.shown){
        self.createPopover = [[NSPopover alloc] init];
        
        self.createPopover.contentViewController = [[SOCreateSSItemController alloc] initWithNibName:@"SOCreateSSItemPopover"
                                                                                                bundle:nil];
        [self.createPopover showRelativeToRect:CGRectZero
                                        ofView:self.createNewButton
                                 preferredEdge:NSRectEdgeMinY];
    } else {
        [self.createPopover close];
    }
}
@end
