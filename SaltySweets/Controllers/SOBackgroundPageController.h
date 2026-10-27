//Created by Salty on 2/21/26.

#import "Base/SOConfigurablePageControllerBase.h"

typedef NS_ENUM(NSUInteger, SODraggingGuide) {
    SODraggingGuideNone,
    SODraggingGuideLeft,
    SODraggingGuideRight,
    SODraggingGuideTop,
    SODraggingGuideBottom
};

@class SOScaleImageManager;

@interface SOBackgroundPageController : SOConfigurablePageControllerBase <NSTextFieldDelegate>
@property (nonatomic, strong) SOScaleImageManager *scaleMgr;

//Mixed
@property (nonatomic, strong) IBOutlet NSImageView * leftImageWell;
@property (nonatomic, strong) IBOutlet NSImageView * bottomImageWell;
@property (nonatomic, strong) IBOutlet NSImageView * rightImageWell;
@property (nonatomic, strong) IBOutlet NSSegmentedControl * scaleSelector;
@property (nonatomic, strong) IBOutlet NSButton * leftFlipButton;
@property (nonatomic, strong) IBOutlet NSButton * rightFlipButton;
@property (nonatomic, strong) IBOutlet NSButton * leftRotateButton;
@property (nonatomic, strong) IBOutlet NSButton * rightRotateButton;
@property (nonatomic, strong) IBOutlet NSTextField * blurRadiusTextbox;
@property (nonatomic, weak) IBOutlet NSTextField *saturationTextbox;
@property (nonatomic, weak) IBOutlet NSTextField *tiltTextbox;
@property (nonatomic, weak) IBOutlet NSTextField *slantTextbox;
@property (nonatomic, weak) IBOutlet NSTextField *tiltLipPercentage;
@property (nonatomic, weak) IBOutlet NSTextField *tileSaturationTextbox;
@property (nonatomic, weak) IBOutlet NSTextField *tileColorContrastTextbox;
@property (nonatomic, weak) IBOutlet NSTextField *tileSigmaXTextbox;
@property (nonatomic, weak) IBOutlet NSTextField *tileSigmaYTextbox;
@property (nonatomic, weak) IBOutlet NSTextField *tileBlurTextbox;
@property (nonatomic, weak) IBOutlet NSTextField *tileBrightnessTextbox;
@property (nonatomic, weak) IBOutlet NSView *frontlineSlicingView;
@property (nonatomic, weak) IBOutlet NSTextField *frontlineHeightTextbox;

//Frontline
@property (nonatomic, weak) IBOutlet SODragAwareImageView *leftPart;
@property (nonatomic, weak) IBOutlet SODragAwareImageView *middlePart;
@property (nonatomic, weak) IBOutlet SODragAwareImageView *rightPart;
@property (weak) IBOutlet NSTextField *frontlineLeftTextbox;
@property (weak) IBOutlet NSTextField *frontlineRightTextbox;

//Group
@property (nonatomic, strong) IBOutlet NSTextField * contentsCenterX;
@property (nonatomic, strong) IBOutlet NSTextField * contentsCenterY;
@property (nonatomic, strong) IBOutlet NSTextField * contentsCenterWidth;
@property (nonatomic, strong) IBOutlet NSTextField * contentsCenterHeight;

@property (nonatomic, strong) IBOutlet NSButton * backgroundTiling;

@property (nonatomic, strong) IBOutlet NSView * contentsCenterView;
@end
