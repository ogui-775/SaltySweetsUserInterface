#import <Carbon/Carbon.h>

#import "../Base/SOPageControllerBase.h"
#import "../Base/SOConfigurablePageControllerBase.h"
#import "../../SOSheets/SOListEditorSheetController.h"

@interface SOIconReplacementPageController : SOConfigurablePageControllerBase <NSCollectionViewDelegate, NSCollectionViewDataSource,
                                                                                NSComboBoxDataSource, NSComboBoxDelegate>
@property (strong) IBOutlet NSCollectionView * appsCollection;
@property (strong) IBOutlet NSComboBox  * folderComboBox;

@property (strong) NSString * lastSelectedFolder;

@property (strong) NSMutableArray * applicationFolderPaths;

@property (strong) SOListEditorSheetController * folderSheetController;
@end

@interface SOAppItem : NSCollectionViewItem
@property (weak) NSBundle * assignedBundle;
@property (weak) SOConfigurablePageControllerBase * parentConfigurableController;
@end

@interface SOAppItemImageView : NSImageView
@property (strong) NSURL * draggedFileURL;
@property (weak) SOAppItem * parentItem;
@property (strong) NSImage * originalSetImage;
@end
