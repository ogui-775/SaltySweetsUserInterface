//Created by Salty on 8/12/26.

#import "SOPackViewController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface SOPackViewController ()
@property (strong) NSDrawer *drawer;
@property (weak) NSWindowController *parentWindowController;
@end

@implementation SOPackViewController
- (instancetype)initWithParentWindowController:(NSWindowController *)wc{
    self = [super initWithNibName:@"SOPackViewPage"
                           bundle:nil];
    if (self){
        _drawer = [[NSDrawer alloc] initWithContentSize:CGSizeMake(400, 400)
                                          preferredEdge:NSMaxXEdge];
        _parentWindowController = wc;
        _drawer.parentWindow = self.parentWindowController.window;
    }
    return self;
}

- (IBAction)showDrawer:(id)sender{
    if (self.drawer.state == 2)
        [self.drawer close];
    else
        [self.drawer open];
}
@end

#pragma clang diagnostic pop
