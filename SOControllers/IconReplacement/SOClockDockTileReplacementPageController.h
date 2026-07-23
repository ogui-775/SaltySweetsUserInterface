//Created by Salty on 7/17/26.

#import <objc/runtime.h>

#import "../Base/SOConfigurablePageControllerBase.h"

@class SOClockDisplayView;

@interface SOClockDockTileReplacementPageController : SOConfigurablePageControllerBase
@property (strong, nonatomic) IBOutlet SOClockDisplayView *previewView;
@property (strong, nonatomic) IBOutlet NSButton *faceRadio;
@property (strong, nonatomic) IBOutlet NSButton *hourRadio;
@property (strong, nonatomic) IBOutlet NSButton *minsRadio;
@property (strong, nonatomic) IBOutlet NSButton *wireframeCheckbox;
@property (strong, nonatomic) IBOutlet NSButton *upButton;
@property (strong, nonatomic) IBOutlet NSButton *downButton;
@property (strong, nonatomic) IBOutlet NSButton *leftButton;
@property (strong, nonatomic) IBOutlet NSButton *rightButton;
@property (strong, nonatomic) IBOutlet NSButton *widthIncreaseButton;
@property (strong, nonatomic) IBOutlet NSButton *widthDecreaseButton;
@property (strong, nonatomic) IBOutlet NSButton *heightIncreaseButton;
@property (strong, nonatomic) IBOutlet NSButton *heightDecreaseButton;
@property (strong, nonatomic) IBOutlet NSButton *clearImageButton;
@property (strong, nonatomic) IBOutlet NSTextField *widthLabel;
@property (strong, nonatomic) IBOutlet NSTextField *heightLabel;
@end
