//Created by Salty on 7/19/26.

#import "Base/SOConfigurablePageControllerBase.h"

@interface SOFooterPageController : SOConfigurablePageControllerBase
@property (weak) IBOutlet NSButton *createNewButton;
@property (weak) IBOutlet NSButton *importButton;
@property (strong) NSPopover *createPopover;
@property (strong) NSPopover *importPopover;
@end
