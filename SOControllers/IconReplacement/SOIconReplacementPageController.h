#import <Carbon/Carbon.h>
#import <QuartzCore/QuartzCore.h>

#import "../Base/SOPageControllerBase.h"
#import "../Base/SOConfigurablePageControllerBase.h"
#import "../../SOSheets/SOListEditorSheetController.h"
#import "../Base/SODragAwareImageView.h"

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

@interface SOAppItemImageView : SODragAwareImageView
- (void)ensureGlowLayer;
@property (assign) BOOL isPendingReplace;
@property (assign) BOOL isPendingRemove;
@property (assign) BOOL isReplaced;
@property (weak) SOAppItem * parentItem;
@property (strong) NSImage * originalSetImage;
@property (strong) CALayer * glowShadowLayer;
@end
