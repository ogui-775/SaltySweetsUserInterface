//Created by Salty on 8/1/26.

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import "Controllers/SOPoofPageController.h"
#import "Controllers/SODockPositionPageController.h"
#import "Controllers/SOAppSettingsPageController.h"
#import "Controllers/SORetinaDisplayPageController.h"
#import "Controllers/SOSeparatorsPageController.h"
#import "Controllers/SOBackgroundPageController.h"
#import "Controllers/SOIconHeightPageController.h"
#import "Controllers/SOIconShadowsPageController.h"
#import "Controllers/SOIndicatorsPageController.h"
#import "Controllers/SOReflectionsPageController.h"

#import "Controllers/SOIconReplacementPageController.h"
#import "Controllers/SOFolderReplacementPageController.h"
#import "Controllers/SOSystemIconReplacementPageController.h"
#import "Controllers/SOSidebarIconReplacementPageController.h"
#import "Controllers/SOSystemSettingsIconReplacementPageController.h"
#import "Controllers/SOVolumeIconReplacementPageController.h"
#import "Controllers/SOClockDockTileReplacementPageController.h"
#import "Controllers/SOCalendarDockTileReplacementPageController.h"
#import "Controllers/SOMainMenuView.h"

#import "SONavigatorBarItem.h"

@class SONavigationalMenuItem;

@interface SONavigatorBarMaster : NSViewController <NSTabViewDelegate>
@property (strong, nonatomic) SOMainMenuView *mainMenuController;
@property (weak) IBOutlet AppDelegate *appDelegate;
@property (assign) BOOL isMainMenuShown;
- (IBAction)returnToMainMenu:(id)sender;
- (NSArray<SONavigatorBarItem *> *)homeNavigationOptions;
- (NSArray<SONavigatorBarItem *> *)dockNavigationOptions;
- (NSArray<SONavigatorBarItem *> *)iconNavigationOptions;
- (void)externalNavigationRequestToPageForItem:(SONavigationalMenuItem *)item;
@end

@interface SONavigationalMenuItem : NSMenuItem
@property (weak) NSViewController *boundController;
@property (assign) BOOL isSiconStudioButton;
@end
