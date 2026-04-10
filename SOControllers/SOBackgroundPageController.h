//Created by Salty on 2/21/26.

#import "Base/SOConfigurablePageControllerBase.h"
#import "Helpers/SOScaleImageManager.h"
#import <QuartzCore/CAShapeLayer.h>
#import <QuartzCore/CATextLayer.h>
#import <QuartzCore/CATransaction.h>
#import "Helpers/SOMath.h"

typedef NS_ENUM(NSUInteger, SODraggingGuide) {
    SODraggingGuideNone,
    SODraggingGuideLeft,
    SODraggingGuideRight,
    SODraggingGuideTop,
    SODraggingGuideBottom
};

@interface SOBackgroundPageController : SOConfigurablePageControllerBase
@property (nonatomic, strong) SOScaleImageManager * scaleMgr;

//Mixed
@property (nonatomic, strong) IBOutlet NSImageView * leftImageWell;
@property (nonatomic, strong) IBOutlet NSImageView * bottomImageWell;
@property (nonatomic, strong) IBOutlet NSImageView * rightImageWell;
@property (nonatomic, strong) IBOutlet NSSegmentedControl * scaleSelector;
@property (nonatomic, strong) IBOutlet NSButton * leftFlipButton;
@property (nonatomic, strong) IBOutlet NSButton * rightFlipButton;
@property (nonatomic, strong) IBOutlet NSButton * leftRotateButton;
@property (nonatomic, strong) IBOutlet NSButton * rightRotateButton;
//Group
@property (nonatomic, strong) IBOutlet NSTextField * contentsCenterX;
@property (nonatomic, strong) IBOutlet NSTextField * contentsCenterY;
@property (nonatomic, strong) IBOutlet NSTextField * contentsCenterWidth;
@property (nonatomic, strong) IBOutlet NSTextField * contentsCenterHeight;

@property (nonatomic, strong) IBOutlet NSButton * backgroundTiling;

@property (nonatomic, strong) IBOutlet NSView * contentsCenterView;
@end
