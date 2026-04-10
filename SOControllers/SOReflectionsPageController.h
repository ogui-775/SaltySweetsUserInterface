//Created by Salty on 2/23/26.

#import "Base/SOConfigurablePageControllerBase.h"
#import "Helpers/SOScaleImageManager.h"
#import "Helpers/SOScaleControlValueManager.h"
#import <QuartzCore/QuartzCore.h>

@interface SOReflectionsPageController : SOConfigurablePageControllerBase <CALayerDelegate>
@property (strong, nonatomic) IBOutlet NSTextField * windowReflectionOpacityTextbox;
@property (strong, nonatomic) IBOutlet NSSlider * windowReflectionOpacitySlider;
@property (strong, nonatomic) IBOutlet NSTextField * windowReflectionInsetTextbox;
@property (strong, nonatomic) IBOutlet NSSlider * windowReflectionInsetSlider;

@property (strong, nonatomic) IBOutlet NSTextField * iconReflectionOpacityTextbox;
@property (strong, nonatomic) IBOutlet NSSlider * iconReflectionOpacitySlider;
@property (strong, nonatomic) IBOutlet NSTextField * iconReflectionHeightTextbox;
@property (strong, nonatomic) IBOutlet NSSlider * iconReflectionHeightSlider;

@property (strong, nonatomic) IBOutlet NSButton * windowReflectionEnabledRadio;
@property (strong, nonatomic) IBOutlet NSButton * windowReflectionDisabledRadio;
@property (strong, nonatomic) IBOutlet NSButton * iconReflectionEnabledRadio;
@property (strong, nonatomic) IBOutlet NSButton * iconReflectionDisabledRadio;

@property (strong, nonatomic) IBOutlet NSButton * reflectionsOnLeftEnabledCheckbox;
@property (strong, nonatomic) IBOutlet NSButton * reflectionsOnRightEnabledCheckbox;

@property (strong, nonatomic) IBOutlet NSView * backgroundPositioningView;
@property (strong, nonatomic) IBOutlet NSSegmentedControl * scaleSelector;
@property (strong, nonatomic) IBOutlet NSSegmentedControl * orientationSelector;
@property (strong, nonatomic) IBOutlet NSStepper * edgeStepper;
@property (strong, nonatomic) IBOutlet NSTextField * edgeTextbox;

@property (strong, nonatomic) SOScaleControlValueManager * valueMgr;
@end
