//Created by Salty on 6/11/26.

#import <SharedClasses/SharedClasses.h>

#import "../Base/SOConfigurablePageControllerBase.h"
#import "../../SOSheets/SOListEditorSheetController.h"

@interface SOSystemIconReplacementPageController : SOConfigurablePageControllerBase <NSTableViewDelegate, NSTableViewDataSource, SOObservableDictionaryDelegate>
@property (strong, nonatomic) IBOutlet NSTableView *extensionTable;
@property (strong, nonatomic) IBOutlet NSButton *extensionTableEditButton;
@property (strong, nonatomic) IBOutlet SODragAwareImageView *imageView;
@end
