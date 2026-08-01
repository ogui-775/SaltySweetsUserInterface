//Created by Salty on 8/1/26.

#import "SONavigatorBarMaster.h"

const NSString *image = @"image";
const NSString *text  = @"text";
const NSString *pageControllerClass  = @"pageControllerClass";

#pragma mark - Tab Buttons
@interface SOMasterTab : NSSegmentedControl
@property (strong) NSMutableDictionary<NSNumber *, NSArray<SONavigatorBarItem *> *> *pagesPerSegment;
- (void)setBoundPages:(NSArray<SONavigatorBarItem *> *)boundPages
           forSegment:(NSInteger)segment;
@end

@implementation SOMasterTab
- (void)setBoundPages:(NSArray<SONavigatorBarItem *> *)boundPages
           forSegment:(NSInteger)segment {
    if (!_pagesPerSegment)
        _pagesPerSegment = [NSMutableDictionary dictionary];
    
    if (boundPages) {
        self.pagesPerSegment[@(segment)] = boundPages;
    } else {
        [self.pagesPerSegment removeObjectForKey:@(segment)];
    }
}

- (NSArray<SONavigatorBarItem *> *)boundPagesForSegment:(NSInteger)segment {
    return self.pagesPerSegment[@(segment)] ?: @[];
}
@end

#pragma mark - Controller

@interface SONavigatorBarMaster ()
@property (strong, nonatomic) NSMutableDictionary *controllerClassToInstance;
@property (strong, nonatomic) SOMasterTab *tabControl;
@end

@implementation SONavigatorBarMaster
- (void)awakeFromNib{
    [super awakeFromNib];
    self.controllerClassToInstance = [NSMutableDictionary dictionary];
    [(SONavigatorBarStretchyView *)self.view setInnerView:self];
    
    CGRect midFrame = CGRectMake(CGRectGetMidX(self.view.bounds) - 200,
                                 CGRectGetMidY(self.view.bounds) - 15,
                                 400,
                                 40);
    
    self.tabControl = [[SOMasterTab alloc] initWithFrame:midFrame];
    [self.tabControl setSegmentCount:3];
    [self.tabControl setSegmentStyle:NSSegmentStyleRoundRect];
    
    [self.tabControl setImage:[NSImage imageWithSystemSymbolName:@"house" accessibilityDescription:nil]
                   forSegment:0];
    [self.tabControl setLabel:@"Home"
                   forSegment:0];
    [self.tabControl setBoundPages:[self homeNavigationOptions]
                        forSegment:0];
    
    [self.tabControl setImage:[NSImage imageWithSystemSymbolName:@"dock.rectangle"
                                        accessibilityDescription:nil]
                   forSegment:1];
    [self.tabControl setLabel:@"Dock"
                   forSegment:1];
    [self.tabControl setBoundPages:[self dockNavigationOptions]
                        forSegment:1];
    
    [self.tabControl setImage:[NSImage imageWithSystemSymbolName:@"app.translucent"
                                        accessibilityDescription:nil]
                   forSegment:2];
    [self.tabControl setLabel:@"Icons"
                   forSegment:2];
    [self.tabControl setBoundPages:[self iconNavigationOptions]
                        forSegment:2];
    
    [self.tabControl setSelectedSegment:0];
    
    [self.view addSubview:self.tabControl];
    
    [self.tabControl setAction:@selector(didChangeTab:)];
    [self.tabControl setTarget:self];
}

- (void)viewDidAppear{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [super viewDidAppear];
        [self initializePageNavigatorBar];
    });
}

- (void)initializePageNavigatorBar{
    if (!self.pageNavigatorBar)
        return;
    
    [self.pageNavigatorBar finishInitWithOptions:[self homeNavigationOptions]];
}

- (void)didChangeTab:(SOMasterTab *)sender{
    NSArray<SONavigatorBarItem *> *boundPagesFromSender = [self.tabControl boundPagesForSegment:sender.selectedSegment];
    
    if (!boundPagesFromSender)
        return;
    
    [self.pageNavigatorBar replaceCurrentOptionsWithArray:boundPagesFromSender];
}

#pragma mark - Menu data

- (NSArray *)homeTableRowData{
    return @[
        @{image:@"hand.wave", text:@"Welcome", pageControllerClass:SOWelcomePageController.class},
        @{image:@"long.text.page.and.pencil", text:@"Credits", pageControllerClass:SOAttributionsPageController.class},
        @{image:@"book.and.wrench", text:@"Docs"},
        @{image:@"gear", text:@"Settings", pageControllerClass:SOAppSettingsPageController.class}
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
        
        SONavigatorBarItem *item = [[SONavigatorBarItem alloc] initWithSymbolName:[tableDict objectForKey:image]
                                                                            title:[tableDict objectForKey:text]
                                                                       controller:vc];
        
        [ret addObject:item];
    }
    
    return ret;
}
@end
