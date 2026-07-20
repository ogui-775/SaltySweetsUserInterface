//Created by Salty on 7/19/26.

#import "Base/SOConfigurablePageControllerBase.h"
#import "../SOPopovers/Controllers/SOCreateSSItemController.h"

@interface SOFooterPageController : SOConfigurablePageControllerBase
@property (weak) IBOutlet NSButton *createNewButton;
@property (weak) IBOutlet NSButton *importButton;
@property (weak) IBOutlet NSButton *applyButton;
@property (strong) IBOutlet NSPopover *createPopover;
@end
