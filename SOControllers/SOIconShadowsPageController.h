//Created by Salty on 2/22/26.

#import "Base/SOConfigurablePageControllerBase.h"

@interface SOIconShadowsPageController : SOConfigurablePageControllerBase
@property (strong, nonatomic) IBOutlet NSSlider * heightSlider;
@property (strong, nonatomic) IBOutlet NSTextField * heightTextbox;
@property (strong, nonatomic) IBOutlet NSTextField * widthTextbox;
@property (strong, nonatomic) IBOutlet NSSlider * widthSlider;

@property (strong, nonatomic) IBOutlet NSView * iconHostingView;

@property (strong, nonatomic) IBOutlet NSSlider * radiusSlider;
@property (strong, nonatomic) IBOutlet NSTextField * radiusTextbox;
@property (strong, nonatomic) IBOutlet NSTextField * opacityTextbox;
@property (strong, nonatomic) IBOutlet NSSlider * opacitySlider; 
@end
