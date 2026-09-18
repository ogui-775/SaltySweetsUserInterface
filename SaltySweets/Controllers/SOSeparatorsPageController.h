//Created by Salty on 2/18/26.

#import "Base/SOConfigurablePageControllerBase.h"

@class SOScaleImageManager;
@class SOScaleControlValueManager;

@interface SOSeparatorsPageController : SOConfigurablePageControllerBase <CALayerDelegate>
@property (nonatomic, weak) IBOutlet NSSegmentedControl * backgroundSelector;
@property (nonatomic, weak) IBOutlet NSSegmentedControl * scaleSelector;
@property (nonatomic, weak) IBOutlet NSButton * fileSystemAccessor;
@property (nonatomic, weak) IBOutlet NSSlider * heightSlider;
@property (nonatomic, weak) IBOutlet NSTextField * heightTextbox;
@property (nonatomic, weak) IBOutlet NSSlider * originSlider;
@property (nonatomic, weak) IBOutlet NSTextField * originTextbox;
@property (nonatomic, weak) IBOutlet NSView * centralImageView;
@property (nonatomic, weak) IBOutlet NSComboBox * resizeComboBox;

@property (nonatomic, strong) SOScaleImageManager *scaleMgr;
@property (nonatomic, strong) SOScaleControlValueManager *scaleValMgr;

@end
