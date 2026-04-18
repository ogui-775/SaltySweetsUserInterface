//Created by Salty on 2/2/26.

#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

#import "SOViewPane.h"

#import "../SOControllers/SOPoofPageController.h"
#import "../SOControllers/SODockPositionPageController.h"
#import "../SOControllers/SOWelcomePageController.h"
#import "../SOControllers/SOAppSettingsPageController.h"
#import "../SOControllers/SORetinaDisplayPageController.h"
#import "../SOControllers/SOAttributionsPageController.h"
#import "../SOControllers/SOSeparatorsPageController.h"
#import "../SOControllers/SOBackgroundPageController.h"
#import "../SOControllers/SOIconHeightPageController.h"
#import "../SOControllers/SOIconShadowsPageController.h"
#import "../SOControllers/SOIndicatorsPageController.h"
#import "../SOControllers/SOReflectionsPageController.h"

#import "../SOControllers/IconReplacement/SOIconReplacementPageController.h"
#import "../SOControllers/IconReplacement/SOFolderReplacementPageController.h"

@interface SONavigatorPane : NSObject <NSToolbarDelegate, NSSplitViewDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property (strong) IBOutlet NSSplitView * contentSplitView;
@property (strong) IBOutlet NSTableView * submenuChooser;
@property (strong) IBOutlet NSToolbar * menuChooser;
@property (assign) IBOutlet SOViewPane * viewPaneController;

@property (strong) NSArray * selectedSupermenu;
@property (nonatomic, strong) NSArray * homeTabMenuItems;
@property (nonatomic, strong) NSArray * dockTabMenuItems;
@property (nonatomic, strong) NSArray * iconTabMenuItems;
@property (nonatomic, strong) NSArray * miscTabMenuItems;

@property (nonatomic, strong) NSMutableDictionary * controllerClassToInstance;

- (IBAction)setMenuPage:(id)sender;
- (IBAction)setContentPane:(id)sender;
@end
