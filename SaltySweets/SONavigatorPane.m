//Created by Salty on 2/2/26.

#import "SONavigatorPane.h"

@interface SONavigatorPane () <NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (strong) NSVisualEffectView *headerVEV;
@property (strong) NSArray *rootCategories;
@property (strong) NSDictionary *menuDictionary;
@end

@implementation SONavigatorPane

NSString * const image = @"image";
NSString * const text  = @"text";
NSString * const pageControllerClass  = @"pageControllerClass";

- (void)awakeFromNib {
    self.controllerClassToInstance = [NSMutableDictionary new];
    
    self.rootCategories = @[@"Home", @"Dock Themes", @"Icon Packs"];
    
    self.menuDictionary = @{
        self.rootCategories[0] : [self homeTableRowData],
        self.rootCategories[1] : [self dockTableRowData],
        self.rootCategories[2] : [self iconTableRowData]
    };
    
    self.submenuChooser.dataSource = self;
    self.submenuChooser.delegate = self;
    
    [self.submenuChooser reloadData];
    
    for (id category in self.rootCategories) {
        [self.submenuChooser expandItem:category];
    }
    
    [self internalSetContentPane:nil withInitBypass:YES];
}

#pragma mark - NSOutlineViewDataSource Methods

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [self.rootCategories count];
    }
    
    if ([self.rootCategories containsObject:item]) {
        NSArray *children = self.menuDictionary[item];
        return [children count];
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return self.rootCategories[index];
    }
    
    if ([self.rootCategories containsObject:item]) {
        NSArray *children = self.menuDictionary[item];
        return children[index];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [self.rootCategories containsObject:item];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSString *identifier = [tableColumn identifier];
    if (![identifier isEqualToString:@"MainBits"]) {
        return nil;
    }
    
    if ([item isKindOfClass:[NSString class]]) {
        return item;
    }
    
    if ([item isKindOfClass:[NSDictionary class]]) {
        return item[text];
    }
    
    return nil;
}

#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![self.rootCategories containsObject:item];
}

#pragma mark - View routing

- (IBAction)setContentPane:(NSOutlineView *)sender {
    [self internalSetContentPane:sender withInitBypass:NO];
}

- (void)internalSetContentPane:(NSOutlineView *)sender withInitBypass:(BOOL)bypass {
    id selectedItem = nil;
    
    if (bypass) {
        selectedItem = self.menuDictionary[@"Home"][0];
    } else {
        NSInteger row = self.submenuChooser.selectedRow;
        if (row == -1) return;
        selectedItem = [self.submenuChooser itemAtRow:row];
    }
    
    if (![selectedItem isKindOfClass:[NSDictionary class]] || ![selectedItem valueForKey:pageControllerClass]) {
        return;
    }
    
    Class cc = [selectedItem valueForKey:pageControllerClass];
    NSViewController *vc = self.controllerClassToInstance[[cc className]];
    if (!vc) {
        vc = [cc new];
        self.controllerClassToInstance[[cc className]] = vc;
    }

    [self.viewPaneController requestPageChangeTo:vc];
}

#pragma mark - Menu data

- (NSArray *)homeTableRowData{
    return @[
        @{image:@"house", text:@"Welcome", pageControllerClass:SOWelcomePageController.class},
        @{image:@"long.text.page.and.pencil", text:@"Attributions", pageControllerClass:SOAttributionsPageController.class},
        @{image:@"book.and.wrench", text:@"Documentation"},
        @{image:@"gear", text:@"App Settings", pageControllerClass:SOAppSettingsPageController.class}
    ];
}

- (NSArray *)dockTableRowData{
    return @[
        @{image:@"smoke", text:@"Poof", pageControllerClass:SOPoofPageController.class},
        @{image:@"dock.rectangle", text:@"Dock Frame", pageControllerClass:SODockPositionPageController.class},
        @{image:@"square.fill.and.line.vertical.and.square.fill", text:@"Separators", pageControllerClass:SOSeparatorsPageController.class},
        @{image:@"photo.on.rectangle.angled", text:@"Background", pageControllerClass:SOBackgroundPageController.class},
        @{image:@"square.and.arrow.up", text:@"Icon Height", pageControllerClass:SOIconHeightPageController.class},
        @{image:@"app.shadow", text:@"Icon Shadows", pageControllerClass:SOIconShadowsPageController.class},
        @{image:@"arrowtriangle.up.fill", text:@"Indicators", pageControllerClass:SOIndicatorsPageController.class},
        @{image:@"macwindow.stack", text:@"Reflections", pageControllerClass:SOReflectionsPageController.class}
    ];
}

- (NSArray *)iconTableRowData{
    return @[
        @{image:@"app.translucent", text:@"Apps", pageControllerClass:SOIconReplacementPageController.class},
        @{image:@"folder", text:@"Folders", pageControllerClass:SOFolderReplacementPageController.class},
        @{image:@"filemenu.and.pointer.arrow", text:@"File Extensions", pageControllerClass:SOSystemIconReplacementPageController.class},
        @{image:@"sidebar.left", text:@"Sidebar", pageControllerClass:SOSidebarIconReplacementPageController.class},
        @{image:@"gear.circle", text:@"System Settings Icons", pageControllerClass:SOSystemSettingsIconReplacementPageController.class},
        @{image:@"clock.arrow.trianglehead.counterclockwise.rotate.90", text:@"Volumes", pageControllerClass:SOVolumeIconReplacementPageController.class},
        @{image:@"clock.circle", text:@"Dock Clock", pageControllerClass:SOClockDockTileReplacementPageController.class},
        @{image:@"calendar", text:@"Dock Calendar"}
    ];
}
@end
