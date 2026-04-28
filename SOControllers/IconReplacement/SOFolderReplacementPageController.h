//Created by Salty on 4/17/26.

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import "../Base/SOConfigurablePageControllerBase.h"
#import "../Base/SODragAwareImageView.h"

@class SOFolderItem;

@interface SOFolderReplacementPageController : SOConfigurablePageControllerBase <NSCollectionViewDataSource, NSCollectionViewDelegate>
@property (strong) IBOutlet NSCollectionView * folderScrollerCollection;
@property (strong) IBOutlet SODragAwareImageView * backFlapWell;
@property (strong) IBOutlet SODragAwareImageView * folderWell;
@property (strong) IBOutlet SODragAwareImageView * frontFlapWell;
@property (strong) IBOutlet NSTextField * currentFolderTypeLabel;
@property (strong) IBOutlet NSTextField * backFlapWellLabel;
@property (strong) IBOutlet NSTextField * backFlapWellAdditionalLabel;
@property (strong) IBOutlet NSTextField * frontFlapWellLabel;
@property (strong) IBOutlet NSTextField * frontFlapWellAdditionalLabel;
@property (strong) IBOutlet NSSwitch * fullVariantSwitch;
@property (strong) IBOutlet NSTextField * fullVariantSwitchLabel;
@property (strong) IBOutlet NSSegmentedControl * folderPaperSegmented;

- (void)selectedFolderDidChange:(SOFolderItem *)sender;
@end

@interface UTType (Private)
+ (void)_enumerateAllDeclaredTypesUsingBlock:(void(^)(UTType * type))block;
@end

@interface SOFolderItem : NSCollectionViewItem
@property (weak) UTType * assignedType;
@property (weak) SOFolderReplacementPageController * parentConfigurableController;
@end

@interface SOSwitchExt : NSSwitch @end
