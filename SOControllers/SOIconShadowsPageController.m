//Created by Salty on 2/22/26.

#import "SOIconShadowsPageController.h"

@implementation SOIconShadowsPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self.iconHostingView setWantsLayer:YES];
    self.iconHostingView.layer.contents = [NSImage imageNamed:@"AppIcon"];
    
    [self refreshOrLoadBaseline];
}

const SOEncodedKeyPath tWidth = {
    .rootKey = &kSODockTileShadowOffset,
    .components = @[@"width"]
};

const SOEncodedKeyPath tHeight = {
    .rootKey = &kSODockTileShadowOffset,
    .components = @[@"height"]
};

- (void)refreshOrLoadBaseline{
    float height = [[self getBaselineForEncodedKeypath:&tHeight] floatValue];
    float width = [[self getBaselineForEncodedKeypath:&tWidth] floatValue];
    float radius = [[self getBaselineForEncodedKey:&kSODockTileShadowBlurRadius] floatValue];
    float opacity = [[self getBaselineForEncodedKey:&kSODockTileShadowOpacity] floatValue];
    
    self.heightSlider.floatValue = height;
    self.heightTextbox.floatValue = height;
    self.widthSlider.floatValue = width;
    self.widthTextbox.floatValue = width;
    self.radiusSlider.floatValue = radius;
    self.radiusTextbox.floatValue = radius;
    self.opacitySlider.floatValue = opacity;
    self.opacityTextbox.floatValue = opacity;
    
    [self adjustShadowRepresentationWithIndex:0 value:height];
    [self adjustShadowRepresentationWithIndex:1 value:width];
    [self adjustShadowRepresentationWithIndex:2 value:radius];
    [self adjustShadowRepresentationWithIndex:3 value:opacity];
}

- (IBAction)heightChanged:(NSControl *)sender{
    CGFloat newHeight = sender.intValue;
    self.heightSlider.intValue = newHeight;
    self.heightTextbox.intValue = newHeight;
    
    [self adjustShadowRepresentationWithIndex:0 value:newHeight];
    
    [self setPendingChangeForKeypath:&tHeight
                               value:@(newHeight)
                                note:[NSString stringWithFormat:@"Set tile shadow height to %f", newHeight]];
}

- (IBAction)widthChanged:(NSControl *)sender{
    CGFloat newWidth = sender.intValue;
    self.widthSlider.intValue = newWidth;
    self.widthTextbox.intValue = newWidth;
    
    [self adjustShadowRepresentationWithIndex:1 value:newWidth];
    
    [self setPendingChangeForKeypath:&tWidth
                               value:@(newWidth)
                                note:[NSString stringWithFormat:@"Set tile shadow width to %f", newWidth]];
}

- (IBAction)radiusChanged:(NSControl *)sender{
    CGFloat newRadius = sender.intValue;
    self.radiusSlider.intValue = newRadius;
    self.radiusTextbox.intValue = newRadius;
    
    [self adjustShadowRepresentationWithIndex:2 value:newRadius];
    
    [self setPendingChangeForKey:&kSODockTileShadowBlurRadius
                           value:@(newRadius)
                            note:[NSString stringWithFormat:@"Set tile shadow blur radius to %f", newRadius]];
}

- (IBAction)opacityChanged:(NSControl *)sender{
    float newOpacity = sender.floatValue;
    self.opacitySlider.floatValue = newOpacity;
    self.opacityTextbox.floatValue = newOpacity;
    
    [self adjustShadowRepresentationWithIndex:3 value:newOpacity];
    
    [self setPendingChangeForKey:&kSODockTileShadowOpacity
                           value:@(newOpacity)
                            note:[NSString stringWithFormat:@"Set tile shadow opacity to %f", newOpacity]];
}

- (void)adjustShadowRepresentationWithIndex:(int)index value:(float)value{
    CALayer * sl = self.iconHostingView.layer;
    
    switch (index) {
        case 0:
            sl.shadowOffset = CGSizeMake(sl.shadowOffset.width, value);
            break;
        case 1:
            sl.shadowOffset = CGSizeMake(value, sl.shadowOffset.height);
            break;
        case 2:
            sl.shadowRadius = value;
            break;
        case 3:
            sl.shadowOpacity = value;
            break;
    }
}
@end
