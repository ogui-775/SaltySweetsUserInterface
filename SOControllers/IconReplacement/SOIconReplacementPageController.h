
#import "../Base/SOPageControllerBase.h"
#import "../Base/SOConfigurablePageControllerBase.h"

@interface SOIconReplacementPageController : SOConfigurablePageControllerBase <NSTableViewDelegate, NSTableViewDataSource>
@property (strong) IBOutlet NSTableView * appsTable;
@property (strong) IBOutlet NSComboBox  * folderComboBox;
@property (strong) IBOutlet NSTextField * appNameLabel;
@property (strong) IBOutlet NSImageView * imageView;

@property (strong) NSString * lastSelectedFolder;

@end
