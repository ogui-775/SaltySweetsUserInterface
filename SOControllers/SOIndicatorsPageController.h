//Created by Salty on 2/23/26.

#import "Base/SOConfigurablePageControllerBase.h"
#import "Helpers/SOScaleImageManager.h"
#import "Helpers/SOMath.h"

@interface SOIndicatorsPageController : SOConfigurablePageControllerBase <NSComboBoxDataSource, NSComboBoxDelegate>
@property (strong, nonatomic) IBOutlet NSImageView * scale1xImageWell;
@property (strong, nonatomic) IBOutlet NSImageView * scale2xImageWell;
@property (strong, nonatomic) IBOutlet NSComboBox *scale1xGravityComboBox;
@property (strong, nonatomic) IBOutlet NSComboBox *scale2xGravityComboBox;
@property (strong, nonatomic) IBOutlet NSStepper *widthMultiplierStepper;
@property (strong, nonatomic) IBOutlet NSStepper *heightMultiplierStepper;
@property (strong, nonatomic) IBOutlet NSTextField *heightLabel;
@property (strong, nonatomic) IBOutlet NSTextField *widthLabel;
@end
