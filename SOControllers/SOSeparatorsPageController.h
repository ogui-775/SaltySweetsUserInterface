//Created by Salty on 2/18/26.

#import "Base/SOConfigurablePageControllerBase.h"
#import <QuartzCore/QuartzCore.h>
#import "Helpers/SOScaleImageManager.h"
#import "Helpers/SOScaleControlValueManager.h"

@interface SOSeparatorsPageController : SOConfigurablePageControllerBase <CALayerDelegate>
@property (nonatomic, strong) IBOutlet NSSegmentedControl * backgroundSelector;
@property (nonatomic, strong) IBOutlet NSSegmentedControl * scaleSelector;
@property (nonatomic, strong) IBOutlet NSButton * fileSystemAccessor;
@property (nonatomic, strong) IBOutlet NSSlider * heightSlider;
@property (nonatomic, strong) IBOutlet NSTextField * heightTextbox;
@property (nonatomic, strong) IBOutlet NSSlider * originSlider;
@property (nonatomic, strong) IBOutlet NSTextField * originTextbox;
@property (nonatomic, strong) IBOutlet NSView * centralImageView;
@property (nonatomic, strong) IBOutlet NSComboBox * resizeComboBox;

@property (nonatomic, strong) SOScaleImageManager * scaleMgr;
@property (nonatomic, strong) SOScaleControlValueManager * scaleValMgr;

@end
