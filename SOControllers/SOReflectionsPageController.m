//Created by Salty on 2/23/26.

#import "SOReflectionsPageController.h"

@interface SOReflectionsPageController ()
@property (strong, nonatomic) CALayer * backgroundLayer;
@property (strong, nonatomic) CALayer * backgroundHeightBar;
@property (assign) CGRect cc;
@property (assign) CGFloat cached1xLeftEdge;
@property (assign) CGFloat cached1xBottomEdge;
@property (assign) CGFloat cached1xRightEdge;
@property (assign) CGFloat cached2xLeftEdge;
@property (assign) CGFloat cached2xBottomEdge;
@property (assign) CGFloat cached2xRightEdge;
@end

static inline CGRect RotatedContentsCenter(CGRect center, NSUInteger orientationIndex){
    if (orientationIndex == 0){
        CGRect rotated;
        rotated.origin.x = center.origin.y;
        rotated.origin.y = center.origin.x;
        rotated.size.width  = center.size.height;
        rotated.size.height = center.size.width;
        return rotated;
    }
    else if (orientationIndex == 1){
        return center;
    } else if (orientationIndex == 2){
        CGRect rotated;
        rotated.origin.x = 1.0 - (center.origin.y + center.size.height);
        rotated.origin.y = center.origin.x;
        rotated.size.width  = center.size.height;
        rotated.size.height = center.size.width;
        return rotated;
    }
    
    return CGRectNull;
}

@implementation SOReflectionsPageController

- (CGRect)edgeRectForOrientation:(NSUInteger)orientationIndex{
    CGFloat currSetUIEdge = [self cachedCGFloatForSetUI];
    switch (orientationIndex) {
        case 0:
            return CGRectMake(self.backgroundPositioningView.layer.bounds.size.width / 2 - 50,
                              1,
                              100 * currSetUIEdge,
                              self.backgroundPositioningView.layer.bounds.size.height - 2);
        case 1:
            return CGRectMake(1,
                              self.backgroundPositioningView.layer.bounds.size.height / 2 - 50,
                              self.backgroundPositioningView.layer.bounds.size.width - 2,
                              100 * currSetUIEdge);
            break;
        case 2: {
            CGRect bgFrame = [self frameRectForOrientation:orientationIndex];
            CGFloat barWidth = bgFrame.size.width * currSetUIEdge;

            return CGRectMake(CGRectGetMaxX(bgFrame) - barWidth,
                              bgFrame.origin.y,
                              barWidth,
                              bgFrame.size.height);
        }
            break;
        default:
            break;
    }
    return CGRectNull;
}

- (CGRect)frameRectForOrientation:(NSUInteger)orientationIndex{
    switch (orientationIndex) {
        case 0:
        case 2:
            return CGRectMake(self.backgroundPositioningView.layer.bounds.size.width / 2 - 50, 1,
                              100, self.backgroundPositioningView.layer.bounds.size.height - 2);
            break;
        case 1:
            return CGRectMake(1, self.backgroundPositioningView.layer.bounds.size.height / 2 - 50, self.backgroundPositioningView.layer.bounds.size.width - 2, 100);
            break;
        default:
            break;
    }
    return CGRectNull;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self.backgroundPositioningView setWantsLayer:YES];
    self.backgroundPositioningView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.backgroundPositioningView.layer.delegate = self;
    self.backgroundPositioningView.layer.needsDisplayOnBoundsChange = YES;
    self.valueMgr = [[SOScaleControlValueManager alloc] initWithOwner:self currentScale:1];
    
    
    //@1x
    SOEncodedKeyPath t1xEdgeKeyLeft = {
        .rootKey = &kSODockEdgeMultiplier,
        .components = @[@"left1x"]
    };
    
    [self.edgeTextbox setDoubleValue:[[self getBaselineForEncodedKeypath:&t1xEdgeKeyLeft] doubleValue]];
    [self.edgeStepper setDoubleValue:[[self getBaselineForEncodedKeypath:&t1xEdgeKeyLeft] doubleValue]];
    
    [(NSNumberFormatter *)self.edgeTextbox.formatter setNumberStyle:NSNumberFormatterPercentStyle];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    //@1x
    SOEncodedKeyPath t1xEdgeKeyLeft = {
        .rootKey = &kSODockEdgeMultiplier,
        .components = @[@"left1x"]
    };
    SOEncodedKeyPath t1xEdgeKeyBottom = {
        .rootKey = &kSODockEdgeMultiplier,
        .components = @[@"bottom1x"]
    };
    SOEncodedKeyPath t1xEdgeKeyRight = {
        .rootKey = &kSODockEdgeMultiplier,
        .components = @[@"right1x"]
    };
    //@2x
    SOEncodedKeyPath t2xEdgeKeyLeft = {
        .rootKey = &kSODockEdgeMultiplier,
        .components = @[@"left2x"]
    };
    SOEncodedKeyPath t2xEdgeKeyBottom = {
        .rootKey = &kSODockEdgeMultiplier,
        .components = @[@"bottom2x"]
    };
    SOEncodedKeyPath t2xEdgeKeyRight = {
        .rootKey = &kSODockEdgeMultiplier,
        .components = @[@"right2x"]
    };
    
    self.windowReflectionEnabledRadio.state =
        [[self getBaselineForEncodedKey:&kSODockWindowReflectionEnabled] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.windowReflectionDisabledRadio.state = !self.windowReflectionEnabledRadio.state;
    
    self.iconReflectionEnabledRadio.state =
        [[self getBaselineForEncodedKey:&kSODockTileReflectionEnabled] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.iconReflectionDisabledRadio.state = !self.iconReflectionEnabledRadio.state;
    
    if (self.windowReflectionEnabledRadio.state == NSControlStateValueOff){
        self.windowReflectionInsetSlider.enabled = NO;
        self.windowReflectionInsetTextbox.enabled = NO;
        self.windowReflectionOpacitySlider.enabled = NO;
        self.windowReflectionOpacityTextbox.enabled = NO;
    }
    
    if (self.iconReflectionEnabledRadio.state == NSControlStateValueOff){
        self.iconReflectionHeightSlider.enabled = NO;
        self.iconReflectionHeightTextbox.enabled = NO;
        self.iconReflectionOpacitySlider.enabled = NO;
        self.iconReflectionOpacityTextbox.enabled = NO;
    }
    
    int windowInset = [[self getBaselineForEncodedKey:&kSODockWindowReflectionInset] intValue];
    self.windowReflectionInsetSlider.intValue = windowInset;
    self.windowReflectionInsetTextbox.intValue = windowInset;
    
    CGFloat windowOpacity = [[self getBaselineForEncodedKey:&kSODockWindowReflectionOpacity] floatValue];
    self.windowReflectionOpacitySlider.floatValue = windowOpacity;
    self.windowReflectionOpacityTextbox.floatValue = windowOpacity;
    
    CGFloat iconHeight = [[self getBaselineForEncodedKey:&kSODockTileReflectionHeight] floatValue];
    self.iconReflectionHeightSlider.floatValue = iconHeight;
    self.iconReflectionHeightTextbox.floatValue = iconHeight;
    
    CGFloat iconOpacity = [[self getBaselineForEncodedKey:&kSODockTileReflectionOpacity] floatValue];
    self.iconReflectionOpacitySlider.floatValue = iconOpacity;
    self.iconReflectionOpacityTextbox.floatValue = iconOpacity;
    
    self.reflectionsOnLeftEnabledCheckbox.state = [[self getBaselineForEncodedKey:&kSODockBackgroundReflectiveOnLeft] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    
    self.reflectionsOnRightEnabledCheckbox.state = [[self getBaselineForEncodedKey:&kSODockBackgroundReflectiveOnRight] boolValue] ?
        NSControlStateValueOn : NSControlStateValueOff;
    
    NSDictionary * centerDict = [self getBaselineForEncodedKey:&kSODockBackgroundContentsCenter];
    self.cc = CGRectMake([centerDict[@"x"] floatValue], [centerDict[@"y"] floatValue],
                                                     [centerDict[@"width"] floatValue], [centerDict[@"height"] floatValue]);
    
    [self compositeInteriorOfImageView];
    CGRect bgFrame = [self frameRectForOrientation:self.orientationSelector.indexOfSelectedItem];
    [self.backgroundLayer setFrame:bgFrame];
    [self.backgroundLayer
        setContentsCenter:RotatedContentsCenter(self.cc, self.orientationSelector.indexOfSelectedItem)];
    
    self.cached1xLeftEdge = [[self getBaselineForEncodedKeypath:&t1xEdgeKeyLeft] doubleValue];
    self.cached1xBottomEdge = [[self getBaselineForEncodedKeypath:&t1xEdgeKeyBottom] doubleValue];
    self.cached1xRightEdge = [[self getBaselineForEncodedKeypath:&t1xEdgeKeyRight] doubleValue];

    self.cached2xLeftEdge = [[self getBaselineForEncodedKeypath:&t2xEdgeKeyLeft] doubleValue];
    self.cached2xBottomEdge = [[self getBaselineForEncodedKeypath:&t2xEdgeKeyBottom] doubleValue];
    self.cached2xRightEdge = [[self getBaselineForEncodedKeypath:&t2xEdgeKeyRight] doubleValue];
    
    [self.backgroundHeightBar setFrame:[self edgeRectForOrientation:self.orientationSelector.indexOfSelectedItem]];
}

#pragma mark - General Settings
- (IBAction)windowReflectionsEnabledChanged:(NSButton *)sender{
    BOOL enabled = sender.tag == 1;
    
    self.windowReflectionInsetSlider.enabled = enabled;
    self.windowReflectionInsetTextbox.enabled = enabled;
    self.windowReflectionOpacitySlider.enabled = enabled;
    self.windowReflectionOpacityTextbox.enabled = enabled;
    
    [self setPendingBoolChangeForKey:&kSODockWindowReflectionEnabled
                             enabled:enabled
                                note:[NSString stringWithFormat:@"Set window reflections enabled to %i", enabled]];
}

- (IBAction)iconReflectionsEnabledChanged:(NSButton *)sender{
    BOOL enabled = sender.tag == 1;
    
    self.iconReflectionHeightSlider.enabled = enabled;
    self.iconReflectionHeightTextbox.enabled = enabled;
    self.iconReflectionOpacitySlider.enabled = enabled;
    self.iconReflectionOpacityTextbox.enabled = enabled;
    
    [self setPendingBoolChangeForKey:&kSODockTileReflectionEnabled
                             enabled:enabled
                                note:[NSString stringWithFormat:@"Set icon reflections enabled to %i", enabled]];
}

#pragma mark - Window Reflection Settings
- (IBAction)windowReflectionOpacityChanged:(NSControl *)sender{
    if (sender.floatValue < 0)
        sender.floatValue = 0;
    
    if (sender.floatValue > 1)
        sender.floatValue = 1;
    
    self.windowReflectionOpacitySlider.floatValue = sender.floatValue;
    self.windowReflectionOpacityTextbox.floatValue = sender.floatValue;
    
    [self setPendingChangeForKey:&kSODockWindowReflectionOpacity
                           value:@(sender.floatValue)
                            note:[NSString stringWithFormat:@"Set window reflection opacity to %f", sender.floatValue]];
}

- (IBAction)windowReflectionInsetChanged:(NSControl *)sender{
    self.windowReflectionInsetSlider.intValue = sender.intValue;
    self.windowReflectionInsetTextbox.intValue = sender.intValue;
    
    [self setPendingChangeForKey:&kSODockWindowReflectionInset
                           value:@(sender.intValue)
                            note:[NSString stringWithFormat:@"Set window reflection inset to %i", sender.intValue]];
}

- (void)compositeInteriorOfImageView{
    CALayer * centralImageLayer = self.backgroundPositioningView.layer;
    
    for (CALayer * sub in centralImageLayer.sublayers){
        if ([sub.name isEqualToString:@"bl"])
            self.backgroundLayer = sub;
        
        if ([sub.name isEqualToString:@"bh"])
            self.backgroundHeightBar = sub;
    }
    
    if (!self.backgroundLayer){
        self.backgroundLayer = [CALayer layer];
        self.backgroundLayer.delegate = self;
        self.backgroundLayer.needsDisplayOnBoundsChange = YES;
        self.backgroundLayer.name = @"bl";
        self.backgroundLayer.contentsGravity = kCAGravityResize;
        self.backgroundLayer.autoresizingMask = kCALayerWidthSizable;
        [centralImageLayer addSublayer:self.backgroundLayer];
    }
    
    if (!self.backgroundHeightBar){
        self.backgroundHeightBar = [CALayer layer];
        self.backgroundHeightBar.delegate = self;
        self.backgroundHeightBar.needsDisplayOnBoundsChange = YES;
        self.backgroundHeightBar.name = @"bh";
        self.backgroundHeightBar.contentsGravity = kCAGravityResize;
        self.backgroundHeightBar.borderColor = [NSColor magentaColor].CGColor;
        self.backgroundHeightBar.borderWidth = 1;
        self.backgroundHeightBar.autoresizingMask = kCALayerWidthSizable;
        [centralImageLayer addSublayer:self.backgroundHeightBar];
    }
    
    NSString * scale = self.scaleSelector.indexOfSelectedItem == 0 ? @"1x" : @"2x";
    NSString * orientation = @"bottom";
    switch (self.orientationSelector.indexOfSelectedItem) {
        case 0:
            orientation = @"left";
            break;
        case 1:
            orientation = @"bottom";
            break;
        case 2:
            orientation = @"right";
            break;
        default:
            break;
    }
    
    SOEncodedKeyPath backgroundKeypath = {
        .rootKey = &kSODockBackgroundAssets,
        .components = @[orientation, [NSString stringWithFormat:@"dock%@", scale]]
    };
    
    self.backgroundLayer.contents = [self loadImageForEncodedKeypath:&backgroundKeypath];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer{
    [self compositeInteriorOfImageView];
}

- (IBAction)scaleDidChange:(NSSegmentedControl *)sender{
    self.backgroundLayer.contentsScale = sender.indexOfSelectedItem + 1;
    CGFloat val = [self cachedCGFloatForSetUI];
    self.edgeTextbox.doubleValue = val;
    self.edgeStepper.doubleValue = val;
    [self compositeInteriorOfImageView];
    CGRect bgFrame = [self frameRectForOrientation:self.orientationSelector.indexOfSelectedItem];

    [self.backgroundLayer setFrame:bgFrame];
    [self.backgroundHeightBar setFrame:[self edgeRectForOrientation:self.orientationSelector.indexOfSelectedItem]];
    [self.backgroundLayer
        setContentsCenter:RotatedContentsCenter(self.cc, self.orientationSelector.indexOfSelectedItem)];
}

- (IBAction)orientationDidChanage:(NSSegmentedControl *)sender{
    CGFloat val = [self cachedCGFloatForSetUI];
    self.edgeTextbox.doubleValue = val;
    self.edgeStepper.doubleValue = val;
    [self compositeInteriorOfImageView];
    CGRect bgFrame = [self frameRectForOrientation:self.orientationSelector.indexOfSelectedItem];

    [self.backgroundLayer setFrame:bgFrame];
    [self.backgroundHeightBar setFrame:[self edgeRectForOrientation:self.orientationSelector.indexOfSelectedItem]];
    [self.backgroundLayer
        setContentsCenter:RotatedContentsCenter(self.cc, self.orientationSelector.indexOfSelectedItem)];
}

- (IBAction)edgeDidChange:(NSControl *)sender{
    if (sender.doubleValue < 0)
        sender.doubleValue = 0;
    if (sender.doubleValue > 1)
        sender.doubleValue = 1;
    
    self.edgeTextbox.doubleValue = sender.doubleValue;
    self.edgeStepper.doubleValue = sender.doubleValue;
    
    NSString * scale = (int)self.scaleSelector.indexOfSelectedItem + 1 == 1 ? @"1x" : @"2x";
    NSString * orientation = @"";
    switch(self.orientationSelector.indexOfSelectedItem){
        case 0:
            orientation = @"left";
            if ([scale isEqualToString:@"1x"])
                self.cached1xLeftEdge = sender.doubleValue;
            else
                self.cached2xLeftEdge = sender.doubleValue;

            break;
        case 1:
            orientation = @"bottom";
            if ([scale isEqualToString:@"1x"])
                self.cached1xBottomEdge = sender.doubleValue;
            else
                self.cached2xBottomEdge = sender.doubleValue;
            
            break;
        case 2:
            orientation = @"right";
            if ([scale isEqualToString:@"1x"])
                self.cached1xRightEdge = sender.doubleValue;
            else
                self.cached2xRightEdge = sender.doubleValue;
            
            break;
        default:
            orientation = @"left";
            break;
    }
    NSString * composite = [NSString stringWithFormat:@"%@%@", orientation, scale];
    SOEncodedKeyPath tSetKey = {
        .rootKey = &kSODockEdgeMultiplier,
        .components = @[composite]
    };
    
    [self setPendingChangeForKeypath:&tSetKey
                               value:@(sender.doubleValue)
                                note:[NSString stringWithFormat:@"Set edge percentage to %f for %@", sender.doubleValue, composite]];
    
    [self.backgroundHeightBar setFrame:[self edgeRectForOrientation:self.orientationSelector.indexOfSelectedItem]];
}

- (CGFloat)cachedCGFloatForSetUI{
    CGFloat retVal = 0;
    
    if (self.scaleSelector.indexOfSelectedItem == 0){
        switch (self.orientationSelector.indexOfSelectedItem) {
            case 0:
                retVal = self.cached1xLeftEdge;
                break;
            case 1:
                retVal = self.cached1xBottomEdge;
                break;
            case 2:
                retVal = self.cached1xRightEdge;
            default:
                break;
        }
    } else {
        switch (self.orientationSelector.indexOfSelectedItem) {
            case 0:
                retVal = self.cached2xLeftEdge;
                break;
            case 1:
                retVal = self.cached2xBottomEdge;
                break;
            case 2:
                retVal = self.cached2xRightEdge;
            default:
                break;
        }
    }
    
    return retVal;
}

#pragma mark - Icon Reflection Settings
- (IBAction)iconReflectionOpacityChanged:(NSControl *)sender{
    if (sender.floatValue < 0)
        sender.floatValue = 0;
    
    if (sender.floatValue > 1)
        sender.floatValue = 1;
    
    self.iconReflectionOpacitySlider.floatValue = sender.floatValue;
    self.iconReflectionOpacityTextbox.floatValue = sender.floatValue;
    
    [self setPendingChangeForKey:&kSODockTileReflectionOpacity
                           value:@(sender.floatValue)
                            note:[NSString stringWithFormat:@"Set icon reflection opacity to %f", sender.floatValue]];
}

- (IBAction)iconReflectionHeightChanged:(NSControl *)sender{
    self.iconReflectionHeightSlider.floatValue = sender.floatValue;
    self.iconReflectionHeightTextbox.floatValue = sender.floatValue;
    
    [self setPendingChangeForKey:&kSODockTileReflectionHeight
                           value:@(sender.floatValue)
                            note:[NSString stringWithFormat:@"Set icon reflection height to %f", sender.floatValue]];
}

#pragma mark - Side Dock Reflection Settings
- (IBAction)leftSideDockReflectionsEnabledChanged:(NSButton *)sender{
    [self setPendingBoolChangeForKey:&kSODockBackgroundReflectiveOnLeft
                             enabled:sender.state == NSControlStateValueOn
                                note:[NSString stringWithFormat:@"Set left side dock reflections enabled to %i", sender.state == NSControlStateValueOn]];
}

- (IBAction)rightSideDockReflectionsEnabledChanged:(NSButton *)sender{
    [self setPendingBoolChangeForKey:&kSODockBackgroundReflectiveOnRight
                             enabled:sender.state == NSControlStateValueOn
                                note:[NSString stringWithFormat:@"Set right side dock reflections enabled to %i", sender.state == NSControlStateValueOn]];
}

#pragma mark - Layout auto
- (void)viewDidLayout{
    [super viewDidLayout];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGRect bgFrame = [self frameRectForOrientation:self.orientationSelector.indexOfSelectedItem];
    [self.backgroundLayer setFrame:bgFrame];
    [self.backgroundLayer
        setContentsCenter:RotatedContentsCenter(self.cc, self.orientationSelector.indexOfSelectedItem)];
    [self.backgroundHeightBar setFrame:[self edgeRectForOrientation:self.orientationSelector.indexOfSelectedItem]];
    [CATransaction commit];
}
@end
