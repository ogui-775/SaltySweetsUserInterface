//Created by Salty on 2/21/26.

#import "SOBackgroundPageController.h"
#import "../Helpers/SOScaleImageManager.h"
#import <QuartzCore/CAShapeLayer.h>
#import <QuartzCore/CATextLayer.h>
#import <QuartzCore/CATransaction.h>
#import "../Helpers/SOMath.h"

typedef NS_ENUM(NSInteger, SOFrontlineGuide) {
    SOFrontlineGuideNone = 0,
    SOFrontlineGuideLeft,
    SOFrontlineGuideRight,
};

@interface SOBackgroundPageController ()
@property (strong) CALayer * backgroundLayer;
@property (strong) CALayer *frontlineLayer;
@property (strong) CAShapeLayer * lLine;
@property (strong) CAShapeLayer * bLine;
@property (strong) CAShapeLayer * rLine;
@property (strong) CAShapeLayer * tLine;
@property (strong) CATextLayer * lLabel;
@property (strong) CATextLayer * rLabel;
@property (strong) CATextLayer * tLabel;
@property (strong) CATextLayer * bLabel;

@property (assign) SODraggingGuide draggingGuide;

// Frontline slicing guides (left/right only)
@property (strong) CALayer *frontlineGuideLayer;
@property (strong) CAShapeLayer *flLine;
@property (strong) CAShapeLayer *frLine;
@property (strong) CATextLayer *flLabel;
@property (strong) CATextLayer *frLabel;
@property (assign) SOFrontlineGuide frontlineDragging;

@end

@interface CALayer (Private)
- (void)setContentsScaling:(NSString *)scale;
@end

@implementation SOBackgroundPageController

- (void)awakeFromNib{
    [super awakeFromNib];

    self.scaleMgr = [[SOScaleImageManager alloc] initWithOwner:self currentScale:1];
    [self.contentsCenterView setWantsLayer:YES];
    [self.frontlineSlicingView setWantsLayer:YES];

    // Frontline image layer
    self.frontlineLayer = [CALayer layer];
    [self.contentsCenterView.layer setNeedsDisplayOnBoundsChange:YES];
    self.frontlineLayer.contentsGravity = kCAGravityResize;
    self.frontlineSlicingView.layer.needsDisplayOnBoundsChange = YES;
    self.frontlineLayer.autoresizingMask = kCALayerWidthSizable;

    [self.frontlineLayer setFrame:CGRectMake(0,
                                             self.frontlineSlicingView.bounds.size.height / 2 - 5,
                                             self.frontlineSlicingView.bounds.size.width - 2,
                                             self.frontlineSlicingView.bounds.size.height / 3)];
    [self.frontlineSlicingView.layer addSublayer:self.frontlineLayer];

    // Frontline slicing guides 
    self.frontlineGuideLayer = [CALayer layer];
    self.frontlineGuideLayer.frame = self.frontlineSlicingView.layer.bounds;
    [self.frontlineSlicingView.layer addSublayer:self.frontlineGuideLayer];

    self.flLine = [CAShapeLayer layer];
    self.frLine = [CAShapeLayer layer];
    for (CAShapeLayer *line in @[self.flLine, self.frLine]) {
        line.lineWidth = 2.0;
        line.strokeColor = [NSColor redColor].CGColor;
        line.lineDashPhase = 4.0;
        line.lineDashPattern = @[@10, @5, @5, @5];
        [self.frontlineGuideLayer addSublayer:line];
    }
    self.flLabel = [self labelWithString:@"L"];
    self.frLabel = [self labelWithString:@"R"];
    [self.frontlineGuideLayer addSublayer:self.flLabel];
    [self.frontlineGuideLayer addSublayer:self.frLabel];

    NSNumberFormatter *pf = [[NSNumberFormatter alloc] init];
    pf.numberStyle = NSNumberFormatterPercentStyle;
    pf.minimum = @0;
    pf.maximum = @1;
    self.frontlineLeftTextbox.formatter = pf;
    self.frontlineRightTextbox.formatter = pf;

    self.backgroundLayer = [CALayer layer];
    self.backgroundLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    self.backgroundLayer.contentsGravity = kCAGravityResize;
    
    [self.backgroundLayer setFrame:CGRectMake(1,
                                              self.contentsCenterView.layer.frame.size.height/2 - 50,
                                              self.contentsCenterView.layer.frame.size.width - 2,
                                              self.contentsCenterView.layer.frame.size.height / 3)];
    [self.contentsCenterView.layer addSublayer:self.backgroundLayer];

    // Setup image wells
    for (NSImageView * well in @[self.leftImageWell, self.bottomImageWell, self.rightImageWell]){
        NSString * direction = well.identifier;
        for (NSString * scale in @[@"1x", @"2x"]){
            SOEncodedKeyPath key = {
                .rootKey = &kSODockBackgroundAssets,
                .components = @[direction, [NSString stringWithFormat:@"dock%@", scale]]
            };
            [self.scaleMgr registerObject:well withEncodedKeypath:&key scale:[scale isEqualToString:@"1x"] ? 1 : 2];
            if ([direction isEqualToString:@"bottom"])
                [self.scaleMgr registerObject:self.backgroundLayer
                           withEncodedKeypath:&key
                                        scale:[scale isEqualToString:@"1x"] ? 1 : 2];
        }
    }
    for (SODragAwareImageView *well in @[self.middlePart]){
        NSString *direction = well.identifier;
        
        for (NSString *scale in @[@"1x", @"2x"]){
            NSString *dirKey = [direction isEqualToString:@"lp"] ? @"left" : [direction isEqualToString:@"mp"] ? @"middleOrMain" : @"right";
            SOEncodedKeyPath tPath = {
                .rootKey = &kSODockFrontlineAssets,
                .components = @[dirKey, [NSString stringWithFormat:@"frontline%@", scale]]
            };
            [self.scaleMgr registerObject:well
                       withEncodedKeypath:&tPath
                                    scale:[scale isEqualToString:@"1x"] ? 1 : 2];
            [self.scaleMgr registerObject:self.frontlineLayer
                       withEncodedKeypath:&tPath
                                    scale:[scale isEqualToString:@"1x"] ? 1 : 2];
        }
    }

    if (self.leftImageWell.image){
        self.leftFlipButton.enabled = YES;
        self.leftRotateButton.enabled = YES;
    }
    if (self.rightImageWell.image){
        self.rightFlipButton.enabled = YES;
        self.rightRotateButton.enabled = YES;
    }

    // Create guide lines
    self.lLine = [CAShapeLayer layer];
    self.bLine = [CAShapeLayer layer];
    self.rLine = [CAShapeLayer layer];
    self.tLine = [CAShapeLayer layer];

    self.lLabel = [self labelWithString:@"L"];
    self.rLabel = [self labelWithString:@"R"];
    self.tLabel = [self labelWithString:@"T"];
    self.bLabel = [self labelWithString:@"B"];

    NSBezierPath * vertPath = [NSBezierPath bezierPath];
    [vertPath moveToPoint:CGPointMake(0, 0)];
    [vertPath lineToPoint:CGPointMake(0, self.backgroundLayer.frame.size.height)];

    self.lLine.path = vertPath.CGPath;
    self.rLine.path = vertPath.CGPath;

    NSBezierPath * horzPath = [NSBezierPath bezierPath];
    [horzPath moveToPoint:CGPointMake(0, 0)];
    [horzPath lineToPoint:CGPointMake(self.backgroundLayer.frame.size.width, 0)];

    self.bLine.path = horzPath.CGPath;
    self.tLine.path = horzPath.CGPath;

    for (CAShapeLayer * line in @[self.lLine, self.rLine, self.bLine, self.tLine]){
        line.lineWidth = 2.0;
        line.strokeColor = [NSColor redColor].CGColor;
        line.lineDashPhase = 4.0;
        line.lineDashPattern = @[@10, @5, @5, @5];
        [self.backgroundLayer addSublayer:line];
    }

    // Add labels
    [self.backgroundLayer insertSublayer:self.lLabel atIndex:10];
    [self.backgroundLayer insertSublayer:self.rLabel atIndex:11];
    [self.backgroundLayer insertSublayer:self.tLabel atIndex:12];
    [self.backgroundLayer insertSublayer:self.bLabel atIndex:13];
    
    NSNumberFormatter *f = (NSNumberFormatter *)self.tiltLipPercentage.formatter;
    f.maximum = @1;
    f.minimum = @0;
    f.format = @"0%";

    [self refreshOrLoadBaseline];
}

#pragma mark - Refresh baseline

- (void)refreshOrLoadBaseline {
    NSDictionary *centerDict = [self getBaselineForEncodedKey:&kSODockBackgroundContentsCenter];

    CGRect centerRect = CGRectMake([centerDict[@"x"] doubleValue],
                                   [centerDict[@"y"] doubleValue],
                                   [centerDict[@"width"] doubleValue],
                                   [centerDict[@"height"] doubleValue]);
    
    self.contentsCenterX.doubleValue = centerRect.origin.x;
    self.contentsCenterY.doubleValue = centerRect.origin.y;
    self.contentsCenterWidth.doubleValue = centerRect.size.width;
    self.contentsCenterHeight.doubleValue = centerRect.size.height;

    CGFloat w = self.backgroundLayer.bounds.size.width;
    CGFloat h = self.backgroundLayer.bounds.size.height;

    // Normalize edges
    CGFloat left   = CLAMP(0, centerRect.origin.x, 1);
    CGFloat bottom = CLAMP(0, centerRect.origin.y, 1);
    CGFloat right  = CLAMP(left, centerRect.origin.x + centerRect.size.width, 1);
    CGFloat top    = CLAMP(bottom, centerRect.origin.y + centerRect.size.height, 1);

    // Update contentsCenter
    CGRect r = CGRectMake(left, bottom, right - left, top - bottom);
    self.backgroundLayer.contentsCenter = r;

    // Update guides in pixelses (stupid, fat, hobitses)
    CGFloat leftX   = left * w;
    CGFloat rightX  = right * w;
    CGFloat bottomY = bottom * h;
    CGFloat topY    = top * h;

    self.lLine.position = CGPointMake(leftX, 0);
    self.rLine.position = CGPointMake(rightX, 0);
    self.bLine.position = CGPointMake(0, bottomY);
    self.tLine.position = CGPointMake(0, topY);

    // Update labels
    self.lLabel.position = CGPointMake(leftX, h - 12);
    self.rLabel.position = CGPointMake(rightX, 12);
    self.tLabel.position = CGPointMake(w - 12, topY);
    self.bLabel.position = CGPointMake(12, bottomY);

    [self checkFlipButton];
    [self.scaleMgr baselineDidRefresh];
    self.scaleSelector.enabled = YES;
    
    NSString *tiling = [self getBaselineForEncodedKey:&kSODockBackgroundTiling];
    [self.backgroundLayer setContentsScaling:tiling];
    if ([tiling isEqualToString:@"repeat"])
        self.backgroundTiling.state = NSControlStateValueOn;
    
    self.blurRadiusTextbox.doubleValue = [[self getBaselineForEncodedKey:&kSODockBackgroundBlurRadius] doubleValue];

    self.saturationTextbox.intValue = [[self getBaselineForEncodedKey:&kSODockWindowReflectionSaturationAmount] intValue];
    
    self.tiltTextbox.doubleValue = [[self getBaselineForEncodedKey:&kSODockBackgroundTiltAngle] doubleValue];
    self.slantTextbox.doubleValue = [[self getBaselineForEncodedKey:&kSODockSidesTiltAngle] doubleValue];
    self.tiltLipPercentage.doubleValue = [[self getBaselineForEncodedKey:&kSODockBackgroundTiltLipPercentage] doubleValue];
    self.tileBlurTextbox.intValue = [[self getBaselineForEncodedKey:&kSODockTileReflectionBlurAmount] intValue];
    self.tileSigmaXTextbox.intValue = [[self getBaselineForEncodedKey:&kSODockTileReflectionBlurSigmaXAmount] intValue];
    self.tileSigmaYTextbox.intValue = [[self getBaselineForEncodedKey:&kSODockTileReflectionBlurSigmaYAmount] intValue];
    self.tileBrightnessTextbox.doubleValue = [[self getBaselineForEncodedKey:&kSODockTileReflectionBrightnessLevel] doubleValue];
    self.tileColorContrastTextbox.doubleValue = [[self getBaselineForEncodedKey:&kSODockTileReflectionColorContrastAmount] doubleValue];
    self.tileSaturationTextbox.doubleValue = [[self getBaselineForEncodedKey:&kSODockTileReflectionSaturationAmount] doubleValue];
    self.frontlineHeightTextbox.intValue = [[self getBaselineForEncodedKey:&kSODockFrontlineHeight] intValue];
    
    self.frontlineLayer.frame = CGRectMake(0,
                                           (self.frontlineSlicingView.layer.bounds.size.height / 2) - (self.frontlineHeightTextbox.intValue),
                                           self.frontlineSlicingView.layer.bounds.size.width,
                                           self.frontlineHeightTextbox.intValue);
    
    // Frontline left/right slicing (defaults: 0% and 100% when no baseline value exists)
    NSNumber *fl = [self getBaselineForEncodedKey:&kSODockFrontlineSlicingLeftPercentage];
    NSNumber *fr = [self getBaselineForEncodedKey:&kSODockFrontlineSlicingRightPercentage];
    [self applyFrontlineSlicingLeft:fl ? fl.doubleValue : 0.0
                              right:fr ? fr.doubleValue : 1.0
                            persist:NO];
}

- (IBAction)actionOnWell:(NSImageView *)sender{
    NSString * partAndScale = [NSString stringWithFormat:@"dock%@", self.scaleMgr.currentScale == 1 ? @"1x" : @"2x"];
    SOEncodedKeyPath key = {
        .rootKey = &kSODockBackgroundAssets,
        .components = @[sender.identifier, partAndScale]
    };
    
    [self checkFlipButton];
    
    if (!sender.image){
        [self setPendingResourceChangeForKeypath:&key
                                        resource:nil
                                            type:kSOChangeResourceTypeNSImage
                                        filename:[NSString stringWithFormat:@"%@.png", partAndScale]
                                            note:[NSString stringWithFormat:@"Cleared dock background for %@ %@", sender.identifier, partAndScale]
                                    contentScale:self.scaleMgr.currentScale];
        [self.scaleMgr setImage:nil forRegisteredObject:sender];
        return;
    }

    [self setPendingResourceChangeForKeypath:&key
                                    resource:sender.image
                                        type:kSOChangeResourceTypeNSImage
                                    filename:[NSString stringWithFormat:@"%@.png", partAndScale]
                                        note:[NSString stringWithFormat:@"Set dock background for %@ %@", sender.identifier, partAndScale]
                                contentScale:self.scaleMgr.currentScale];
    [self.scaleMgr setImage:sender.image forRegisteredObject:sender];
    return;
}

- (IBAction)actionOnFrontlineWell:(SODragAwareImageView *)sender{
    NSString *partAndScale = [NSString stringWithFormat:@"frontline%@", self.scaleMgr.currentScale == 1 ? @"1x" : @"2x"];
    NSString *dirKey = [sender.identifier isEqualToString:@"lp"] ? @"left" : [sender.identifier isEqualToString:@"mp"] ? @"middleOrMain" : @"right";
    
    SOEncodedKeyPath key = {
        .rootKey = &kSODockFrontlineAssets,
        .components = @[dirKey, partAndScale]
    };
    
    if (!sender.image){
        [self setPendingResourceChangeForKeypath:&key
                                        resource:nil
                                            type:kSOChangeResourceTypeNSImage
                                        filename:[NSString stringWithFormat:@"%@.png", partAndScale]
                                            note:[NSString stringWithFormat:@"Cleared frontline for %@",
                                                  dirKey]
                                    contentScale:self.scaleMgr.currentScale];
        [self.scaleMgr setImage:nil forRegisteredObject:sender];
        return;
    }
    
    [self setPendingResourceChangeForKeypath:&key
                                    resource:sender.image
                                        type:kSOChangeResourceTypeNSImage
                                    filename:[NSString stringWithFormat:@"%@.png", partAndScale]
                                        note:[NSString stringWithFormat:@"Set frontline for %@ to %@",
                                              dirKey, partAndScale]
                                contentScale:self.scaleMgr.currentScale];
    [self.scaleMgr setImage:sender.image forRegisteredObject:sender];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.backgroundLayer setFrame:CGRectMake(1,
                                              self.contentsCenterView.layer.frame.size.height/2 - 50,
                                              self.contentsCenterView.layer.frame.size.width - 2,
                                              self.contentsCenterView.layer.frame.size.height / 3)];
    [self resizeBackgroundLayer:self.backgroundLayer.bounds.size];
    [self updateGuideLinePaths];

    // Keep the frontline overlay and image layer in sync with the slicing view
    self.frontlineGuideLayer.frame = self.frontlineSlicingView.layer.bounds;
    self.frontlineLayer.frame = CGRectMake(0,
                                           self.frontlineLayer.frame.origin.y,
                                           self.frontlineSlicingView.layer.bounds.size.width,
                                           self.frontlineLayer.frame.size.height);
    [self applyFrontlineSlicingLeft:self.frontlineLeftTextbox.doubleValue
                              right:self.frontlineRightTextbox.doubleValue
                            persist:NO];
    [CATransaction commit];
}

- (void)updateGuideLinePaths {
    CGFloat w = self.backgroundLayer.bounds.size.width;
    CGFloat h = self.backgroundLayer.bounds.size.height;
    
    // Horizontal lines: tLine and bLine
    CGMutablePathRef hPath = CGPathCreateMutable();
    CGPathMoveToPoint(hPath, NULL, 0, 0);
    CGPathAddLineToPoint(hPath, NULL, w, 0);
    self.tLine.path = hPath;
    self.bLine.path = hPath;
    CGPathRelease(hPath);
    
    // Vertical lines: lLine and rLine
    CGMutablePathRef vPath = CGPathCreateMutable();
    CGPathMoveToPoint(vPath, NULL, 0, 0);
    CGPathAddLineToPoint(vPath, NULL, 0, h);
    self.lLine.path = vPath;
    self.rLine.path = vPath;
    CGPathRelease(vPath);
}

- (void)resizeBackgroundLayer:(CGSize)newSize {
    CGFloat w = newSize.width;
    CGFloat h = newSize.height;

    CGRect cc = self.backgroundLayer.contentsCenter;
    CGFloat left   = cc.origin.x;
    CGFloat bottom = cc.origin.y;
    CGFloat right  = cc.origin.x + cc.size.width;
    CGFloat top    = cc.origin.y + cc.size.height;

    // Update guide line positions
    self.lLine.position = CGPointMake(left * w, 0);
    self.rLine.position = CGPointMake(right * w, 0);
    self.bLine.position = CGPointMake(0, bottom * h);
    self.tLine.position = CGPointMake(0, top * h);

    // Update labels
    self.lLabel.position = CGPointMake(left * w, h - 12);
    self.rLabel.position = CGPointMake(right * w, 12);
    self.tLabel.position = CGPointMake(w - 12, top * h);
    self.bLabel.position = CGPointMake(12, bottom * h);
}

- (void)checkFlipButton{
    if (self.leftImageWell.image){
        self.leftFlipButton.enabled = YES;
        self.leftRotateButton.enabled = YES;
    }
    else {
        self.leftFlipButton.enabled = NO;
        self.leftRotateButton.enabled = NO;
    }
    
    if (self.rightImageWell.image){
        self.rightFlipButton.enabled = YES;
        self.rightRotateButton.enabled = YES;
    }
    else {
        self.rightFlipButton.enabled = NO;
        self.rightRotateButton.enabled = NO;
    }
}

#pragma mark - Flip left/right image

- (IBAction)flipButtonPressed:(NSButton *)sender{
    NSImageView * iv = [sender.identifier isEqualToString:@"leftFlip"] ? self.leftImageWell : self.rightImageWell;
    NSImage * img = iv.image;
    iv.image = [self flipNSImageVertically:img];
    [self rotationResourceChange:iv];
}

- (NSImage *)flipNSImageVertically:(NSImage *)image {
    if (!image) return nil;
    CGImageRef cgImage = [image CGImageForProposedRect:NULL
                                               context:nil
                                                 hints:nil];
    if (!cgImage) return nil;
    size_t width  = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    CGBitmapInfo bitmapInfo =
        kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
#pragma clang diagnostic pop
    CGContextRef ctx = CGBitmapContextCreate(
        NULL,
        width,
        height,
        8,
        width * 4,
        colorSpace,
        bitmapInfo
    );
    CGColorSpaceRelease(colorSpace);
    if (!ctx) return nil;
    CGContextTranslateCTM(ctx, width, 0);
    CGContextScaleCTM(ctx, -1.0, 1.0);
    CGContextDrawImage(ctx,
                       CGRectMake(0, 0, width, height),
                       cgImage);

    CGImageRef newCGImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    NSImage *flippedImage =
        [[NSImage alloc] initWithCGImage:newCGImage
                                    size:NSMakeSize(width, height)];
    CGImageRelease(newCGImage);
    return flippedImage;
}

#pragma mark - Rotate left/right image

- (IBAction)rotateButtonPressed:(NSButton *)sender{
    NSImageView * iv = [sender.identifier isEqualToString:@"leftRotate"] ? self.leftImageWell : self.rightImageWell;
    NSImage * img = iv.image;
    iv.image = [self rotateNSImage:img byDegrees:90];
    [self rotationResourceChange:iv];
}

- (void)rotationResourceChange:(NSImageView *)view{
    NSString * partAndScale = [NSString stringWithFormat:@"dock%@", self.scaleMgr.currentScale == 1 ? @"1x" : @"2x"];
    SOEncodedKeyPath key = {
        .rootKey = &kSODockBackgroundAssets,
        .components = @[view.identifier, partAndScale]
    };
    
    [self.scaleMgr setImage:view.image forRegisteredObject:view];

    [self setPendingResourceChangeForKeypath:&key
                                    resource:view.image
                                        type:kSOChangeResourceTypeNSImage
                                    filename:[NSString stringWithFormat:@"%@.png", partAndScale]
                                        note:[NSString stringWithFormat:@"Set dock background for %@ %@ with rotation", view.identifier, partAndScale]
                                contentScale:self.scaleMgr.currentScale];
}

- (NSImage *)rotateNSImage:(NSImage *)image byDegrees:(CGFloat)degrees {
    if (!image) return nil;
    CGImageRef cgImage = [image CGImageForProposedRect:NULL
                                               context:nil
                                                 hints:nil];
    if (!cgImage) return nil;
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    size_t rotatedWidth = height;
    size_t rotatedHeight = width;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    CGBitmapInfo bitmapInfo =
        kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
#pragma clang diagnostic pop
    CGContextRef ctx = CGBitmapContextCreate(
        NULL,
        rotatedWidth,
        rotatedHeight,
        8,
        rotatedWidth * 4,
        CGColorSpaceCreateDeviceRGB(),
        bitmapInfo
    );
    CGContextTranslateCTM(ctx, rotatedWidth, 0);
    CGContextRotateCTM(ctx, degrees * M_PI / 180.0);
    CGContextDrawImage(ctx,
                       CGRectMake(0, 0, width, height),
                       cgImage);
    CGImageRef newCGImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    NSImage * rotatedImage = [[NSImage alloc] initWithCGImage:newCGImage
                                                         size:NSMakeSize(rotatedWidth, rotatedHeight)];
    CGImageRelease(newCGImage);
    return rotatedImage;
}

#pragma mark - Set scale for imagewells

- (IBAction)scaleSelectionChanged:(NSSegmentedControl *)sender{
    int newScale = (int)sender.indexOfSelectedItem + 1;
    [self.scaleMgr scaleDidChangeTo:newScale];
    self.backgroundLayer.contentsScale = newScale;
    [self checkFlipButton];
}

#pragma mark - Helpers

- (CATextLayer *)labelWithString:(NSString *)str {
    CATextLayer * label = [CATextLayer layer];
    label.string = str;
    label.fontSize = 12;
    label.alignmentMode = kCAAlignmentCenter;
    label.foregroundColor = NSColor.whiteColor.CGColor;
    label.backgroundColor = NSColor.blackColor.CGColor;
    label.cornerRadius = 4;
    label.contentsScale = NSScreen.mainScreen.backingScaleFactor;
    label.bounds = CGRectMake(0, 0, 20, 16);
    return label;
}

#pragma mark - Live contents center sizing

//Plus tiling
- (IBAction)backgroundTilingWasSet:(NSButton *)sender{
    sender.state == NSControlStateValueOn ? [self setTilingBoolTo:YES] : [self setTilingBoolTo:NO];
}

static NSString * const kCAContentsScalingRepeat = @"repeat";
static NSString * const kCAContentsScalingStretch = @"stretch";
- (void)setTilingBoolTo:(BOOL)val{
    if (val){
        [self.backgroundLayer setContentsScaling:kCAContentsScalingRepeat];
        [self setPendingChangeForKey:&kSODockBackgroundTiling
                               value:kCAContentsScalingRepeat
                                note:[NSString stringWithFormat:@"Set background tiling to repeat"]];
    }
    else{
        [self.backgroundLayer setContentsScaling:kCAContentsScalingStretch];
        [self setPendingChangeForKey:&kSODockBackgroundTiling
                               value:kCAContentsScalingStretch
                                note:[NSString stringWithFormat:@"Set background tiling to stretch"]];
    }
}

- (void)mouseDown:(NSEvent *)event {
    [self.view.window makeFirstResponder:nil];

    // Frontline guides take priority
    CGPoint fp = [self.frontlineGuideLayer convertPoint:event.locationInWindow fromLayer:nil];
    if (CGRectContainsPoint(self.flLabel.frame, fp)) {
        self.frontlineDragging = SOFrontlineGuideLeft;
        return;
    }
    else if (CGRectContainsPoint(self.frLabel.frame, fp)) {
        self.frontlineDragging = SOFrontlineGuideRight;
        return;
    }
    self.frontlineDragging = SOFrontlineGuideNone;

    // Background guides
    CGPoint p = [self.backgroundLayer convertPoint:event.locationInWindow fromLayer:nil];

    if (CGRectContainsPoint(self.lLabel.frame, p))
        self.draggingGuide = SODraggingGuideLeft;
    else if (CGRectContainsPoint(self.rLabel.frame, p))
        self.draggingGuide = SODraggingGuideRight;
    else if (CGRectContainsPoint(self.tLabel.frame, p))
        self.draggingGuide = SODraggingGuideTop;
    else if (CGRectContainsPoint(self.bLabel.frame, p))
        self.draggingGuide = SODraggingGuideBottom;
}

- (void)mouseDragged:(NSEvent *)event {
    // Frontline guides
    if (self.frontlineDragging != SOFrontlineGuideNone) {
        CGPoint fp = [self.frontlineGuideLayer convertPoint:event.locationInWindow fromLayer:nil];
        CGFloat fw = self.frontlineGuideLayer.bounds.size.width;
        CGFloat x  = CLAMP(0, fp.x, fw);

        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (self.frontlineDragging == SOFrontlineGuideLeft)
            self.flLine.position = CGPointMake(MIN(x, self.frLine.position.x), 0);
        else
            self.frLine.position = CGPointMake(MAX(x, self.flLine.position.x), 0);
        [CATransaction commit];

        [self updateFrontlineSlicingFromGuides];
        return;
    }

    // Background guides
    CGPoint p = [self.backgroundLayer convertPoint:event.locationInWindow fromLayer:nil];
    CGFloat w = self.backgroundLayer.bounds.size.width;
    CGFloat h = self.backgroundLayer.bounds.size.height;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    switch (self.draggingGuide) {
        case SODraggingGuideLeft:
            self.lLine.position = CGPointMake(CLAMP(0, p.x, self.rLine.position.x - 1), 0);
            break;
        case SODraggingGuideRight:
            self.rLine.position = CGPointMake(CLAMP(self.lLine.position.x + 1, p.x, w), 0);
            break;
        case SODraggingGuideTop:
            self.tLine.position = CGPointMake(0, CLAMP(self.bLine.position.y + 1, p.y, h));
            break;
        case SODraggingGuideBottom:
            self.bLine.position = CGPointMake(0, CLAMP(0, p.y, self.tLine.position.y - 1));
            break;
        default:
            break;
    }

    [self updateContentsCenterFromGuides];
    [CATransaction commit];
}

- (void)mouseUp:(NSEvent *)event {
    self.frontlineDragging = SOFrontlineGuideNone;

    self.draggingGuide = (SODraggingGuide)0;
}

- (void)updateContentsCenterFromGuides {
    CGFloat w = self.backgroundLayer.bounds.size.width;
    CGFloat h = self.backgroundLayer.bounds.size.height;

    // Normalized positions
    CGFloat left   = CLAMP(0, self.lLine.position.x / w, 1);
    CGFloat right  = CLAMP(left, self.rLine.position.x / w, 1);
    CGFloat bottom = CLAMP(0, self.bLine.position.y / h, 1);
    CGFloat top    = CLAMP(bottom, self.tLine.position.y / h, 1);

    // Update contentsCenter
    CGRect r = CGRectMake(left, bottom, right - left, top - bottom);
    self.backgroundLayer.contentsCenter = r;

    // Pixel positions for guides
    CGFloat leftX   = left * w;
    CGFloat rightX  = right * w;
    CGFloat bottomY = bottom * h;
    CGFloat topY    = top * h;

    self.lLine.position = CGPointMake(leftX, 0);
    self.rLine.position = CGPointMake(rightX, 0);
    self.bLine.position = CGPointMake(0, bottomY);
    self.tLine.position = CGPointMake(0, topY);

    // Labels
    self.lLabel.position = CGPointMake(leftX, h - 12);
    self.rLabel.position = CGPointMake(rightX, 12);
    self.tLabel.position = CGPointMake(w - 12, topY);
    self.bLabel.position = CGPointMake(12, bottomY);
    
    SOEncodedKeyPath t_xPath = {
        .rootKey = &kSODockBackgroundContentsCenter,
        .components = @[@"x"]
    };
    SOEncodedKeyPath t_yPath = {
        .rootKey = &kSODockBackgroundContentsCenter,
        .components = @[@"y"]
    };
    SOEncodedKeyPath t_widthPath = {
        .rootKey = &kSODockBackgroundContentsCenter,
        .components = @[@"width"]
    };
    SOEncodedKeyPath t_heightPath = {
        .rootKey = &kSODockBackgroundContentsCenter,
        .components = @[@"height"]
    };
    
    r.origin.x = ROUND_DP(r.origin.x, 3);
    r.origin.y = ROUND_DP(r.origin.y, 3);
    r.size.width = ROUND_DP(r.size.width, 3);
    r.size.height = ROUND_DP(r.size.height, 3);
    
    [self setPendingChangeForKeypath:&t_xPath
                               value:@(r.origin.x)
                                note:[NSString
                                      stringWithFormat:@"Set contents center value for X for dock background to %f", r.origin.x]
    ];
    [self setPendingChangeForKeypath:&t_yPath
                               value:@(r.origin.y)
                                note:[NSString
                                      stringWithFormat:@"Set contents center value for Y for dock background to %f", r.origin.y]
    ];
    [self setPendingChangeForKeypath:&t_widthPath
                               value:@(r.size.width)
                                note:[NSString
                                      stringWithFormat:@"Set contents center value for Width for dock background to %f", r.size.width]
    ];
    [self setPendingChangeForKeypath:&t_heightPath
                               value:@(r.size.height)
                                note:[NSString
                                      stringWithFormat:@"Set contents center value for Height for dock background to %f", r.size.height]
    ];
    
    self.contentsCenterX.doubleValue = r.origin.x;
    self.contentsCenterY.doubleValue = r.origin.y;
    self.contentsCenterWidth.doubleValue = r.size.width;
    self.contentsCenterHeight.doubleValue = r.size.height;
}

- (IBAction)blurRadiusDidChange:(NSTextField *)sender{
    if (sender.doubleValue < 0)
        sender.doubleValue = 0;
    
    [self setPendingChangeForKey:&kSODockBackgroundBlurRadius
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set background reflection blur radius to %f",
                                  sender.doubleValue]];
}

- (IBAction)saturationDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockWindowReflectionSaturationAmount
                           value:@(sender.intValue)
                            note:[NSString stringWithFormat:@"Set background reflection saturation amount to %i",
                                  sender.intValue]];
}

- (IBAction)tiltDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockBackgroundTiltAngle
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set background tilt angle to %f",
                                  sender.doubleValue]];
}

- (IBAction)slantDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockSidesTiltAngle
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set background slant angle to %f",
                                  sender.doubleValue]];
}

- (IBAction)tiltLipDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockBackgroundTiltLipPercentage
                           value:@(ROUND_DP(sender.doubleValue, 3))
                            note:[NSString stringWithFormat:@"Set tilt bottom lip to %f%%",
                                  ROUND_DP(sender.doubleValue * 100, 3)]];
}

- (IBAction)tileBlurDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockTileReflectionBlurAmount
                           value:@(sender.intValue)
                            note:[NSString stringWithFormat:@"Set tile reflection blur to %i",
                                  sender.intValue]];
}

- (IBAction)tileSigmaXDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockTileReflectionBlurSigmaXAmount
                           value:@(sender.intValue)
                            note:[NSString stringWithFormat:@"Set tile reflection sigma X to %i",
                                  sender.intValue]];
}

- (IBAction)tileSigmaYDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockTileReflectionBlurSigmaYAmount
                           value:@(sender.intValue)
                            note:[NSString stringWithFormat:@"Set tile reflection sigma Y to %i",
                                  sender.intValue]];
}

- (IBAction)tileBrightnessDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockTileReflectionBrightnessLevel
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set tile reflection brightness to %f",
                                  sender.doubleValue]];
}

- (IBAction)tileColorContrastDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockTileReflectionColorContrastAmount
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set tile reflection color contrast to %f",
                                  sender.doubleValue]];
}

- (IBAction)tileSaturationDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockTileReflectionSaturationAmount
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set tile reflection saturation to %f",
                                  sender.doubleValue]];
}

- (IBAction)frontlineHeightDidChange:(NSTextField *)sender{
    [self setPendingChangeForKey:&kSODockFrontlineHeight
                           value:@(sender.intValue)
                            note:[NSString stringWithFormat:@"Set frontline height to %i",
                                  sender.intValue]];
}

#pragma mark - Frontline slicing

- (IBAction)updateFrontlineSlicingFromTextField:(NSTextField *)sender{
    CGFloat left  = ROUND_DP(CLAMP(0, self.frontlineLeftTextbox.doubleValue, 1), 3);
    CGFloat right = ROUND_DP(CLAMP(0, self.frontlineRightTextbox.doubleValue, 1), 3);

    if (sender == self.frontlineLeftTextbox)
        right = MAX(right, left);
    else
        left = MIN(left, right);

    [self applyFrontlineSlicingLeft:left right:right persist:YES];
}

- (void)updateFrontlineSlicingFromGuides{
    CGFloat w = self.frontlineGuideLayer.bounds.size.width;
    if (w <= 0) return;

    CGFloat left  = ROUND_DP(CLAMP(0, self.flLine.position.x / w, 1), 2);
    CGFloat right = ROUND_DP(CLAMP(left, self.frLine.position.x / w, 1), 2);

    [self applyFrontlineSlicingLeft:ROUND_DP(left, 3)
                              right:ROUND_DP(right, 3)
                            persist:YES];
}

// Updates layer, guides, labels and textboxes, and optionally records the pending changes
- (void)applyFrontlineSlicingLeft:(CGFloat)left right:(CGFloat)right persist:(BOOL)persist {
    left  = ROUND_DP(CLAMP(0, left, 1), 2);
    right = ROUND_DP(CLAMP(left, right, 1), 2);

    CGFloat w = self.frontlineGuideLayer.bounds.size.width;
    CGFloat h = self.frontlineGuideLayer.bounds.size.height;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    // Guide line paths (full height of the slicing view)
    CGMutablePathRef vp = CGPathCreateMutable();
    CGPathMoveToPoint(vp, NULL, 0, 0);
    CGPathAddLineToPoint(vp, NULL, 0, h);
    self.flLine.path = vp;
    self.frLine.path = vp;
    CGPathRelease(vp);

    // 3-slice horizontally: full-height center rect
    self.frontlineLayer.contentsCenter = CGRectMake(left, 0, right - left, 1);

    self.flLine.position  = CGPointMake(left * w, 0);
    self.frLine.position  = CGPointMake(right * w, 0);
    self.flLabel.position = CGPointMake(left * w, h - 12);
    self.frLabel.position = CGPointMake(right * w, 12);

    [CATransaction commit];

    self.frontlineLeftTextbox.doubleValue  = left;
    self.frontlineRightTextbox.doubleValue = right;

    if (!persist) return;

    [self setPendingChangeForKey:&kSODockFrontlineSlicingLeftPercentage
                           value:@(left)
                            note:[NSString stringWithFormat:@"Set frontline left slicing to %f%%", left * 100]];
    [self setPendingChangeForKey:&kSODockFrontlineSlicingRightPercentage
                           value:@(right)
                            note:[NSString stringWithFormat:@"Set frontline right slicing to %f%%", right * 100]];
}

- (IBAction)updateContentsCenterFromTextField:(NSTextField *)sender {
    CGFloat value = sender.doubleValue;

    value = CLAMP(0, value, 1);
    value = ROUND_DP(value, 4);

    CGRect r = self.backgroundLayer.contentsCenter;

    NSString *identifier = sender.identifier;

    if ([identifier isEqualToString:@"xtf"]) {
        CGFloat maxX = 1.0 - r.size.width;
        r.origin.x = MIN(value, maxX);
    }
    else if ([identifier isEqualToString:@"ytf"]) {
        CGFloat maxY = 1.0 - r.size.height;
        r.origin.y = MIN(value, maxY);
    }
    else if ([identifier isEqualToString:@"wtf"]) {
        r.size.width = MIN(value, 1.0 - r.origin.x);
    }
    else if ([identifier isEqualToString:@"htf"]) {
        r.size.height = MIN(value, 1.0 - r.origin.y);
    }
    else {
        return;
    }

    self.backgroundLayer.contentsCenter = r;

    SOEncodedKeyPath xPath = {
        .rootKey = &kSODockBackgroundContentsCenter,
        .components = @[@"x"]
    };

    SOEncodedKeyPath yPath = {
        .rootKey = &kSODockBackgroundContentsCenter,
        .components = @[@"y"]
    };

    SOEncodedKeyPath widthPath = {
        .rootKey = &kSODockBackgroundContentsCenter,
        .components = @[@"width"]
    };

    SOEncodedKeyPath heightPath = {
        .rootKey = &kSODockBackgroundContentsCenter,
        .components = @[@"height"]
    };

    [self setPendingChangeForKeypath:&xPath
                               value:@(r.origin.x)
                                note:[NSString stringWithFormat:
                                      @"Set contents center value for X for dock background to %f",
                                      r.origin.x]];

    [self setPendingChangeForKeypath:&yPath
                               value:@(r.origin.y)
                                note:[NSString stringWithFormat:
                                      @"Set contents center value for Y for dock background to %f",
                                      r.origin.y]];

    [self setPendingChangeForKeypath:&widthPath
                               value:@(r.size.width)
                                note:[NSString stringWithFormat:
                                      @"Set contents center value for Width for dock background to %f",
                                      r.size.width]];

    [self setPendingChangeForKeypath:&heightPath
                               value:@(r.size.height)
                                note:[NSString stringWithFormat:
                                      @"Set contents center value for Height for dock background to %f",
                                      r.size.height]];

    self.contentsCenterX.doubleValue = r.origin.x;
    self.contentsCenterY.doubleValue = r.origin.y;
    self.contentsCenterWidth.doubleValue = r.size.width;
    self.contentsCenterHeight.doubleValue = r.size.height;

    CGFloat w = self.backgroundLayer.bounds.size.width;
    CGFloat h = self.backgroundLayer.bounds.size.height;

    CGFloat leftX   = r.origin.x * w;
    CGFloat rightX  = (r.origin.x + r.size.width) * w;
    CGFloat bottomY = r.origin.y * h;
    CGFloat topY    = (r.origin.y + r.size.height) * h;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    self.lLine.position = CGPointMake(leftX, 0);
    self.rLine.position = CGPointMake(rightX, 0);
    self.bLine.position = CGPointMake(0, bottomY);
    self.tLine.position = CGPointMake(0, topY);

    self.lLabel.position = CGPointMake(leftX, h - 12);
    self.rLabel.position = CGPointMake(rightX, 12);
    self.tLabel.position = CGPointMake(w - 12, topY);
    self.bLabel.position = CGPointMake(12, bottomY);

    [CATransaction commit];
}

@end
