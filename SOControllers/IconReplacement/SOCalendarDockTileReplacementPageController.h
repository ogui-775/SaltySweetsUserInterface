//Created by Salty on 7/23/26.

#import "../Base/SOConfigurablePageControllerBase.h"
#import <SharedClasses/SharedClasses.h>

@interface SOCalendarDockTileReplacementPageController : SOConfigurablePageControllerBase
@property (weak, nonatomic) IBOutlet NSView *compositionView;

@property (weak, nonatomic) IBOutlet NSSlider *dayRotationDial;
@property (weak, nonatomic) IBOutlet NSStepper *dayWidthStepper;
@property (weak, nonatomic) IBOutlet NSStepper *dayHeightStepper;
@property (weak, nonatomic) IBOutlet NSStepper *dayXStepper;
@property (weak, nonatomic) IBOutlet NSStepper *dayYStepper;
@property (strong, nonatomic) NSFontPanel *dayFontPanel;
@property (strong, nonatomic) NSColorPanel *dayColorPanel;

@property (weak, nonatomic) IBOutlet NSSlider *monthRotationDial;
@property (weak, nonatomic) IBOutlet NSStepper *monthWidthStepper;
@property (weak, nonatomic) IBOutlet NSStepper *monthHeightStepper;
@property (weak, nonatomic) IBOutlet NSStepper *monthXStepper;
@property (weak, nonatomic) IBOutlet NSStepper *monthYStepper;
@property (strong, nonatomic) NSColorPanel *monthColorPanel;
@property (strong, nonatomic) NSFontPanel *monthFontPanel;
@end
