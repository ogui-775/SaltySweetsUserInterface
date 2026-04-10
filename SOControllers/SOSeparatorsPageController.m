//Created by Salty on 2/18/26.

#import "SOSeparatorsPageController.h"

@interface SOSeparatorsPageController ()
@property (strong, nonatomic) CALayer * backgroundLayer;
@property (strong, nonatomic) CALayer * separatorLayer;
@end

@implementation SOSeparatorsPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.scaleMgr = [[SOScaleImageManager alloc] initWithOwner:self currentScale:(int)self.scaleSelector.selectedSegment + 1];
    self.scaleValMgr = [[SOScaleControlValueManager alloc] initWithOwner:self currentScale:(int)self.scaleSelector.selectedSegment + 1];
    
    [self.centralImageView setWantsLayer:YES];
    self.centralImageView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [self refreshOrLoadBaseline];
    
    self.centralImageView.layer.delegate = self;
    self.centralImageView.layer.needsDisplayOnBoundsChange = YES;
    
    SOEncodedKeyPath separatorKeypath1x = {
        .rootKey = &kSODockSeparatorAssets,
        .components = @[@"separator1x"]
    };
    SOEncodedKeyPath separatorKeypath2x = {
        .rootKey = &kSODockSeparatorAssets,
        .components = @[@"separator2x"]
    };
    SOEncodedKeyPath heightKeypath1x = {
        .rootKey = &kSODockSeparatorHeightMultiplier,
        .components = @[@"1x"]
    };
    SOEncodedKeyPath heightKeypath2x = {
        .rootKey = &kSODockSeparatorHeightMultiplier,
        .components = @[@"2x"]
    };
    SOEncodedKeyPath originKeypath1x = {
        .rootKey = &kSODockSeparatorOriginMultiplier,
        .components = @[@"1x"]
    };
    SOEncodedKeyPath originKeypath2x = {
        .rootKey = &kSODockSeparatorOriginMultiplier,
        .components = @[@"2x"]
    };
    SOEncodedKeyPath t1xGravity = {
        .rootKey = &kSODockSeparatorContentsGravity,
        .components = @[@"1x"]
    };
    SOEncodedKeyPath t2xGravity = {
        .rootKey = &kSODockSeparatorContentsGravity,
        .components = @[@"2x"]
    };
    
    [self.scaleMgr registerObject:self.separatorLayer withEncodedKeypath:&separatorKeypath1x scale:1];
    [self.scaleMgr registerObject:self.separatorLayer withEncodedKeypath:&separatorKeypath2x scale:2];
    
    [self.scaleValMgr registerObject:self.heightSlider withEncodedKeypath:&heightKeypath1x scale:1 valueType:SOValueEncodingCGFloat];
    [self.scaleValMgr registerObject:self.heightTextbox withEncodedKeypath:&heightKeypath1x scale:1 valueType:SOValueEncodingCGFloat];
    [self.scaleValMgr registerObject:self.heightTextbox withEncodedKeypath:&heightKeypath2x scale:2 valueType:SOValueEncodingCGFloat];
    [self.scaleValMgr registerObject:self.heightSlider withEncodedKeypath:&heightKeypath2x scale:2 valueType:SOValueEncodingCGFloat];
    [self.scaleValMgr registerObject:self.originSlider withEncodedKeypath:&originKeypath1x scale:1 valueType:SOValueEncodingCGFloat];
    [self.scaleValMgr registerObject:self.originTextbox withEncodedKeypath:&originKeypath1x scale:1 valueType:SOValueEncodingCGFloat];
    [self.scaleValMgr registerObject:self.originTextbox withEncodedKeypath:&originKeypath2x scale:2 valueType:SOValueEncodingCGFloat];
    [self.scaleValMgr registerObject:self.originSlider withEncodedKeypath:&originKeypath2x scale:2 valueType:SOValueEncodingCGFloat];
    [self.scaleValMgr registerObject:self.resizeComboBox withEncodedKeypath:&t1xGravity scale:1 valueType:SOValueEncodingNSString];
    [self.scaleValMgr registerObject:self.resizeComboBox withEncodedKeypath:&t2xGravity scale:2 valueType:SOValueEncodingNSString];
    [self.resizeComboBox addItemsWithObjectValues:[self resizeArray]];
    [self.resizeComboBox setNumberOfVisibleItems:[self resizeArray].count];
}

- (NSArray<CALayerContentsGravity> *)resizeArray{
    return @[
        kCAGravityTop,
        kCAGravityLeft,
        kCAGravityRight,
        kCAGravityBottom,
        kCAGravityCenter,
        kCAGravityResize,
        kCAGravityTopLeft,
        kCAGravityTopRight,
        kCAGravityBottomLeft,
        kCAGravityBottomRight,
        kCAGravityResizeAspect,
        kCAGravityResizeAspectFill
    ];
}

- (void)refreshOrLoadBaseline{
    int currentScale = (int)self.scaleSelector.selectedSegment + 1;
    
    if (currentScale == 1){
        SOEncodedKeyPath t1xHeight = {
            .rootKey = &kSODockSeparatorHeightMultiplier,
            .components = @[@"1x"]
        };
        SOEncodedKeyPath t1xOrigin = {
            .rootKey = &kSODockSeparatorOriginMultiplier,
            .components = @[@"1x"]
        };
        SOEncodedKeyPath t1xGravity = {
            .rootKey = &kSODockSeparatorContentsGravity,
            .components = @[@"1x"]
        };
        
        CGFloat heightMultiplier      = [[self getBaselineForEncodedKeypath:&t1xHeight] doubleValue];
        
        self.heightSlider.doubleValue = heightMultiplier;
        self.heightTextbox.doubleValue= heightMultiplier;
        [(NSNumberFormatter *)self.heightTextbox.formatter setNumberStyle:NSNumberFormatterPercentStyle];
        
        CGFloat originMultiplier      = [[self getBaselineForEncodedKeypath:&t1xOrigin] doubleValue];
        
        self.originSlider.doubleValue = originMultiplier;
        self.originTextbox.doubleValue= originMultiplier;
        [(NSNumberFormatter *)self.originTextbox.formatter setNumberStyle:NSNumberFormatterPercentStyle];
        
        [self.resizeComboBox setStringValue:[self getBaselineForEncodedKeypath:&t1xGravity]];
    } else {
        SOEncodedKeyPath t2xHeight = {
            .rootKey = &kSODockSeparatorHeightMultiplier,
            .components = @[@"2x"]
        };
        SOEncodedKeyPath t2xOrigin = {
            .rootKey = &kSODockSeparatorOriginMultiplier,
            .components = @[@"2x"]
        };
        SOEncodedKeyPath t2xGravity = {
            .rootKey = &kSODockSeparatorContentsGravity,
            .components = @[@"2x"]
        };
        
        CGFloat heightMultiplier      = [[self getBaselineForEncodedKeypath:&t2xHeight] doubleValue];
        
        self.heightSlider.doubleValue = heightMultiplier;
        self.heightTextbox.doubleValue= heightMultiplier;
        [(NSNumberFormatter *)self.heightTextbox.formatter setNumberStyle:NSNumberFormatterPercentStyle];
        
        CGFloat originMultiplier      = [[self getBaselineForEncodedKeypath:&t2xOrigin] doubleValue];
        
        self.originSlider.doubleValue = originMultiplier;
        self.originTextbox.doubleValue= originMultiplier;
        [(NSNumberFormatter *)self.originTextbox.formatter setNumberStyle:NSNumberFormatterPercentStyle];
        
        [self.resizeComboBox setStringValue:[self getBaselineForEncodedKeypath:&t2xGravity]];
    }
    self.scaleSelector.enabled    = [[self getBaselineForEncodedKey:&kSODockUsesRetinaResourcesWhereRequested] boolValue];
    
    [self compositeInteriorOfImageView];
    [self.scaleMgr baselineDidRefresh];
    [self.scaleValMgr baselineDidRefresh];
    [self contentsGravityChanged:nil];
}

- (IBAction)contentsGravityChanged:(id)sender{
    CALayerContentsGravity gravity = [self resizeArray][[[self resizeArray] indexOfObjectPassingTest:^BOOL(CALayerContentsGravity obj, NSUInteger idx, BOOL * stop) {
        return [obj isEqualToString:self.resizeComboBox.stringValue];
    }]];
    
    [self.scaleValMgr setValue:[sender stringValue] forRegisteredObject:sender];
    
    self.separatorLayer.contentsGravity = gravity;
    NSString * scaleKey = self.scaleSelector.selectedSegment + 1 == 1 ? @"1x" : @"2x";
    SOEncodedKeyPath tGravity = {
        .rootKey = &kSODockSeparatorContentsGravity,
        .components = @[scaleKey]
    };
    
    [self setPendingChangeForKeypath:&tGravity
                           value:gravity
                            note:[NSString stringWithFormat:@"Set separator contents gravity to %@ for scale %@", gravity, scaleKey]];
}

- (IBAction)backgroundSelectionChanged:(NSSegmentedControl *)sender{
    switch(sender.indexOfSelectedItem){
        case 0:
            self.centralImageView.layer.backgroundColor = [NSColor blackColor].CGColor;
            break;
        case 1:
            self.centralImageView.layer.backgroundColor = [NSColor whiteColor].CGColor;
            break;
    }
}

- (void)compositeInteriorOfImageView{
    CALayer * centralImageLayer = self.centralImageView.layer;
    
    for (CALayer * sub in centralImageLayer.sublayers){
        if ([sub.name isEqualToString:@"sl"])
            self.separatorLayer = sub;
        
        if ([sub.name isEqualToString:@"bl"])
            self.backgroundLayer = sub;
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
    
    if (!self.separatorLayer){
        self.separatorLayer = [CALayer layer];
        self.separatorLayer.delegate = self;
        self.separatorLayer.needsDisplayOnBoundsChange = YES;
        self.separatorLayer.name = @"sl";
        [centralImageLayer insertSublayer:self.separatorLayer above:self.backgroundLayer];
    }
    
    NSString * scale = self.scaleSelector.indexOfSelectedItem == 0 ? @"1x" : @"2x";
    
    SOEncodedKeyPath backgroundKeypath = {
        .rootKey = &kSODockBackgroundAssets,
        .components = @[@"bottom", [NSString stringWithFormat:@"dock%@", scale]]
    };
    
    self.backgroundLayer.contents = [self loadImageForEncodedKeypath:&backgroundKeypath];
    [self.scaleMgr scaleDidChangeTo:(int)self.scaleSelector.indexOfSelectedItem + 1];
    [self.scaleValMgr scaleDidChangeTo:(int)self.scaleSelector.indexOfSelectedItem + 1];
    
    if (self.separatorLayer.contents)
        self.fileSystemAccessor.image = [NSImage imageWithSystemSymbolName:@"xmark" accessibilityDescription:nil];
    
    NSDictionary * centerDict = [self getBaselineForEncodedKey:&kSODockBackgroundContentsCenter];
    CGRect cc = CGRectMake([centerDict[@"x"] floatValue], [centerDict[@"y"] floatValue],
                           [centerDict[@"width"] floatValue], [centerDict[@"height"] floatValue]);
    self.backgroundLayer.contentsCenter = cc;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer{
    [self compositeInteriorOfImageView];
}

- (IBAction)adjustSeparatorHeight:(NSTextField *)sender{
    self.heightSlider.doubleValue = sender.doubleValue;
    self.heightTextbox.doubleValue= sender.doubleValue;
    
    CGRect slCurrFrame = self.separatorLayer.frame;
    slCurrFrame.size.height = sender.doubleValue * 100;
    [self.separatorLayer setFrame:slCurrFrame];
    
    NSString * scaleKey = self.scaleSelector.selectedSegment + 1 == 1 ? @"1x" : @"2x";
    SOEncodedKeyPath tSeparator = {
        .rootKey = &kSODockSeparatorHeightMultiplier,
        .components = @[scaleKey]
    };
    
    [self setPendingChangeForKeypath:&tSeparator
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set separator height percentage to %f for scale %@", sender.doubleValue, scaleKey]];
    
    [self.scaleValMgr setValue:@(sender.doubleValue) forRegisteredObject:self.heightSlider];
    [self.scaleValMgr setValue:@(sender.doubleValue) forRegisteredObject:self.heightTextbox];
}

- (IBAction)adjustSeparatorOrigin:(NSTextField *)sender{
    self.originSlider.doubleValue = sender.doubleValue;
    self.originTextbox.doubleValue= sender.doubleValue;
    
    CGRect slCurrFrame = self.separatorLayer.frame;
    slCurrFrame.origin.y = (self.backgroundLayer.frame.origin.y + self.backgroundLayer.frame.origin.y * sender.doubleValue);
    [self.separatorLayer setFrame:slCurrFrame];
    
    NSString * scaleKey = self.scaleSelector.selectedSegment + 1 == 1 ? @"1x" : @"2x";
    SOEncodedKeyPath tSeparator = {
        .rootKey = &kSODockSeparatorOriginMultiplier,
        .components = @[scaleKey]
    };
    
    [self setPendingChangeForKeypath:&tSeparator
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set separator origin percentage to %f for scale %@", sender.doubleValue, scaleKey]];
    
    [self.scaleValMgr setValue:@(sender.doubleValue) forRegisteredObject:self.originSlider];
    [self.scaleValMgr setValue:@(sender.doubleValue) forRegisteredObject:self.originTextbox];
}

- (IBAction)filePickerOpened:(NSButton *)sender{
    NSString * scale = self.scaleSelector.selectedSegment == 0 ? @"1x" : @"2x";
    SOEncodedKeyPath separatorKeypath = {
        .rootKey = &kSODockSeparatorAssets,
        .components = @[[NSString stringWithFormat:@"separator%@", scale]]
    };
    
    if (self.separatorLayer.contents){
        [self.scaleMgr setImage:nil forRegisteredObject:self.separatorLayer];
        sender.image = [NSImage imageWithSystemSymbolName:@"folder" accessibilityDescription:nil];
        
        [self setPendingResourceChangeForKeypath:&separatorKeypath
                                        resource:nil
                                            type:kSOChangeResourceTypeNSImage
                                        filename:[NSString stringWithFormat:@"separator%@.png", scale]
                                            note:[NSString stringWithFormat:@"Cleared custom separator for scale %@", scale]
                                    contentScale:self.scaleSelector.selectedSegment + 1];
        return;
    }
    
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    panel.allowedContentTypes = @[UTTypeImage];
    panel.allowsMultipleSelection = NO;
    [panel beginSheetModalForWindow:self.view.window
                  completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK)
            return;
        
        NSURL * fileURL = panel.URL;
        NSData * fileData = [NSData dataWithContentsOfURL:fileURL];
        if (!fileData)
            return;
        
        [self setPendingResourceChangeForKeypath:&separatorKeypath
                                        resource:fileData
                                            type:kSOChangeResourceTypeNSImage
                                        filename:[NSString stringWithFormat:@"separator%@.png", scale]
                                            note:[NSString stringWithFormat:@"Set custom separator for scale %@", scale]
                                    contentScale:self.scaleSelector.selectedSegment + 1];
        
        NSImage * img = [[NSImage alloc] initWithData:fileData];
        [self.scaleMgr setImage:img forRegisteredObject:self.separatorLayer];
        
        sender.image = [NSImage imageWithSystemSymbolName:@"xmark" accessibilityDescription:nil];
    }];
    
}

- (IBAction)scaleSelectionChanged:(NSSegmentedControl *)sender{
    if (!sender.enabled)
        return;
    
    NSString * scale = sender.indexOfSelectedItem == 0 ? @"1x" : @"2x";
    self.backgroundLayer.contentsScale = sender.indexOfSelectedItem + 1;
    SOEncodedKeyPath backgroundKeypath = {
        .rootKey = &kSODockBackgroundAssets,
        .components = @[@"bottom", [NSString stringWithFormat:@"dock%@", scale]]
    };
    
    self.backgroundLayer.contents = [self loadImageForEncodedKeypath:&backgroundKeypath];
    [self.scaleMgr scaleDidChangeTo:(int)sender.indexOfSelectedItem + 1];
    [self.scaleValMgr scaleDidChangeTo:(int)sender.indexOfSelectedItem + 1];
    
    if (self.separatorLayer.contents)
        self.fileSystemAccessor.image = [NSImage imageWithSystemSymbolName:@"xmark" accessibilityDescription:nil];
    else
        self.fileSystemAccessor.image = [NSImage imageWithSystemSymbolName:@"folder" accessibilityDescription:nil];
    
    self.separatorLayer.contentsScale = self.backgroundLayer.contentsScale;
    
    CGRect slCurrFrame = self.separatorLayer.frame;
    slCurrFrame.size.height = self.heightTextbox.doubleValue * 100;
    slCurrFrame.origin.y = (self.backgroundLayer.frame.origin.y + self.backgroundLayer.frame.origin.y * self.originTextbox.doubleValue);
    [self.separatorLayer setFrame:slCurrFrame];
}

- (IBAction)wireframeSet:(NSButton *)sender{
    if (sender.state == NSControlStateValueOn){
        self.backgroundLayer.borderColor = [NSColor redColor].CGColor;
        self.backgroundLayer.borderWidth = 1;
        self.separatorLayer.borderColor = [NSColor redColor].CGColor;
        self.separatorLayer.borderWidth = 1;
    } else {
        self.backgroundLayer.borderColor = [NSColor clearColor].CGColor;
        self.backgroundLayer.borderWidth = 0;
        self.separatorLayer.borderColor = [NSColor clearColor].CGColor;
        self.separatorLayer.borderWidth = 0;
    }
}

- (void)viewDidLayout{
    [super viewDidLayout];
    [self compositeInteriorOfImageView];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGRect frame = self.centralImageView.layer.bounds;
    CGRect bgFrame = CGRectMake(1,
                                frame.size.height / 2 - 50,
                                frame.size.width - 2,
                                100);
    [self.backgroundLayer setFrame:bgFrame];
    
    CGRect slFrame = CGRectMake(frame.size.width / 2 - 15,
                                bgFrame.origin.y + (self.originSlider.doubleValue * bgFrame.origin.y),
                                30,
                                self.heightSlider.doubleValue * 100);
    [self.separatorLayer setFrame:slFrame];
    [CATransaction commit];
}

@end
