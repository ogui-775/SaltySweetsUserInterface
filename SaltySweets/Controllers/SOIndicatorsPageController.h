//Created by Salty on 2/23/26.

#import "Base/SOConfigurablePageControllerBase.h"

@interface SOIndicatorsPageController : SOConfigurablePageControllerBase <NSComboBoxDataSource, NSComboBoxDelegate>
@property (strong, nonatomic) IBOutlet NSImageView * scale1xImageWell;
@property (strong, nonatomic) IBOutlet NSImageView * scale2xImageWell;
@property (strong, nonatomic) IBOutlet NSComboBox *scale1xGravityComboBox;
@property (strong, nonatomic) IBOutlet NSComboBox *scale2xGravityComboBox;
@end
