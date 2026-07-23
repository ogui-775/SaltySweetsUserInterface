//Created by Salty on 7/17/26.

#import "SOClockDockTileReplacementPageController.h"

@interface SOClockDisplayLayer : CALayer
- (void)setFace:(id)contents hour:(id)contents mins:(id)contents;
@property (strong) CALayer *faceImageLayer;
@property (strong) CALayer *hourImageLayer;
@property (strong) CALayer *minsImageLayer;

@property (strong) NSURL *faceImageURL;
@property (strong) NSURL *hourImageURL;
@property (strong) NSURL *minsImageURL;
@end

@interface SOClockDisplayView : NSView
@property (strong) NSString *trackedKey;
@property (strong) SOClockDisplayLayer *clockLayer;
@property (strong) SODragAwareImageView *imageView;
@end

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
        self.previewView.clockLayer.faceImageURL = [NSURL fileURLWithPath:faceFile];
    
    if (minsFile)
        self.previewView.clockLayer.minsImageURL = [NSURL fileURLWithPath:minsFile];
    
    if (hourFile)
        self.previewView.clockLayer.hourImageURL = [NSURL fileURLWithPath:hourFile];
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
    
    [self.undoManager registerUndoWithTarget:self
                                     handler:^(SOClockDockTileReplacementPageController *s){
        [currentLitLayer setContents:currentContents];
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
    
    sender.image = nil;
}

- (IBAction)clearButtonWasPressed:(NSButton *)sender{
    if (![self layerForViewWithLight].contents)
        return;
    
    CALayer *currentLayer = [self layerForViewWithLight];
    NSImage *currentImage = [currentLayer contents];
    
    [self.undoManager registerUndoWithTarget:self
                                     handler:^(SOClockDockTileReplacementPageController *c){
        [currentLayer setContents:currentImage];
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
    
}

- (IBAction)centerPointIsDesired:(NSButton *)sender{
    BOOL requested = [sender state] == NSControlStateValueOn;
    
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
