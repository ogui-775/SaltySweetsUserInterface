//Created by Salty on 2/7/26.

#import "Base/SOConfigurablePageControllerBase.h"

@interface SODockPositionPageController : SOConfigurablePageControllerBase
@property (nonatomic, strong) IBOutlet NSSlider * widthSlider;
@property (nonatomic, strong) IBOutlet NSTextField * widthInputBox;

@property (nonatomic, strong) IBOutlet NSSlider * originSlider;
@property (nonatomic, strong) IBOutlet NSTextField * originInputBox;

- (IBAction)setExtensionAmount:(id)sender;
- (IBAction)setOriginModifier:(id)sender;
@end
