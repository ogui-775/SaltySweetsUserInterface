//Created by Salty on 8/1/26.

#import <Cocoa/Cocoa.h>

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
#import "../SOControllers/SODocumentationPageController.h"

#import "../SOControllers/IconReplacement/SOIconReplacementPageController.h"
#import "../SOControllers/IconReplacement/SOFolderReplacementPageController.h"
#import "../SOControllers/IconReplacement/SOSystemIconReplacementPageController.h"
#import "../SOControllers/IconReplacement/SOSidebarIconReplacementPageController.h"
#import "../SOControllers/IconReplacement/SOSystemSettingsIconReplacementPageController.h"
#import "../SOControllers/IconReplacement/SOVolumeIconReplacementPageController.h"
#import "../SOControllers/IconReplacement/SOClockDockTileReplacementPageController.h"
#import "../SOControllers/IconReplacement/SOCalendarDockTileReplacementPageController.h"
#import "Native/Controllers/SOMainMenuView.h"

#import "SONavigatorBarItem.h"

@interface SONavigatorBarMaster : NSViewController <NSTabViewDelegate>
@property (strong, nonatomic) SOMainMenuView *mainMenuController;
@end
