//Created by Salty on 7/5/26.

#import "../Base/SOConfigurablePageControllerBase.h"

@interface SOVolumeIconReplacementPageController : SOConfigurablePageControllerBase <SOObservableDictionaryDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property (strong, nonatomic) IBOutlet NSTableView *tableView;
@property (strong, nonatomic) IBOutlet SODragAwareImageView *imageWell;
@end
