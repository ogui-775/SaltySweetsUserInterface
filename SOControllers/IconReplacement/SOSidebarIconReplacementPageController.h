//Created by Salty on 6/21/26.

#import <objc/runtime.h>
#import <FinderSync/FinderSync.h>

#import "../Base/SOConfigurablePageControllerBase.h"

@interface SOSidebarIconReplacementPageController : SOConfigurablePageControllerBase <NSTableViewDelegate, NSTableViewDataSource, SOObservableDictionaryDelegate>
@property (strong, nonatomic) IBOutlet NSTableView *sidebarContainer;
@property (strong, nonatomic) IBOutlet SODragAwareImageView *imageView;
@property (strong, nonatomic) IBOutlet NSTextField *labelView;
@end
