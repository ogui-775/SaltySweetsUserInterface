//Created by Salty on 7/17/26.

#import "SOClockDockTileReplacementPageController.h"

@interface SOClockDisplayLayer : CALayer
- (void)setFace:(id)face hour:(id)hour mins:(id)mins;
@property (strong) CALayer *faceImageLayer;
@property (strong) CALayer *hourImageLayer;
@property (strong) CALayer *minsImageLayer;
@end

@interface SOClockDisplayView : NSView
- (void)finishInit;
@property (strong) NSString *trackedKey;
@property (strong) SOClockDisplayLayer *clockLayer;
@property (strong) SODragAwareImageView *imageView;
@end

const void *kSOAssociatedURL = &kSOAssociatedURL;

@implementation SOClockDockTileReplacementPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.previewView finishInit];
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

#pragma mark - Helpers
- (NSImage *)imageRotated180:(NSImage *)image{
    if (!image)
        return nil;
    
    NSImage *source = image;
    
    return [NSImage imageWithSize:source.size
                          flipped:NO
                   drawingHandler:^BOOL(NSRect dstRect)
    {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:NSMidX(dstRect) yBy:NSMidY(dstRect)];
        [transform rotateByDegrees:180.0];
        [transform translateXBy:-NSMidX(dstRect) yBy:-NSMidY(dstRect)];
        [transform concat];
        [source drawInRect:dstRect];
        return YES;
    }];
}

- (NSString *)resolvedBaselineFileForKeypath:(const SOEncodedKeyPath *)keyPath{
    NSString *file = [self getBaselineForEncodedKeypath:keyPath];
    if (file)
        file = [[self.accessPoint currentIconPackBundle].resourcePath stringByAppendingPathComponent:file];
    return file;
}

#pragma mark - Loading

- (void)refreshOrLoadBaseline{
    const SOEncodedKeyPath faceKey = [self faceKeypath];
    const SOEncodedKeyPath minsKey = [self minsKeypath];
    const SOEncodedKeyPath hourKey = [self hourKeypath];
    
    NSImage *faceImage = [self loadImageForEncodedKeypath:&faceKey];
    NSImage *hourImage = [self loadImageForEncodedKeypath:&hourKey];
    NSImage *minsImage = [self loadImageForEncodedKeypath:&minsKey];
    
    NSImage *newHourImage = [self imageRotated180:hourImage];
    
    [self.previewView.clockLayer setFace:faceImage
                                    hour:newHourImage
                                    mins:minsImage];
    
    NSString *faceFile = [self resolvedBaselineFileForKeypath:&faceKey];
    NSString *minsFile = [self resolvedBaselineFileForKeypath:&minsKey];
    NSString *hourFile = [self resolvedBaselineFileForKeypath:&hourKey];
    
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

#pragma mark - Actions

- (IBAction)radioWasPressed:(NSButton *)sender{
    if ([[sender identifier] isEqualToString:@"f"])
        self.previewView.trackedKey = @"clock.face";
    else if ([[sender identifier] isEqualToString:@"m"])
        self.previewView.trackedKey = @"clock.minute";
    else
        self.previewView.trackedKey = @"clock.hour";
}

- (IBAction)imageWellWasInteractedWith:(SODragAwareImageView *)sender{
    NSURL *droppedURL = sender.draggedFileURL;
    NSImage *droppedImage = sender.image;
    
    if ([[droppedURL pathExtension] isEqualToString:@"sicon"])
        droppedImage = [SOSicon NSImageOrNilForURL:droppedURL];
    
    if (!droppedImage)
        return;
    
    CALayer *currentLitLayer = [self layerForViewWithLight];
    if (!currentLitLayer)
        return;
    
    NSImage *currentContents = currentLitLayer.contents;
    NSURL *previousURL = objc_getAssociatedObject(currentLitLayer,
                                                  &kSOAssociatedURL);
    
    NSImage *imageToApply = droppedImage;
    if (currentLitLayer == self.previewView.clockLayer.hourImageLayer)
        imageToApply = [self imageRotated180:droppedImage];
    
    [self.undoManager registerUndoWithTarget:self
                                     handler:^(SOClockDockTileReplacementPageController *s){
        [currentLitLayer setContents:currentContents];
        objc_setAssociatedObject(currentLitLayer,
                                 &kSOAssociatedURL,
                                 previousURL,
                                 OBJC_ASSOCIATION_RETAIN);
        [s.pendingChangeArray removeLastObject];
        [s.changeDelegate contentDidChangeState:s];
    }];
    [self.undoManager setActionName:@"Set Image"];
    
    [currentLitLayer setContents:imageToApply];
    
    const SOEncodedKeyPath tLayer = {
        .rootKey = &kSOIconsDockTilePluginDict,
        .components = @[self.previewView.trackedKey]
    };
    
    [self setPendingIconResourceChangeForKeypath:&tLayer
                                        resource:[NSData dataWithContentsOfURL:droppedURL]
                                        filename:droppedURL.lastPathComponent
                                            note:[NSString stringWithFormat:@"Set %@ to %@",
                                                  self.previewView.trackedKey,
                                                  droppedURL.lastPathComponent]];
    
    objc_setAssociatedObject(currentLitLayer,
                             &kSOAssociatedURL,
                             droppedURL,
                             OBJC_ASSOCIATION_RETAIN);
    
    sender.image = nil;
}

- (IBAction)clearButtonWasPressed:(NSButton *)sender{
    CALayer *currentLayer = [self layerForViewWithLight];
    if (!currentLayer || !currentLayer.contents)
        return;
    
    id currentContents = currentLayer.contents;
    NSURL *currentLayerURL = objc_getAssociatedObject(currentLayer,
                                                      &kSOAssociatedURL);
    
    [self.undoManager registerUndoWithTarget:self
                                     handler:^(SOClockDockTileReplacementPageController *c){
        [currentLayer setContents:currentContents];
        objc_setAssociatedObject(currentLayer,
                                 &kSOAssociatedURL,
                                 currentLayerURL,
                                 OBJC_ASSOCIATION_RETAIN);
        [c.pendingChangeArray removeLastObject];
        [c.changeDelegate contentDidChangeState:c];
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
    
    [currentLayer setContents:nil];
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

#pragma mark - Keypaths

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

#pragma mark - Center point

- (IBAction)centerPointIsDesired:(NSButton *)sender{
    BOOL requested = [sender state] == NSControlStateValueOn;
    BOOL wasFound = NO;
    
    for (CALayer *s in self.previewView.clockLayer.minsImageLayer.sublayers){
        if ([s.name isEqualToString:@"centerPoint"]){
            [s setHidden:!requested];
            wasFound = YES;
        }
    }
    
    if (requested && !wasFound){
        CALayer *c = [CALayer layer];
        [c setName:@"centerPoint"];
        [c setBackgroundColor:NSColor.redColor.CGColor];
        
        CGRect bounds = self.previewView.clockLayer.bounds;
        CGFloat x = CGRectGetMidX(bounds);
        CGFloat y = CGRectGetMidY(bounds);
        [c setFrame:CGRectMake(x, y, 0, 0)];
        [c setBounds:CGRectMake(0, 0, 5, 5)];
        [self.previewView.clockLayer.minsImageLayer addSublayer:c];
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
- (void)finishInit{
    self.imageView = [[SODragAwareImageView alloc] initWithFrame:self.bounds];
    
    [self addSubview:self.imageView
          positioned:NSWindowAbove
          relativeTo:self];
}

- (void)layout{
    [super layout];
    
    [self.clockLayer setNeedsLayout];
}
@end
