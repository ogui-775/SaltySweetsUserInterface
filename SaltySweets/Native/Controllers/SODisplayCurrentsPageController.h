//Created by Salty on 8/30/26.

#import <Cocoa/Cocoa.h>

#import "../../../SOControllers/Base/SOConfigurablePageControllerBase.h"

@interface SODisplayCurrentsPageController : SOConfigurablePageControllerBase
@property (weak) IBOutlet NSTextField *dockThemeNameDisplay;
@property (weak) IBOutlet NSButton *dockThemeSigningInfoButton;

@property (weak) IBOutlet NSTextField *iconPackNameDisplay;
@end
