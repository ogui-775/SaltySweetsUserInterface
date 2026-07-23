//Created by Salty on 7/17/26.

#import "SOClockDockTileReplacementPageController.h"

@interface SOClockDisplayLayer : CALayer
- (void)setFace:(id)contents hour:(id)contents mins:(id)contents;
@property (strong) CALayer *faceImageLayer;
@property (strong) CALayer *hourImageLayer;
@property (strong) CALayer *minsImageLayer;
@end

@interface SOClockDisplayView : NSView
@property (strong) NSString *trackedKey;
@property (strong) SOClockDisplayLayer *clockLayer;
@property (strong) SODragAwareImageView *imageView;
@end

const void *kSOAssociatedURL = &kSOAssociatedURL;

@implementation SOClockDockTileReplacementPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.previewView setWantsLayer:YES];
    [self.previewView.layer setBackgroundColor:NSColor.darkGrayColor.CGColor];
    
    self.previewView.clockLayer = [SOClockDisplayLayer layer];
    [self.previewView.layer addSublayer:self.previewView.clockLayer];
    
    CGRect bounds = [self.previewView layer].bounds;
    
    CGFloat x = CGRectGetMidX(bounds) - 150;
    CGFloat y = CGRectGetMidY(bounds) - 150;
    
    [self.previewView.clockLayer setFrame:CGRectMake(x, y, 300, 300)];
    
    [self.previewView.imageView setAction:@selector(imageWellWasInteractedWith:)];
    [self.previewView.imageView setTarget:self];
    
    [[SOAtomicAccessPoint sharedInstance] registerUndoManagerForClear:self.undoManager withController:self];
    
    [self refreshOrLoadBaseline];
    
    self.previewView.trackedKey = @"clock.face";
}

- (void)refreshOrLoadBaseline{
    const SOEncodedKeyPath faceKey = [self faceKeypath];
    const SOEncodedKeyPath minsKey = [self minsKeypath];
    const SOEncodedKeyPath hourKey = [self hourKeypath];
    
    NSImage *faceImage = [self loadImageForEncodedKeypath:&faceKey];
    NSImage *hourImage = [self loadImageForEncodedKeypath:&hourKey];

    NSImage *newHourImage = [NSImage imageWithSize:hourImage.size
                                           flipped:NO
                                    drawingHandler:^BOOL(NSRect dstRect)
    {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:NSMidX(dstRect) yBy:NSMidY(dstRect)];
        [transform rotateByDegrees:180.0];
        [transform translateXBy:-NSMidX(dstRect) yBy:-NSMidY(dstRect)];
        [transform concat];
        [hourImage drawInRect:dstRect];
        return YES;
    }];
    NSImage *minsImage = [self loadImageForEncodedKeypath:&minsKey];
    
    [self.previewView.clockLayer setFace:faceImage
                                    hour:newHourImage
                                    mins:minsImage];
    
    NSString *faceFile = [self getBaselineForEncodedKeypath:&faceKey];
    if (faceFile)
        faceFile = [[self.accessPoint currentIconPackBundle].resourcePath stringByAppendingPathComponent:faceFile];
    NSString *minsFile = [self getBaselineForEncodedKeypath:&minsKey];
    if (minsFile)
        minsFile = [[self.accessPoint currentIconPackBundle].resourcePath stringByAppendingPathComponent:minsFile];
    NSString *hourFile = [self getBaselineForEncodedKeypath:&hourKey];
    if (hourFile)
        hourFile = [[self.accessPoint currentIconPackBundle].resourcePath stringByAppendingPathComponent:hourFile];
    
    if (faceFile)
        objc_setAssociatedObject(self.previewView.clockLayer.faceImageLayer,
                                 &kSOAssociatedURL,
                                 [NSURL fileURLWithPath:faceFile],
                                 OBJC_ASSOCIATION_RETAIN);
    
    if (minsFile)
        objc_setAssociatedObject(self.previewView.clockLayer.minsImageLayer,
                                 &kSOAssociatedURL,
                                 [NSURL fileURLWithPath:minsFile],
                                 OBJC_ASSOCIATION_RETAIN);
    
    if (hourFile)
        objc_setAssociatedObject(self.previewView.clockLayer.hourImageLayer,
                                 &kSOAssociatedURL,
                                 [NSURL fileURLWithPath:hourFile],
                                 OBJC_ASSOCIATION_RETAIN);
}

- (IBAction)radioWasPressed:(NSButton *)sender{
    if ([[sender identifier] isEqualToString:@"f"])
        self.previewView.trackedKey = @"clock.face";
    else if ([[sender identifier] isEqualToString:@"m"])
        self.previewView.trackedKey = @"clock.minute";
    else
        self.previewView.trackedKey = @"clock.hour";
}

- (IBAction)imageWellWasInteractedWith:(SODragAwareImageView *)sender{
    if ([[sender.draggedFileURL pathExtension] isEqualToString:@"sicon"]){
        sender.image = [SOSiconBundle NSImageOrNilForURL:sender.draggedFileURL];
    }
    
    if (!sender.image)
        return;
    
    CALayer *currentLitLayer = [self layerForViewWithLight];
    NSImage *currentContents = currentLitLayer.contents;
    
    NSURL *litLayerURL = objc_getAssociatedObject(currentLitLayer,
                                                  &kSOAssociatedURL);
    
    [self.undoManager registerUndoWithTarget:self
                                     handler:^(SOClockDockTileReplacementPageController *s){
        [currentLitLayer setContents:currentContents];
        objc_setAssociatedObject(currentLitLayer,
                                 &kSOAssociatedURL,
                                 litLayerURL,
                                 OBJC_ASSOCIATION_RETAIN);
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
    }];
    [self.undoManager setActionName:@"Set Image"];
    
    [currentLitLayer setContents:sender.image];
    
    const SOEncodedKeyPath tLayer = {
        .rootKey = &kSOIconsDockTilePluginDict,
        .components = @[self.previewView.trackedKey]
    };
    
    [self setPendingIconResourceChangeForKeypath:&tLayer
                                        resource:[NSData dataWithContentsOfURL:sender.draggedFileURL]
                                        filename:[sender draggedFileURL].lastPathComponent
                                            note:[NSString stringWithFormat:@"Set %@ to %@",
                                                  self.previewView.trackedKey,
                                                  [sender draggedFileURL].lastPathComponent]];
    
    [self.previewView setNeedsDisplay:YES];
    [self.previewView.clockLayer setNeedsDisplay];
    
    objc_setAssociatedObject(currentLitLayer,
                             &kSOAssociatedURL,
                             [sender draggedFileURL],
                             OBJC_ASSOCIATION_RETAIN);
    
    sender.image = nil;
}

- (IBAction)clearButtonWasPressed:(NSButton *)sender{
    if (![self layerForViewWithLight].contents)
        return;
    
    CALayer *currentLayer = [self layerForViewWithLight];
    NSImage *currentImage = [currentLayer contents];
    NSURL *currentLayerURL = objc_getAssociatedObject(currentLayer,
                                                      &kSOAssociatedURL);
    
    [self.undoManager registerUndoWithTarget:self
                                     handler:^(SOClockDockTileReplacementPageController *c){
        [currentLayer setContents:currentImage];
        objc_setAssociatedObject(currentLayer,
                                 &kSOAssociatedURL,
                                 currentLayerURL,
                                 OBJC_ASSOCIATION_RETAIN);
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
    }];
    [self.undoManager setActionName:@"Cleared Image"];
    
    const SOEncodedKeyPath tLayer = {
        .rootKey = &kSOIconsDockTilePluginDict,
        .components = @[self.previewView.trackedKey]
    };
    
    if ([self getBaselineForEncodedKeypath:&tLayer])
        [self setPendingIconResourceChangeForKeypath:&tLayer
                                            resource:nil
                                            filename:nil
                                                note:[NSString stringWithFormat:@"Cleared image for %@",
                                                      self.previewView.trackedKey]];
    
    [[self layerForViewWithLight] setContents:nil];
    [self.previewView.clockLayer setNeedsDisplay];
    
    objc_setAssociatedObject(currentLayer,
                             &kSOAssociatedURL,
                             nil,
                             OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerForViewWithLight{
    NSString *k = self.previewView.trackedKey;
    
    if ([k isEqualToString:@"clock.face"])
        return self.previewView.clockLayer.faceImageLayer;
    else if ([k isEqualToString:@"clock.hour"])
        return self.previewView.clockLayer.hourImageLayer;
    else if ([k isEqualToString:@"clock.minute"])
        return self.previewView.clockLayer.minsImageLayer;
    else
        return nil;
}

- (const SOEncodedKeyPath)hourKeypath{
    const SOEncodedKeyPath hourKey = {
        .rootKey = &kSOIconsDockTilePluginDict,
        .components = @[@"clock.hour"]
    };
    
    return hourKey;
}

- (const SOEncodedKeyPath)minsKeypath{
    const SOEncodedKeyPath minuteKey = {
        .rootKey = &kSOIconsDockTilePluginDict,
        .components = @[@"clock.minute"]
    };
    
    return minuteKey;
}

- (const SOEncodedKeyPath)faceKeypath{
    const SOEncodedKeyPath faceKey = {
        .rootKey = &kSOIconsDockTilePluginDict,
        .components = @[@"clock.face"]
    };
    
    return faceKey;
}

#pragma mark - Image Editing

- (IBAction)widthDidChange:(NSButton *)sender{
    BOOL narrower = [sender.identifier isEqualToString:@"w-"];
    CALayer *cLayer = [self layerForViewWithLight];
    NSImage *cImage = [cLayer contents];
    
    if (!narrower){
        NSImage *new = [NSImage imageWithSize:cImage.size
                                      flipped:NO
                               drawingHandler:^BOOL(NSRect dstRect) {
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
            [cImage drawInRect:CGRectMake(0, 0, dstRect.size.width + 1, dstRect.size.height)];
            return YES;
        }];
        [cLayer setContents:new];
        return;
    }
    NSImage *new = [NSImage imageWithSize:cImage.size
                                  flipped:NO
                           drawingHandler:^BOOL(NSRect dstRect) {
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
        [cImage drawInRect:CGRectMake(0, 0, dstRect.size.width - 1, dstRect.size.height)];
        return YES;
    }];
    [cLayer setContents:new];
}

- (IBAction)heightDidChange:(NSButton *)sender{
    BOOL shorter = [sender.identifier isEqualToString:@"h-"];
    CALayer *cLayer = [self layerForViewWithLight];
    NSImage *cImage = [cLayer contents];
    
    if (!shorter){
        NSImage *new = [NSImage imageWithSize:cImage.size
                                      flipped:NO
                               drawingHandler:^BOOL(NSRect dstRect) {
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
            [cImage drawInRect:CGRectMake(0, 0, dstRect.size.width, dstRect.size.height + 1)];
            return YES;
        }];
        [cLayer setContents:new];
        return;
    }
    NSImage *new = [NSImage imageWithSize:cImage.size
                                  flipped:NO
                           drawingHandler:^BOOL(NSRect dstRect) {
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
        [cImage drawInRect:CGRectMake(0, 0, dstRect.size.width, dstRect.size.height - 1)];
        return YES;
    }];
    [cLayer setContents:new];
}

- (IBAction)positionDidChange:(NSButton *)sender{
    NSString *identifier = [sender identifier];
    CALayer *cLayer = [self layerForViewWithLight];
    NSImage *cImage = [cLayer contents];
    
    if ([identifier isEqualToString:@"w"]){
        NSImage *new = [NSImage imageWithSize:cImage.size
                                      flipped:NO
                               drawingHandler:^BOOL(NSRect dstRect) {
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
            [cImage drawInRect:CGRectMake(0, 1, dstRect.size.width, dstRect.size.height)];
            return YES;
        }];
        [cLayer setContents:new];
    } else if ([identifier isEqualToString:@"a"]){
        NSImage *new = [NSImage imageWithSize:cImage.size
                                      flipped:NO
                               drawingHandler:^BOOL(NSRect dstRect) {
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
            [cImage drawInRect:CGRectMake(-1, 0, dstRect.size.width, dstRect.size.height)];
            return YES;
        }];
        [cLayer setContents:new];
    } else if ([identifier isEqualToString:@"s"]){
        NSImage *new = [NSImage imageWithSize:cImage.size
                                      flipped:NO
                               drawingHandler:^BOOL(NSRect dstRect) {
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
            [cImage drawInRect:CGRectMake(0, -1, dstRect.size.width, dstRect.size.height)];
            return YES;
        }];
        [cLayer setContents:new];
    } else if ([identifier isEqualToString:@"d"]){
        NSImage *new = [NSImage imageWithSize:cImage.size
                                      flipped:NO
                               drawingHandler:^BOOL(NSRect dstRect) {
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
            [cImage drawInRect:CGRectMake(1, 0, dstRect.size.width, dstRect.size.height)];
            return YES;
        }];
        [cLayer setContents:new];
    }
}

- (IBAction)saveGraphicsState:(NSButton *)sender{
    NSURL *faceURL = objc_getAssociatedObject(self.previewView.clockLayer.faceImageLayer,
                                              &kSOAssociatedURL);
    NSURL *minsURL = objc_getAssociatedObject(self.previewView.clockLayer.minsImageLayer,
                                              &kSOAssociatedURL);
    NSURL *hourURL = objc_getAssociatedObject(self.previewView.clockLayer.hourImageLayer,
                                              &kSOAssociatedURL);
    
    NSImage *faceImage = self.previewView.clockLayer.faceImageLayer.contents;
    NSImage *minsImage = self.previewView.clockLayer.minsImageLayer.contents;
    NSImage *hourImage = self.previewView.clockLayer.hourImageLayer.contents;
    
    const SOEncodedKeyPath faceKey = [self faceKeypath];
    
    [self setPendingIconResourceChangeForKeypath:&faceKey
                                        resource:faceImage
                                        filename:[[[[faceURL lastPathComponent] stringByDeletingPathExtension]
                                                   stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned                    long)faceURL.hash]]stringByAppendingPathExtension:@"png"]
                                            note:@"Set clock.face as modified PNG"];
    
    const SOEncodedKeyPath minsKey = [self minsKeypath];
    
    [self setPendingIconResourceChangeForKeypath:&minsKey
                                        resource:minsImage
                                        filename:[[[[minsURL lastPathComponent] stringByDeletingPathExtension]
                                                   stringByAppendingString:[NSString stringWithFormat:@"%lu",
                                                                            (unsigned long)minsURL.hash]]stringByAppendingPathExtension:@"png"]
                                            note:@"Set clock.minute as modified PNG"];

    const SOEncodedKeyPath hourKey = [self hourKeypath];
    
    [self setPendingIconResourceChangeForKeypath:&hourKey
                                        resource:hourImage
                                        filename:[[[[hourURL lastPathComponent] stringByDeletingPathExtension]
                                                   stringByAppendingString:[NSString stringWithFormat:@"%lu",
                                                                            (unsigned long)hourURL.hash]]stringByAppendingPathExtension:@"png"]
                                            note:@"Set clock.hour as modified PNG"];
}

- (IBAction)centerPointIsDesired:(NSButton *)sender{
    BOOL requested = [sender state] == NSControlStateValueOn;
    
    if (!requested){
        NSArray<CALayer *> * subs = self.previewView.clockLayer.minsImageLayer.sublayers;
        for (CALayer *s in subs){
            if ([s.name isEqualToString:@"centerPoint"])
                [s setHidden:YES];
        }
    } else {
        BOOL wasFound = NO;
        NSArray<CALayer *> * subs = self.previewView.clockLayer.minsImageLayer.sublayers;
        for (CALayer *s in subs){
            if ([s.name isEqualToString:@"centerPoint"]){
                [s setHidden:NO];
                wasFound = YES;
            }
        }
        
        if (!wasFound){
            CALayer *c = [CALayer layer];
            [c setName:@"centerPoint"];
            [c setBackgroundColor:NSColor.redColor.CGColor];
            
            CGRect bounds = self.previewView.clockLayer.bounds;
            CGFloat x = CGRectGetMidX(bounds);
            CGFloat y = CGRectGetMidY(bounds);
            CGRect centerRect = CGRectMake(x, y, 0, 0);
            [c setFrame:centerRect];
            [c setBounds:CGRectMake(0, 0, 5, 5)];
            [self.previewView.clockLayer.minsImageLayer addSublayer:c];
        }
    }
}
@end

@implementation SOClockDisplayLayer
+ (instancetype)layer{
    SOClockDisplayLayer *layer = [super layer];
    layer.faceImageLayer = [CALayer layer];
    layer.hourImageLayer = [CALayer layer];
    layer.minsImageLayer = [CALayer layer];
    
    [layer addSublayer:layer.faceImageLayer];
    [layer insertSublayer:layer.hourImageLayer above:layer.faceImageLayer];
    [layer insertSublayer:layer.minsImageLayer above:layer.hourImageLayer];
    
    return layer;
}

- (void)setFace:(id)face
           hour:(id)hour
           mins:(id)mins{
    [self.faceImageLayer setContents:face];
    [self.hourImageLayer setContents:hour];
    [self.minsImageLayer setContents:mins];
}

- (void)layoutSublayers{
    [super layoutSublayers];
    
    CGRect bounds = [self superlayer].bounds;
    
    CGFloat x = CGRectGetMidX(bounds) - 150;
    CGFloat y = CGRectGetMidY(bounds) - 150;
    
    [self setFrame:CGRectMake(x, y, 300, 300)];
}

- (void)setFrame:(CGRect)frame{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [super setFrame:frame];

    for (CALayer *sub in self.sublayers){
        [sub setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }

    [CATransaction commit];
}
@end

@implementation SOClockDisplayView
- (void)awakeFromNib{
    [super awakeFromNib];
    self.imageView = [[SODragAwareImageView alloc] initWithFrame:self.frame];
    
    [self addSubview:self.imageView];
}

- (void)layout{
    [super layout];
    
    [self.clockLayer setNeedsLayout];
}
@end
