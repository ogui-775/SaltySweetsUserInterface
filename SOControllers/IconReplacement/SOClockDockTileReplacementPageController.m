//Created by Salty on 7/17/26.

#import "SOClockDockTileReplacementPageController.h"

@interface SOClockDisplayLayer : CALayer
- (void)setFace:(id)contents hour:(id)contents mins:(id)contents;
@property (strong) CALayer *faceImageLayer;
@property (strong) CALayer *hourImageLayer;
@property (strong) CALayer *minsImageLayer;
@end

@interface SOClockDisplayView : NSView
@property (weak) SODragAwareImageView *viewHasTheLight;
@property (strong) SOClockDisplayLayer *clockLayer;
@property (strong) SODragAwareImageView *faceSettingImageView;
@property (strong) SODragAwareImageView *hourSettingImageView;
@property (strong) SODragAwareImageView *minsSettingImageView;
@end

@interface SOClockDockTileReplacementPageController ()
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
    
    self.previewView.viewHasTheLight = self.previewView.faceSettingImageView;
    
    [self.previewView.faceSettingImageView setAction:@selector(imageWellWasInteractedWith:)];
    [self.previewView.hourSettingImageView setAction:@selector(imageWellWasInteractedWith:)];
    [self.previewView.minsSettingImageView setAction:@selector(imageWellWasInteractedWith:)];
    [self.previewView.faceSettingImageView setTarget:self];
    [self.previewView.hourSettingImageView setTarget:self];
    [self.previewView.minsSettingImageView setTarget:self];
    
    [[SOAtomicAccessPoint sharedInstance] registerUndoManagerForClear:self.undoManager withController:self];
    
    [self refreshOrLoadBaseline];
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
}

- (IBAction)radioWasPressed:(NSButton *)sender{
    if ([[sender identifier] isEqualToString:@"f"])
        self.previewView.viewHasTheLight = self.previewView.faceSettingImageView;
    else if ([[sender identifier] isEqualToString:@"m"])
        self.previewView.viewHasTheLight = self.previewView.minsSettingImageView;
    else
        self.previewView.viewHasTheLight = self.previewView.hourSettingImageView;
    
    for (SODragAwareImageView *v in @[self.previewView.faceSettingImageView, self.previewView.hourSettingImageView, self.previewView.minsSettingImageView]){
        [v setEnabled:NO];
        [v setEditable:NO];
    }
    
    self.previewView.viewHasTheLight.enabled = YES;
    self.previewView.viewHasTheLight.editable = YES;
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
    }];
    [self.undoManager setActionName:@"Set Image"];
    
    [currentLitLayer setContents:sender.image];
    
    [self.previewView setNeedsDisplay:YES];
    [self.previewView.clockLayer setNeedsDisplay];
    
    sender.image = nil;
}

- (CALayer *)layerForViewWithLight{
    SODragAwareImageView *v = [self.previewView viewHasTheLight];
    
    if ([[v identifier] isEqualToString:@"face"])
        return self.previewView.clockLayer.faceImageLayer;
    else if ([[v identifier] isEqualToString:@"hour"])
        return self.previewView.clockLayer.hourImageLayer;
    else if ([[v identifier] isEqualToString:@"mins"])
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
    self.faceSettingImageView = [[SODragAwareImageView alloc] initWithFrame:self.frame];
    self.faceSettingImageView.identifier = @"face";
    self.hourSettingImageView = [[SODragAwareImageView alloc] initWithFrame:self.frame];
    self.hourSettingImageView.identifier = @"hour";
    self.minsSettingImageView = [[SODragAwareImageView alloc] initWithFrame:self.frame];
    self.minsSettingImageView.identifier = @"mins";
    
    [self addSubview:self.faceSettingImageView];
    [self addSubview:self.hourSettingImageView];
    [self addSubview:self.minsSettingImageView];
    
    self.faceSettingImageView.editable = YES;
    self.hourSettingImageView.editable = NO;
    self.minsSettingImageView.editable = NO;
    
    self.faceSettingImageView.enabled = YES;
    self.hourSettingImageView.enabled = NO;
    self.minsSettingImageView.enabled = NO;
}

- (void)layout{
    [super layout];
    
    [self.clockLayer setNeedsLayout];
}
@end
