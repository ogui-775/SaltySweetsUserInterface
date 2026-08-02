//Created by Salty on 8/2/26.

#import "SOSplitViewController.h"

@interface SOSplitViewController ()
@property (strong) NSSplitViewItem *sidebarItem;
@property (strong) NSSplitViewItem *mainPanelItem;
@end

@implementation SOSplitViewController
- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.sidebarItem = [NSSplitViewItem sidebarWithViewController:[[SOSidebarController alloc] initWithNibName:@"SOSidebarView"
                                                                                                        bundle:nil]];
    self.sidebarItem.canCollapse = YES;
    self.sidebarItem.maximumThickness = 210;
    self.sidebarItem.canCollapseFromWindowResize = NO;
    [self addSplitViewItem:self.sidebarItem];
    
    self.mainPanelItem = [NSSplitViewItem splitViewItemWithViewController:[[SOMainPanelController alloc] initWithNibName:@"SOMainPanelView"
                                                                                                                  bundle:nil]];
    
    [self addSplitViewItem:self.mainPanelItem];
    
    [self.view.window.toolbar insertItemWithItemIdentifier:NSToolbarToggleSidebarItemIdentifier atIndex:0];
    [self.view.window.toolbar insertItemWithItemIdentifier:NSToolbarSidebarTrackingSeparatorItemIdentifier atIndex:1];
    [self.view.window.toolbar insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier atIndex:2];
    [self.view.window.toolbar insertItemWithItemIdentifier:@"nav" atIndex:3];
    [self.view.window.toolbar insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier atIndex:4];
}

- (void)viewDidAppear {
    [super viewDidAppear];

    SOMainPanelController *mainController = (SOMainPanelController *)self.mainPanelItem.viewController;

    for (NSToolbarItem *item in self.view.window.toolbar.items) {
        if (![item.view isKindOfClass:NSClassFromString(@"SONavigatorBarStretchyView")]) {
            continue;
        }

        id controller = [item.view valueForKey:@"_viewController"];
        [controller setValue:mainController.navigatorBar forKey:@"_pageNavigatorBar"];
        [controller performSelector:@selector(initializePageNavigatorBar)];
        break;
    }
}
@end
