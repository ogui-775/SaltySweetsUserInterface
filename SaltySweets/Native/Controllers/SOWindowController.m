//Created by Salty on 8/2/26.

#import "SOWindowController.h"
#import "../../SONavigatorBarMaster.h"
#import "SOPackViewController.h"

const NSToolbarItemIdentifier itemId = @"menuItemToolbar";
const NSToolbarItemIdentifier drawerButton = @"drawerControl";

@implementation SOWindowController
- (void)awakeFromNib{
    [super awakeFromNib];
    [self.window.toolbar setAllowsDisplayModeCustomization:NO];
    [self.window.toolbar setDelegate:self];
    
    [self.window.toolbar insertItemWithItemIdentifier:itemId
                                              atIndex:0];
    
    [self.window.toolbar insertItemWithItemIdentifier:drawerButton
                                              atIndex:1];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag{
    if ([itemIdentifier isEqualToString:itemId]){
        NSMenuToolbarItem *menuItem = [[NSMenuToolbarItem alloc] initWithItemIdentifier:itemId];
        
        menuItem.image = [NSImage imageWithSystemSymbolName:@"square.grid.3x3.fill"
                                   accessibilityDescription:nil];
        
        menuItem.showsIndicator = NO;
        menuItem.navigational = YES;
        menuItem.target = self.navigatorBarMaster;
        menuItem.action = @selector(returnToMainMenu:);
        
        NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Navigation"];
        NSMenu *viewMenu = [[NSMenu alloc] initWithTitle:@"View"];
        
        [self populateMenu:menu];
        [self populateMenu:viewMenu];
        
        [self.viewMenu setSubmenu:viewMenu];

        menuItem.menu = menu;
        
        return menuItem;
    }
    
    if ([itemIdentifier isEqualToString:drawerButton]){
        NSToolbarItem *buttonItem = [[NSToolbarItem alloc] initWithItemIdentifier:drawerButton];
        buttonItem.image = [NSImage imageWithSystemSymbolName:@"sidebar.squares.trailing"
                                     accessibilityDescription:nil];
        
        buttonItem.action = @selector(showDrawer:);
        
        if (!self.packViewController)
            self.packViewController = [[SOPackViewController alloc] initWithParentWindowController:self];
        
        buttonItem.target = self.packViewController;
        buttonItem.toolTip = @"Show/Hide Collections";
        
        return buttonItem;
    }
    return nil;
}

- (IBAction)showAbout:(id)sender{
    if (!self.aboutController)
        self.aboutController = [[SOAboutController alloc] initWithWindowNibName:@"AboutPanel"];
    
    [self.aboutController showWindow:self];
}

- (void)populateMenu:(NSMenu *)menu{
    NSArray *iconItems = [self.navigatorBarMaster iconNavigationOptions];
    NSMenuItem *iconHeader = [NSMenuItem sectionHeaderWithTitle:@"Icons"];
    [menu addItem:iconHeader];
    [self addItems:iconItems toMenu:menu];
    
    NSArray *dockItems = [self.navigatorBarMaster dockNavigationOptions];
    NSMenuItem *dockHeader = [NSMenuItem sectionHeaderWithTitle:@"Dock"];
    [menu addItem:dockHeader];
    [self addItems:dockItems toMenu:menu];

    NSArray *homeItems = [self.navigatorBarMaster homeNavigationOptions];
    NSMenuItem *homeHeader = [NSMenuItem sectionHeaderWithTitle:@"SaltySweets"];
    [menu addItem:homeHeader];
    [self addItems:homeItems toMenu:menu];
}

- (void)addItems:(NSArray<SONavigatorBarItem *> *)items toMenu:(NSMenu *)menu{
    for (SONavigatorBarItem *item in items){
        SONavigationalMenuItem *menuItem = [[SONavigationalMenuItem alloc] init];
        menuItem.title = item.label;
        menuItem.boundController = item.viewController;
        menuItem.action = @selector(externalNavigationRequestToPageForItem:);
        menuItem.target = self.navigatorBarMaster;
        menuItem.enabled = YES;
        NSImage *itemImage = [item.image copy];
        
        [itemImage setSize:CGSizeMake(16, 16)];
        
        menuItem.image = itemImage;
        
        if (@available(macOS 27.0, *)) {
            menuItem.preferredImageVisibility = NSMenuItemImageVisibilityVisible;
        }
        
        [menu addItem:menuItem];
    }
}
@end
