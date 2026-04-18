//Created by Salty on 2/2/26.

#import "SONavigatorPane.h"

@implementation SONavigatorPane

NSString * const image = @"image";
NSString * const text  = @"text";
NSString * const pageControllerClass  = @"pageControllerClass";

- (void)awakeFromNib{
    self.controllerClassToInstance = [NSMutableDictionary new];
    
    self.homeTabMenuItems = [self homeTableRowData];
    self.dockTabMenuItems = [self dockTableRowData];
    self.iconTabMenuItems = [self iconTableRowData];
    
    self.selectedSupermenu = self.homeTabMenuItems;
    
    [self internalSetContentPane:nil withInitBypass:YES];
    [self.menuChooser setSelectedItemIdentifier:@"1"];
    [self.submenuChooser reloadData];
}

#pragma mark - Navigation table data population

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.selectedSupermenu count];
}

- (id)tableView:(NSTableView *)tableView
            objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row{
    NSString * identifier = tableColumn.identifier;
    
    if ([identifier isEqualToString:@"ImageCol"]){
        return [NSImage imageWithSystemSymbolName:[self.selectedSupermenu[row] valueForKey:image]
                         accessibilityDescription:nil];
    } else {
        return [self.selectedSupermenu[row] valueForKey:text];
    }
}

#pragma mark - View routing

- (IBAction)setContentPane:(NSTableView *)sender{
    [self internalSetContentPane:sender withInitBypass:NO];
}

- (void)internalSetContentPane:(NSTableView *)sender withInitBypass:(BOOL)bypass{
    if (!bypass){
        if (![self.selectedSupermenu[sender.selectedRow] valueForKey:pageControllerClass]){
            return;
        }
    }
    
    long lastSelected = 0;
    if (!sender) {
        lastSelected = self.submenuChooser.selectedRow;
    } else {
        lastSelected = sender.selectedRow;
    }

    
    Class cc;
    if (bypass){
        cc = [self.selectedSupermenu[0] valueForKey:pageControllerClass];
    } else {
        cc = [self.selectedSupermenu[lastSelected] valueForKey:pageControllerClass];
    }

    NSViewController * vc = self.controllerClassToInstance[[cc className]];
    if (!vc){
        vc = [cc new];
        self.controllerClassToInstance[[cc className]] = vc;
    }

    [self.viewPaneController requestPageChangeTo:vc];
}

- (IBAction)setMenuPage:(NSToolbarItem *)sender{
    switch (sender.itemIdentifier.intValue) {
        case 0:
            if ([self.contentSplitView.subviews[1] frame].origin.x <= 10){
                [CATransaction begin];
                [[self.contentSplitView animator] setPosition:200 ofDividerAtIndex:0];
                [self.contentSplitView.subviews[0] setHidden:NO];
                [CATransaction commit];
            } else {
                [CATransaction begin];
                [[self.contentSplitView animator] setPosition:0 ofDividerAtIndex:0];
                [self.contentSplitView.subviews[0] setHidden:YES];
                [CATransaction commit];
            }
            return;
        case 1:
            self.selectedSupermenu = self.homeTabMenuItems;
            break;
        case 2:
            self.selectedSupermenu = self.dockTabMenuItems;
            break;
        case 3:
            self.selectedSupermenu = self.iconTabMenuItems;
            break;
        default:
            self.selectedSupermenu = self.homeTabMenuItems;
            break;
    }
    
    [self.submenuChooser reloadData];
    [self internalSetContentPane:nil withInitBypass:NO];
}

#pragma mark - Menu data

- (NSArray *)homeTableRowData{
    return @[
        @{image:@"house", text:@"Welcome",
          pageControllerClass:SOWelcomePageController.class},
        @{image:@"dot.scope.display", text:@"Retina Display",
          pageControllerClass:SORetinaDisplayPageController.class},
        @{image:@"long.text.page.and.pencil", text:@"Attributions",
          pageControllerClass:SOAttributionsPageController.class},
        @{image:@"book.and.wrench", text:@"Documentation"},
        @{image:@"gear", text:@"App Settings",
          pageControllerClass:SOAppSettingsPageController.class}
    ];
}

- (NSArray *)dockTableRowData{
    return @[
        @{image:@"smoke", text:@"Poof",
          pageControllerClass:SOPoofPageController.class},
        @{image:@"dock.rectangle", text:@"Dock Frame",
          pageControllerClass:SODockPositionPageController.class},
        @{image:@"square.fill.and.line.vertical.and.square.fill", text:@"Separators",
          pageControllerClass:SOSeparatorsPageController.class},
        @{image:@"photo.on.rectangle.angled", text:@"Background",
          pageControllerClass:SOBackgroundPageController.class},
        @{image:@"square.and.arrow.up", text:@"Icon Height",
          pageControllerClass:SOIconHeightPageController.class},
        @{image:@"app.shadow", text:@"Icon Shadows",
          pageControllerClass:SOIconShadowsPageController.class},
        @{image:@"arrowtriangle.up.fill", text:@"Indicators",
          pageControllerClass:SOIndicatorsPageController.class},
        @{image:@"macwindow.stack", text:@"Reflections",
          pageControllerClass:SOReflectionsPageController.class}
    ];
}

- (NSArray *)iconTableRowData{
    return @[
        @{image:@"app.translucent", text:@"App Icons",
          pageControllerClass:SOIconReplacementPageController.class},
        @{image:@"folder", text:@"Folder Icons",
          pageControllerClass:SOFolderReplacementPageController.class},
        @{image:@"filemenu.and.pointer.arrow", text:@"System Icons"}
    ];
}
@end
