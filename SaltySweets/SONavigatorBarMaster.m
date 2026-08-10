//Created by Salty on 8/1/26.

#import "SONavigatorBarMaster.h"

const NSString *image = @"image";
const NSString *text  = @"text";
const NSString *pageControllerClass  = @"pageControllerClass";
const NSString *preferenceImage = @"preferenceImage";

#pragma mark - Controller
@interface SONavigatorBarMaster ()
@property (strong, nonatomic) NSMutableDictionary *controllerClassToInstance;
@end

@implementation SONavigatorBarMaster
- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.controllerClassToInstance = [NSMutableDictionary dictionary];
    self.mainMenuController = [[SOMainMenuView alloc] initWithNibName:@"SOMainMenuPage"
                                                               bundle:nil];
    
    [self initializePageMenu];
}

- (void)initializePageMenu{
    if (!self.mainMenuController)
        return;
    
    [self returnToMainMenu:nil];
    [self.mainMenuController finishInitWithItemDictionary:@{
        @(0) : [self homeNavigationOptions],
        @(1) : [self dockNavigationOptions],
        @(2) : [self iconNavigationOptions]
    }];
    self.mainMenuController.delegate = self;
    self.mainMenuController.action = @selector(itemWasSelectedInMenu:);
}

- (void)itemWasSelectedInMenu:(SOCollectionViewItemButton *)sender{
    NSViewController *c = [sender.delegate boundController];
    
    [[SOViewPane defaultInstance] clearDisplayView];
    [[NSApp mainWindow] setTitle:[sender title]];
    [self.mainMenuController.collectionView deselectAll:nil];
    NSWindow *window = [[[SOViewPane defaultInstance] displayView] window];
    [window setStyleMask:NSWindowStyleMaskClosable
     | NSWindowStyleMaskTitled
     | NSWindowStyleMaskMiniaturizable
     | NSWindowStyleMaskResizable];
    [self setWindow:window
               size:CGSizeMake(746, 600)
            animate:YES];
    [window setMinSize:CGSizeMake(746, 600)];
    [[SOViewPane defaultInstance] requestPageChangeTo:c];
}

- (IBAction)returnToMainMenu:(NSButton *)sender{
    [[SOViewPane defaultInstance] clearDisplayView];
    [[NSApp mainWindow] setTitle:@"SaltySweets"];
    [self.mainMenuController.collectionView deselectAll:nil];
    NSWindow *window = [[SOViewPane defaultInstance].displayView window];
    [window setStyleMask:NSWindowStyleMaskClosable
     | NSWindowStyleMaskTitled
     | NSWindowStyleMaskMiniaturizable];
    [self setWindow:window
               size:CGSizeMake(746, 350)
            animate:YES];
    [[SOViewPane defaultInstance] requestPageChangeTo:self.mainMenuController];
}

- (IBAction)goToDocumentation:(id)sender{
    [[SOViewPane defaultInstance] clearDisplayView];
    [[NSApp mainWindow] setTitle:@"Documentation"];
    [self.mainMenuController.collectionView deselectAll:nil];
    NSWindow *window = [[[SOViewPane defaultInstance] displayView] window];
    [window setStyleMask:NSWindowStyleMaskClosable
     | NSWindowStyleMaskTitled
     | NSWindowStyleMaskMiniaturizable
     | NSWindowStyleMaskResizable];
    [self setWindow:window
               size:CGSizeMake(746, 600)
            animate:YES];
    [window setMinSize:CGSizeMake(746, 600)];
    [[SOViewPane defaultInstance] requestPageChangeTo:self.controllerClassToInstance[@"SODocumentationPageController"]];
}

- (NSArray<SONavigatorBarItem *> *)itemArrayForSection:(NSInteger)section{
    if (section == 0)
        return [self homeNavigationOptions];
    else if (section == 1)
        return [self dockNavigationOptions];
    else
        return [self iconNavigationOptions];
}

#pragma mark - Menu data

- (NSArray *)homeTableRowData{
    return @[
        @{image:@"hand.wave", text:@"Welcome", pageControllerClass:SOWelcomePageController.class},
        @{image:@"long.text.page.and.pencil", text:@"Credits", pageControllerClass:SOAttributionsPageController.class},
        @{image:@"book.and.wrench", text:@"Documentation", pageControllerClass:SODocumentationPageController.class},
        @{image:@"gear", text:@"Settings", pageControllerClass:SOAppSettingsPageController.class, preferenceImage:NSImageNameAdvanced}
    ];
}

- (NSArray *)dockTableRowData{
    return @[
        @{image:@"smoke", text:@"Poof", pageControllerClass:SOPoofPageController.class, preferenceImage:@"i_poof"},
        @{image:@"dock.rectangle", text:@"Dock Frame", pageControllerClass:SODockPositionPageController.class, preferenceImage:@"i_frame"},
        @{image:@"square.fill.and.line.vertical.and.square.fill", text:@"Separators", pageControllerClass:SOSeparatorsPageController.class, preferenceImage:@"i_separator"},
        @{image:@"photo.on.rectangle.angled", text:@"Background", pageControllerClass:SOBackgroundPageController.class, preferenceImage:@"i_background"},
        @{image:@"square.and.arrow.up", text:@"Icon Height", pageControllerClass:SOIconHeightPageController.class, preferenceImage:@"i_height"},
        @{image:@"app.shadow", text:@"Icon Shadows", pageControllerClass:SOIconShadowsPageController.class, preferenceImage:@"i_shadow"},
        @{image:@"arrowtriangle.up.fill", text:@"Indicators", pageControllerClass:SOIndicatorsPageController.class, preferenceImage:@"i_indicator"},
        @{image:@"macwindow.stack", text:@"Reflections", pageControllerClass:SOReflectionsPageController.class, preferenceImage:@"i_reflection"}
    ];
}

- (NSArray *)iconTableRowData{
    return @[
        @{image:@"app.translucent", text:@"Applications", pageControllerClass:SOIconReplacementPageController.class},
        @{image:@"folder", text:@"Folders", pageControllerClass:SOFolderReplacementPageController.class},
        @{image:@"filemenu.and.pointer.arrow", text:@"File Extensions", pageControllerClass:SOSystemIconReplacementPageController.class},
        @{image:@"sidebar.left", text:@"Sidebar", pageControllerClass:SOSidebarIconReplacementPageController.class},
        @{image:@"gear.circle", text:@"Settings Icons", pageControllerClass:SOSystemSettingsIconReplacementPageController.class},
        @{image:@"clock.arrow.trianglehead.counterclockwise.rotate.90", text:@"Volumes", pageControllerClass:SOVolumeIconReplacementPageController.class},
        @{image:@"clock.circle", text:@"Dock Clock", pageControllerClass:SOClockDockTileReplacementPageController.class},
        @{image:@"calendar", text:@"Dock Calendar", pageControllerClass:SOCalendarDockTileReplacementPageController.class}
    ];
}

- (NSArray<SONavigatorBarItem *> *)homeNavigationOptions{
    return [self navOptionsWithArray:[self homeTableRowData]];
}

- (NSArray<SONavigatorBarItem *> *)dockNavigationOptions{
    return [self navOptionsWithArray:[self dockTableRowData]];
}

- (NSArray<SONavigatorBarItem *> *)iconNavigationOptions{
    return [self navOptionsWithArray:[self iconTableRowData]];
}

- (NSArray<SONavigatorBarItem *> *)navOptionsWithArray:(NSArray *)array{
    NSMutableArray *ret = [NSMutableArray array];
    
    for (NSDictionary *tableDict in array){
        Class cc = [tableDict objectForKey:pageControllerClass];
        
        if (!cc)
            continue;
        
        NSViewController *vc = self.controllerClassToInstance[[cc className]];
        if (!vc) {
            vc = [cc new];
            self.controllerClassToInstance[[cc className]] = vc;
        }
        
        SONavigatorBarItem *item = [[SONavigatorBarItem alloc] initWithFallbackSymbolName:[tableDict objectForKey:image]
                                                                      preferredImageNamed:[tableDict objectForKey:preferenceImage]
                                                                                    title:[tableDict objectForKey:text]
                                                                               controller:vc];
        
        [ret addObject:item];
    }
    
    return ret;
}

- (void)setWindow:(NSWindow *)window
             size:(NSSize)size
          animate:(BOOL)animate{
    NSRect frame = window.frame;
    
    frame.origin.y += frame.size.height - size.height;

    frame.size = size;

    [window setFrame:frame
             display:YES
             animate:animate];
}
@end
