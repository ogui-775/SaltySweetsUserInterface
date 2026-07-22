//Created by Salty on 7/19/26.

#import "SOFooterPageController.h"

@implementation SOFooterPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:NSColor.separatorColor.CGColor];
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    
}

- (IBAction)createNewWasPressed:(NSButton *)sender{
    [self.importPopover close];
    
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

- (IBAction)importWasPressed:(NSButton *)sender{
    [self.createPopover close];
    
    if (!self.importPopover.shown){
        self.importPopover = [[NSPopover alloc] init];
        
        self.importPopover.contentViewController = [[SOImportSSItemController alloc] initWithNibName:@"SOImportSSItemPopover"
                                                                                              bundle:nil];
        
        [self.importPopover showRelativeToRect:CGRectZero
                                        ofView:self.importButton
                                 preferredEdge:NSRectEdgeMinY];
    } else {
        [self.importPopover close];
    }
}
@end
