//Created by Salty on 6/26/26.

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import "../Base/SOConfigurablePageControllerBase.h"

@interface SOSystemSettingsIconReplacementPageController : SOConfigurablePageControllerBase <SOObservableDictionaryDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property (strong, nonatomic) IBOutlet NSTableView *table;
@property (strong, nonatomic) IBOutlet SODragAwareImageView *imageWell;
@end

@interface UTType (Private)
+ (void)_enumerateAllDeclaredTypesUsingBlock:(void(^)(UTType * type))block;
@end
