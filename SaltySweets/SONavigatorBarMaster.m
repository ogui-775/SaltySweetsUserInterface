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
    
    if (!self.controllerClassToInstance)
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

- (void)externalNavigationRequestToPageForItem:(SONavigationalMenuItem *)item{
    if (![self.appDelegate.window isVisible])
        [self.appDelegate.window makeKeyAndOrderFront:nil];
    
    NSViewController *c = item.boundController;
    
    [self navigateToViewController:c withTitle:[item title]];
}

- (void)itemWasSelectedInMenu:(SOCollectionViewItemButton *)sender{
    NSViewController *c = [sender.delegate boundController];
    
    [self navigateToViewController:c withTitle:[sender title]];
}

- (void)navigateToViewController:(NSViewController *)c withTitle:(NSString *)title{
    [[SOViewPane defaultInstance] clearDisplayView];
    [[NSApp mainWindow] setTitle:title];
    [self.mainMenuController.collectionView deselectAll:nil];
    NSWindow *window = [[[SOViewPane defaultInstance] displayView] window];
    [window setStyleMask:NSWindowStyleMaskClosable
     | NSWindowStyleMaskTitled
     | NSWindowStyleMaskMiniaturizable
     | NSWindowStyleMaskResizable];
    [self setWindow:window
        contentSize:CGSizeMake(746, 466)
            animate:YES];
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
        contentSize:CGSizeMake(746, 270)
            animate:YES];
    [[SOViewPane defaultInstance] requestPageChangeTo:self.mainMenuController];
}

- (IBAction)goToDocumentation:(id)sender{
    NSViewController *c = self.controllerClassToInstance[@"SODocumentationPageController"];
    
    [self navigateToViewController:c withTitle:@"Documentation"];
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
        @{image:@"app.translucent", text:@"Applications", pageControllerClass:SOIconReplacementPageController.class, preferenceImage:@"i_app"},
        @{image:@"folder", text:@"Folders", pageControllerClass:SOFolderReplacementPageController.class, preferenceImage:@"i_folder"},
        @{image:@"filemenu.and.pointer.arrow", text:@"File Extensions", pageControllerClass:SOSystemIconReplacementPageController.class, preferenceImage:@"i_document"},
        @{image:@"sidebar.left", text:@"Sidebar", pageControllerClass:SOSidebarIconReplacementPageController.class, preferenceImage:@"i_sidebar"},
        @{image:@"gear.circle", text:@"Settings Icons", pageControllerClass:SOSystemSettingsIconReplacementPageController.class, preferenceImage:@"i_pref"},
        @{image:@"clock.arrow.trianglehead.counterclockwise.rotate.90", text:@"Volumes", pageControllerClass:SOVolumeIconReplacementPageController.class, preferenceImage:@"i_volume"},
        @{image:@"clock.circle", text:@"Dock Clock", pageControllerClass:SOClockDockTileReplacementPageController.class, preferenceImage:@"i_clock"},
        @{image:@"calendar", text:@"Dock Calendar", pageControllerClass:SOCalendarDockTileReplacementPageController.class, preferenceImage:@"i_calendar"}
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
    if (!self.controllerClassToInstance)
        self.controllerClassToInstance = [NSMutableDictionary dictionary];
    
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
      contentSize:(NSSize)size
          animate:(BOOL)animate{
    NSRect frame = window.frame;
    frame.size = size;

    frame = [window frameRectForContentRect:frame];
    frame.origin.y = frame.origin.y - (frame.size.height - window.frame.size.height);
    
    [window setFrame:frame
             display:YES
             animate:animate];
    
    [window setContentMinSize:size];
}
@end

@implementation SONavigationalMenuItem @end
