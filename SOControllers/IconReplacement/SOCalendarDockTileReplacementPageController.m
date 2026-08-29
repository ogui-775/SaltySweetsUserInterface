#import "SOCalendarDockTileReplacementPageController.h"

@interface SOCalendarDockTileReplacementPageController ()
@property (strong) SOCalendarConfigHolder *config;

@property (strong) CALayer *monthRect;

@property (strong) CALayer *dayRect;

@property (strong) CAShapeLayer *monthRotateHandle;

@property (strong) CAShapeLayer *dayRotateHandle;

@property (strong) CAShapeLayer *monthOriginHandle;

@property (strong) CAShapeLayer *dayOriginHandle;

@property (weak) CAShapeLayer *activeHandle;
@property (assign) CGPoint dragOffset;
@property (assign) CGPoint dragStartOrigin;
@property (assign) CGSize dragStartSize;
@property (assign) CGFloat dragStartRotation;
@end

@implementation SOCalendarDockTileReplacementPageController
const SOEncodedKeyPath tCal = {
    .rootKey = &kSOIconsDockTilePluginDict,
    .components = @[@"calendar.base"]
};

const SOEncodedKeyPath tDayCol = {
    .rootKey = &kSOIconsDockTilePluginDict,
    .components = @[@"calendar.day.font.color"]
};

const SOEncodedKeyPath tMonthCol = { .rootKey = &kSOIconsDockTilePluginDict, .components = @[@"calendar.month.font.color"] };
const SOEncodedKeyPath tFontName = { .rootKey = &kSOIconsDockTilePluginDict, .components = @[@"calendar.font.typeface"] };
const SOEncodedKeyPath tFontSizeMonth = { .rootKey = &kSOIconsDockTilePluginDict, .components = @[@"calendar.day.font.size"] };
const SOEncodedKeyPath tFontSizeDay = { .rootKey = &kSOIconsDockTilePluginDict, .components = @[@"calendar.day.font.size"] };
const SOEncodedKeyPath tDayBold = { .rootKey = &kSOIconsDockTilePluginDict, .components = @[@"calendar.day.font.bold"] };
const SOEncodedKeyPath tMonthBold = { .rootKey = &kSOIconsDockTilePluginDict, .components = @[@"calendar.day.month.bold"] };

- (void)awakeFromNib{
    [super awakeFromNib];

    [self.compositionView setWantsLayer:YES];

    [self.compositionView.layer setBackgroundColor:NSColor.darkGrayColor.CGColor];

    [[SOAtomicAccessPoint sharedInstance] registerUndoManagerForClear:self.undoManager withController:self];

    self.monthRect = [CALayer layer];

    self.dayRect = [CALayer layer];

    [self.compositionView.layer addSublayer:self.monthRect];

    [self.compositionView.layer addSublayer:self.dayRect];

    self.monthRotateHandle = [CAShapeLayer layer];

    self.dayRotateHandle = [CAShapeLayer layer];

    [self.monthRect addSublayer:self.monthRotateHandle];

    [self.dayRect addSublayer:self.dayRotateHandle];

    self.monthOriginHandle = [CAShapeLayer layer];

    self.dayOriginHandle = [CAShapeLayer layer];

    [self.monthRect addSublayer:self.monthOriginHandle];

    [self.dayRect addSublayer:self.dayOriginHandle];

    NSBezierPath *cir = [NSBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 10, 10)

                                                             xRadius:90

                                                             yRadius:90];

    self.monthRotateHandle.path = [cir CGPath];

    self.monthRotateHandle.fillColor = [NSColor whiteColor].CGColor;

    self.monthRotateHandle.bounds = CGRectMake(0, 0, 10, 10);

    self.monthRotateHandle.anchorPoint = CGPointMake(0, 0);

    self.dayRotateHandle.path = [cir CGPath];

    self.dayRotateHandle.fillColor = [NSColor whiteColor].CGColor;

    self.dayRotateHandle.bounds = CGRectMake(0, 0, 10, 10);

    self.dayRotateHandle.anchorPoint = CGPointMake(0, 0);

    self.monthOriginHandle.path = [cir CGPath];

    self.monthOriginHandle.fillColor = [NSColor whiteColor].CGColor;

    self.monthOriginHandle.bounds = CGRectMake(0, 0, 10, 10);

    self.monthOriginHandle.anchorPoint = CGPointMake(0, 0);

    self.dayOriginHandle.path = [cir CGPath];

    self.dayOriginHandle.fillColor = [NSColor whiteColor].CGColor;

    self.dayOriginHandle.bounds = CGRectMake(0, 0, 10, 10);

    self.dayOriginHandle.anchorPoint = CGPointMake(0, 0);

    self.monthRect.anchorPoint = CGPointMake(0, 0);

    self.dayRect.anchorPoint = CGPointMake(0, 0);

    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    self.config = [SOCalendarConfigHolder currentPackConfig:self.baselineState];
    
    self.baseImageWell.image = [self loadImageForEncodedKeypath:&tCal];
    
    self.dayColorPanel.color = self.config.dayColor ?: [NSColor blackColor];
    
    self.monthColorPanel.color = self.config.monthColor ?: [NSColor whiteColor];
    
    self.fontNameTextField.stringValue = self.config.typeface;
    
    self.dayFontSizeComboBox.intValue = (int)self.config.dayFontSize;
    
    self.monthFontSizeComboBox.intValue = (int)self.config.monthFontSize;
    
    self.dayBoldCheckbox.state = [self getBaselineForEncodedKeypath:&tDayBold] ? NSControlStateValueOn : NSControlStateValueOff;
    
    self.monthBoldCheckbox.state = [self getBaselineForEncodedKeypath:&tMonthBold] ? NSControlStateValueOn : NSControlStateValueOff;
    
    CGFloat scaleX = self.compositionView.layer.bounds.size.width / 128.0;
    CGFloat scaleY = self.compositionView.layer.bounds.size.height / 128.0;
    
    self.dayRect.bounds = CGRectMake(0,
                                     0,
                                     self.config.daySize.width * scaleX,
                                     self.config.daySize.height * scaleY);
    
    self.dayRect.position = CGPointMake(self.config.dayOrigin.x * scaleX,
                                        self.config.dayOrigin.y * scaleY);
    
    self.dayRect.transform = CATransform3DMakeRotation(self.config.dayRotation * (M_PI / 180.0),
                                                       0,
                                                       0,
                                                       1);
    
    [self.dayRect setBorderColor:NSColor.redColor.CGColor];
    
    [self.dayRect setBorderWidth:1];
    
    self.monthRect.bounds = CGRectMake(0,
                                       0,
                                       self.config.monthSize.width * scaleX,
                                       self.config.monthSize.height * scaleY);
    
    self.monthRect.position = CGPointMake(self.config.monthOrigin.x * scaleX,
                                          self.config.monthOrigin.y * scaleY);
    
    self.monthRect.transform = CATransform3DMakeRotation(self.config.monthRotation * (M_PI / 180.0),
                                                         0,
                                                         0,
                                                         1);
    
    [self.monthRect setBorderColor:NSColor.redColor.CGColor];
    
    [self.monthRect setBorderWidth:1];
    
    self.monthRotateHandle.position = CGPointMake(self.monthRect.bounds.size.width - 5,
                                                  self.monthRect.bounds.size.height - 5);
    
    self.dayRotateHandle.position = CGPointMake(self.dayRect.bounds.size.width - 5,
                                                self.dayRect.bounds.size.height - 5);
    
    self.dayOriginHandle.position = CGPointMake(-5, -5);
    
    self.monthOriginHandle.position = CGPointMake(-5, -5);
    
    [self drawCalendar];
}

- (IBAction)modifyBaseCalendarImage:(SODragAwareImageView *)sender{
    NSImage *currentImage = [self loadImageForEncodedKeypath:&tCal];

    [self.undoManager registerUndoWithTarget:self

                                     handler:^void(SOCalendarDockTileReplacementPageController *c){
        self.baseImageWell.image = currentImage;
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
    }];

    if ([[sender.draggedFileURL pathExtension] isEqualToString:@"sicon"])
        sender.image = [SOSicon NSImageOrNilForURL:sender.draggedFileURL];

    if (!sender.image){
        [self.undoManager setActionName:@"Clear Calendar"];

        [self setPendingIconResourceChangeForKeypath:&tCal
                                            resource:nil
                                            filename:nil
                                            note:[NSString stringWithFormat:@"Cleared Calendar Base Image"]];

        return;
    }

    [self.undoManager setActionName:@"Set Calendar"];

    [self setPendingIconResourceChangeForKeypath:&tCal
                                        resource:[NSData dataWithContentsOfURL:sender.draggedFileURL]
                                        filename:sender.draggedFileURL.lastPathComponent
                                            note:[NSString stringWithFormat:@"Set Calendar Base Image to %@",
                                                  sender.draggedFileURL.lastPathComponent]];
}

- (IBAction)updateColor:(NSColorWell *)sender{
    BOOL isMonthColor = NO;

    if ([[sender identifier] isEqualToString:@"monthcw"])
        isMonthColor = YES;

    if (!isMonthColor){
        NSColor *dayCurr = self.config.dayColor;

        [self.undoManager setActionName:@"Set Day Color"];
        [self.undoManager registerUndoWithTarget:self

                                         handler:^void(SOCalendarDockTileReplacementPageController *c) {
            self.dayColorPanel.color = dayCurr;
            self.config.monthColor = dayCurr;
            [self.pendingChangeArray removeLastObject];
            [self.changeDelegate contentDidChangeState:self];
        }];

        self.config.dayColor = sender.color;
        [self setPendingIconChangeForKeypath:&tDayCol
                                       value:[NSColor hexStringWithColor:sender.color]
                                        note:[NSString stringWithFormat:@"Set day color to %@", [NSColor hexStringWithColor:sender.color]]];
    }

    else {
        NSColor *monthCurr = self.config.monthColor;

        [self.undoManager setActionName:@"Set Month Color"];
        [self.undoManager registerUndoWithTarget:self
                                         handler:^void(SOCalendarDockTileReplacementPageController *c) {
            self.monthColorPanel.color = monthCurr;
            self.config.monthColor = monthCurr;
            [self.pendingChangeArray removeLastObject];
            [self.changeDelegate contentDidChangeState:self];
        }];

        self.config.monthColor = sender.color;

        [self setPendingIconChangeForKeypath:&tMonthCol
                                       value:[NSColor hexStringWithColor:sender.color]
                                        note:[NSString stringWithFormat:@"Set month color to %@", [NSColor hexStringWithColor:sender.color]]];
    }
}

- (IBAction)fontNameUpdate:(NSTextField *)sender{
    NSString *fontName = [sender stringValue];

    NSString *currentFontName = self.config.typeface;

    [self.undoManager setActionName:@"Set Typeface"];
    [self.undoManager registerUndoWithTarget:self

                                     handler:^(SOCalendarDockTileReplacementPageController *c){
        self.fontNameTextField.stringValue = currentFontName;
        self.config.typeface = currentFontName;
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
    }];

    [self setPendingIconChangeForKeypath:&tFontName
                                   value:fontName
                                    note:[NSString stringWithFormat:@"Set font to name %@", fontName]];
}

- (IBAction)fontSizeChange:(NSComboBox *)sender{
    BOOL isMonthBox =
        [[sender identifier] isEqualToString:@"monthFontSizeBox"];

    [self.undoManager setActionName:@"Set Font Size"];

    if (isMonthBox){
        NSUInteger currMonthSize = self.config.monthFontSize;

        [self.undoManager registerUndoWithTarget:self

                                         handler:^(SOCalendarDockTileReplacementPageController *c){
            self.monthFontSizeComboBox.intValue = (int)currMonthSize;
            self.config.monthFontSize = currMonthSize;
            [self.pendingChangeArray removeLastObject];
            [self.changeDelegate contentDidChangeState:self];
        }];

        self.config.monthFontSize = sender.intValue;

        [self setPendingIconChangeForKeypath:&tFontSizeMonth
                                       value:@(sender.intValue)
                                        note:[NSString stringWithFormat:@"Set month font size to %i",
                                              sender.intValue]];
        return;
    }

    NSUInteger currDaySize = self.config.dayFontSize;
    [self.undoManager registerUndoWithTarget:self

                                     handler:^(SOCalendarDockTileReplacementPageController *c){
        self.dayFontSizeComboBox.intValue = (int)currDaySize;
        self.config.dayFontSize = currDaySize;
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
    }];

    self.config.dayFontSize = sender.intValue;

    [self setPendingIconChangeForKeypath:&tFontSizeDay
                                   value:@(sender.intValue)
                                    note:[NSString stringWithFormat:@"Set day font size to %i",
                                          sender.intValue]];
}

- (IBAction)boldChanged:(NSButton *)sender{
    BOOL bold = sender.state == NSControlStateValueOn;

    BOOL isMonth = [[sender identifier] isEqualToString:@"monthBold"];

    [self.undoManager setActionName:@"Set Bold/Regular"];
    if (isMonth){
        BOOL currMonthBold = self.config.monthIsBold;

        [self.undoManager registerUndoWithTarget:self

                                         handler:^(SOCalendarDockTileReplacementPageController *c){
            self.config.monthIsBold = currMonthBold;
            self.monthBoldCheckbox.state = currMonthBold ? NSControlStateValueOn : NSControlStateValueOff;
            [self.pendingChangeArray removeLastObject];
            [self.changeDelegate contentDidChangeState:self];
        }];

        self.config.monthIsBold = bold;

        [self setPendingIconChangeForKeypath:&tMonthBold
                                       value:@(bold)
                                        note:[NSString stringWithFormat:@"Set month bold to %i",
                                              bold]];

        return;
    }

    BOOL currDayBold = self.config.dayIsBold;

    [self.undoManager registerUndoWithTarget:self
                                     handler:^(SOCalendarDockTileReplacementPageController *c){
        self.config.dayIsBold = currDayBold;
        self.dayBoldCheckbox.state = currDayBold ? NSControlStateValueOn : NSControlStateValueOff;
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
    }];

    self.config.dayIsBold = bold;

    [self setPendingIconChangeForKeypath:&tDayBold
                                   value:@(bold)
                                    note:[NSString stringWithFormat:@"Set day bold to %i",
                                          bold]];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox{
    return 99;

}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index{
    return @(index + 1);
}

- (IBAction)doRedraw:(id)sender{
    [self drawCalendar];
}

- (void)mouseDown:(NSEvent *)event{
    self.activeHandle = [self hitTestHandlesWithEvent:event];

    if (!self.activeHandle)
        return;

    CGPoint mousePoint = [self locationInCalendarViewWithEvent:event];

    CALayer *rect = (self.activeHandle == self.monthOriginHandle ||
                     self.activeHandle == self.monthRotateHandle) ?
                    self.monthRect : self.dayRect;

    CGPoint handleCenter = [self.activeHandle convertPoint:CGPointMake(5, 5)
                                                    toLayer:self.compositionView.layer];

    self.dragOffset = CGPointMake(handleCenter.x - mousePoint.x,
                                  handleCenter.y - mousePoint.y);

    self.dragStartOrigin = rect.position;
    self.dragStartSize = rect.bounds.size;

    BOOL isMonth = self.activeHandle == self.monthOriginHandle ||
                   self.activeHandle == self.monthRotateHandle;

    self.dragStartRotation = isMonth ? self.config.monthRotation :
                                        self.config.dayRotation;
}

- (void)mouseDragged:(NSEvent *)event{
    if (!self.activeHandle)
        return;

    CGPoint mousePoint = [self locationInCalendarViewWithEvent:event];

    BOOL isMonth = self.activeHandle == self.monthOriginHandle ||
                   self.activeHandle == self.monthRotateHandle;

    CALayer *rect = isMonth ? self.monthRect : self.dayRect;

    CGFloat scaleX = self.compositionView.layer.bounds.size.width / 128.0;
    CGFloat scaleY = self.compositionView.layer.bounds.size.height / 128.0;

    CGFloat startWidth = self.dragStartSize.width;
    CGFloat startHeight = self.dragStartSize.height;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    if (self.activeHandle == self.monthOriginHandle ||
        self.activeHandle == self.dayOriginHandle){

        CGPoint targetHandle = CGPointMake(mousePoint.x + self.dragOffset.x,
                                           mousePoint.y + self.dragOffset.y);

        rect.position = targetHandle;

        if (isMonth)
            self.config.monthOrigin = CGPointMake(round(targetHandle.x / scaleX),
                                                  round(targetHandle.y / scaleY));
        else
            self.config.dayOrigin = CGPointMake(round(targetHandle.x / scaleX),
                                                round(targetHandle.y / scaleY));
    }
    else{
        CGPoint targetHandle = CGPointMake(mousePoint.x + self.dragOffset.x,
                                           mousePoint.y + self.dragOffset.y);

        CGPoint origin = self.dragStartOrigin;

        CGFloat dx = targetHandle.x - origin.x;
        CGFloat dy = targetHandle.y - origin.y;

        CGFloat cornerAngle = atan2(startHeight, startWidth);
        CGFloat newRotation = atan2(dy, dx) - cornerAngle;

        CGFloat distance = hypot(dx, dy);
        CGFloat diagonal = hypot(startWidth, startHeight);

        if (distance < 1.0)
            distance = 1.0;

        CGFloat sizeScale = distance / diagonal;

        CGFloat newWidth = startWidth * sizeScale;
        CGFloat newHeight = startHeight * sizeScale;

        rect.position = origin;
        rect.bounds = CGRectMake(0,
                                 0,
                                 newWidth,
                                 newHeight);

        rect.transform = CATransform3DMakeRotation(newRotation,
                                                    0,
                                                    0,
                                                    1);

        CGFloat newRotationDegrees = newRotation * (180.0 / M_PI);

        if (isMonth){
            self.config.monthOrigin = CGPointMake(round(origin.x / scaleX),
                                                  round(origin.y / scaleY));
            self.config.monthSize = CGSizeMake(round(newWidth / scaleX),
                                               round(newHeight / scaleY));
            self.config.monthRotation = round(newRotationDegrees);
        }
        else{
            self.config.dayOrigin = CGPointMake(round(origin.x / scaleX),
                                                round(origin.y / scaleY));
            self.config.daySize = CGSizeMake(round(newWidth / scaleX),
                                             round(newHeight / scaleY));
            self.config.dayRotation = round(newRotationDegrees);
        }
    }

    self.monthRotateHandle.position =
        CGPointMake(self.monthRect.bounds.size.width - 5,
                    self.monthRect.bounds.size.height - 5);

    self.dayRotateHandle.position =
        CGPointMake(self.dayRect.bounds.size.width - 5,
                    self.dayRect.bounds.size.height - 5);

    self.dayOriginHandle.position = CGPointMake(-5, -5);
    self.monthOriginHandle.position = CGPointMake(-5, -5);

    [self drawCalendar];

    [CATransaction commit];
    
    if (self.activeHandle == self.dayOriginHandle){
        const SOEncodedKeyPath tDayOrigin = {
            .rootKey = &kSOIconsDockTilePluginDict,
            .components = @[kSOCalendarConfigKeyDayOrigin.key]
        };
        
        [self setPendingIconChangeForKeypath:&tDayOrigin
                                       value:NSStringFromPoint(self.config.dayOrigin)
                                        note:[NSString stringWithFormat:@"Set calendar day origin to %@",
                                              NSStringFromPoint(self.config.dayOrigin)]];
    } else if (self.activeHandle == self.dayRotateHandle){
        const SOEncodedKeyPath tDayRotation = {
            .rootKey = &kSOIconsDockTilePluginDict,
            .components = @[kSOCalendarConfigKeyDayRotation.key]
        };
        
        [self setPendingIconChangeForKeypath:&tDayRotation
                                       value:@(self.config.dayRotation)
                                        note:[NSString stringWithFormat:@"Set calendar day rotation to %f",
                                              self.config.dayRotation]];
        
        const SOEncodedKeyPath tDayWidth = {
            .rootKey = &kSOIconsDockTilePluginDict,
            .components = @[kSOCalendarConfigKeyDayWidth.key]
        };
        
        [self setPendingIconChangeForKeypath:&tDayWidth
                                       value:@(self.config.daySize.width)
                                        note:[NSString stringWithFormat:@"Set calendar day width to %f",
                                              self.config.daySize.width]];
        
        const SOEncodedKeyPath tDayHeight = {
            .rootKey = &kSOIconsDockTilePluginDict,
            .components = @[kSOCalendarConfigKeyDayHeight.key]
        };
        
        [self setPendingIconChangeForKeypath:&tDayHeight
                                       value:@(self.config.daySize.height)
                                        note:[NSString stringWithFormat:@"Set calendar day height to %f",
                                              self.config.daySize.height]];
    } else if (self.activeHandle == self.monthOriginHandle){
        const SOEncodedKeyPath tMonthOrigin = {
            .rootKey = &kSOIconsDockTilePluginDict,
            .components = @[kSOCalendarConfigKeyMonthOrigin.key]
        };
        
        [self setPendingIconChangeForKeypath:&tMonthOrigin
                                       value:NSStringFromPoint(self.config.monthOrigin)
                                        note:[NSString stringWithFormat:@"Set calendar month origin to %@",
                                              NSStringFromPoint(self.config.monthOrigin)]];
    } else if (self.activeHandle == self.monthRotateHandle){
        const SOEncodedKeyPath tMonthRotation = {
            .rootKey = &kSOIconsDockTilePluginDict,
            .components = @[kSOCalendarConfigKeyMonthRotation.key]
        };
        
        [self setPendingIconChangeForKeypath:&tMonthRotation
                                       value:@(self.config.monthRotation)
                                        note:[NSString stringWithFormat:@"Set calendar month rotation to %f",
                                              self.config.monthRotation]];
        
        const SOEncodedKeyPath tMonthWidth = {
            .rootKey = &kSOIconsDockTilePluginDict,
            .components = @[kSOCalendarConfigKeyMonthWidth.key]
        };
        
        [self setPendingIconChangeForKeypath:&tMonthWidth
                                       value:@(self.config.monthSize.width)
                                        note:[NSString stringWithFormat:@"Set calendar month width to %f",
                                              self.config.monthSize.width]];
        
        const SOEncodedKeyPath tMonthHeight = {
            .rootKey = &kSOIconsDockTilePluginDict,
            .components = @[kSOCalendarConfigKeyMonthHeight.key]
        };
        
        [self setPendingIconChangeForKeypath:&tMonthHeight
                                       value:@(self.config.monthSize.height)
                                        note:[NSString stringWithFormat:@"Set calendar month height to %f",
                                              self.config.monthSize.height]];
    }
}

- (void)mouseUp:(NSEvent *)event{
    self.activeHandle = nil;
}

- (CAShapeLayer *)hitTestHandlesWithEvent:(NSEvent *)event{
    CGPoint clickPos = [self locationInCalendarViewWithEvent:event];

    if (CGPointEqualToPoint(clickPos, CGPointZero))
        return nil;

    NSArray<CAShapeLayer *> *layersForTest = @[
        self.dayOriginHandle,
        self.dayRotateHandle,
        self.monthOriginHandle,
        self.monthRotateHandle
    ];

    CAShapeLayer *hitLayerOrNil = nil;

    for (CAShapeLayer *l in layersForTest){
        CGRect translatedRect = [l convertRect:[l bounds]
                                       toLayer:[self compositionView].layer];

        if (!CGRectContainsPoint(translatedRect, clickPos))
            continue;

        hitLayerOrNil = l;
    }

    return hitLayerOrNil;
}

- (CGPoint)locationInCalendarViewWithEvent:(NSEvent *)event{
    CGPoint ret = [event locationInWindow];

    ret = [self.compositionView convertPoint:ret
                                    fromView:self.view.window.contentView];

    return ret;
}

- (void)drawCalendar{
    NSImage *base = self.baseImageWell.image ?: [self loadImageForEncodedKeypath:&tCal];

    if (!base)
        return;

    CGImageRef img = [base CGImageForProposedRect:NULL
                                          context:nil
                                            hints:nil];

    if (!img)
        return;

    CGImageRef outImage = [SOCalendarDrawing drawDateStringsToImage:img
                                                         withConfig:[self config]
                                                           withDate:[NSDate now]];

    if (!outImage)
        return;

    NSImage *drawn = [[NSImage alloc] initWithCGImage:outImage
                                                 size:CGSizeMake(0, 0)];

    [self.compositionView.layer setContents:drawn];
}
@end

@implementation SOCalendarPositioningView

@end
