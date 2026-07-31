//Created by Salty on 2/23/26.

#import "SOIndicatorsPageController.h"

@implementation SOIndicatorsPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self refreshOrLoadBaseline];
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

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox{
    return [[self resizeArray] count];
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index{
    return [self resizeArray][index];
}

- (void)refreshOrLoadBaseline{
    SOEncodedKeyPath t1x = {
        .rootKey = &kSODockIndicatorAssets,
        .components = @[@"indicator1x"]
    };
    [self.scale1xImageWell setImage:[self loadImageForEncodedKeypath:&t1x]];
    
    if (!self.scale2xImageWell.enabled)
        return;
    
    SOEncodedKeyPath t2x = {
        .rootKey = &kSODockIndicatorAssets,
        .components = @[@"indicator2x"]
    };
    [self.scale2xImageWell setImage:[self loadImageForEncodedKeypath:&t2x]];
    
    const SOEncodedKeyPath t1xGrav = {
        .rootKey = &kSODockIndicatorContentsGravity,
        .components = @[@"1x"]
    };
    
    const SOEncodedKeyPath t2xGrav = {
        .rootKey = &kSODockIndicatorContentsGravity,
        .components = @[@"2x"]
    };
    
    self.scale1xGravityComboBox.stringValue = [self getBaselineForEncodedKeypath:&t1xGrav];
    self.scale2xGravityComboBox.stringValue = [self getBaselineForEncodedKeypath:&t2xGrav];
    
    double width = [[self getBaselineForEncodedKey:&kSODockIndicatorWidthMultiplier] doubleValue];
    double height = [[self getBaselineForEncodedKey:&kSODockIndicatorHeightMultiplier] doubleValue];
    
    self.widthMultiplierStepper.doubleValue = width;
    self.heightMultiplierStepper.doubleValue = height;
    
    self.heightLabel.stringValue = [[NSNumber numberWithDouble:height] stringValue];
    self.widthLabel.stringValue = [[NSNumber numberWithDouble:width] stringValue];
}

- (IBAction)imageDidChange:(NSImageView *)sender{
    NSString * scale = [sender.identifier isEqualToString:@"1"] ? @"indicator1x" : @"indicator2x";
    SOEncodedKeyPath tKey = {
        .rootKey = &kSODockIndicatorAssets,
        .components = @[scale]
    };
    
    [self setPendingResourceChangeForKeypath:&tKey
                                    resource:sender.image
                                        type:kSOChangeResourceTypeNSImage
                                    filename:[NSString stringWithFormat:@"%@.png", scale]
                                        note:[NSString stringWithFormat:@"Set indicator asset for scale %@", scale]
                                contentScale:[scale isEqualToString:@"indicator1x"] ? 1 : 2];
}

- (IBAction)contentsGravityDidChange:(NSComboBox *)sender{
    BOOL is2x = [[sender identifier] isEqualToString:@"c2x"];
    
    if (!is2x){
        const SOEncodedKeyPath t1xGrav = {
            .rootKey = &kSODockIndicatorContentsGravity,
            .components = @[@"1x"]
        };
        
        [self setPendingChangeForKeypath:&t1xGrav
                                   value:sender.stringValue
                                    note:[NSString stringWithFormat:@"Set gravity for 1x indicator to %@",
                                          sender.stringValue]];
    } else {
        const SOEncodedKeyPath t2xGrav = {
            .rootKey = &kSODockIndicatorContentsGravity,
            .components = @[@"2x"]
        };
        
        [self setPendingChangeForKeypath:&t2xGrav
                                   value:sender.stringValue
                                    note:[NSString stringWithFormat:@"Set gravity for 2x indicator to %@",
                                          sender.stringValue]];
    }
}

- (IBAction)widthDidStep:(NSStepper *)sender{
    sender.doubleValue = ROUND_DP(sender.doubleValue, 2);
    NSNumber *new = [NSNumber numberWithDouble:sender.doubleValue];
    self.widthLabel.stringValue = [new stringValue];
    [self setPendingChangeForKey:&kSODockIndicatorWidthMultiplier
                           value:new
                            note:[NSString stringWithFormat:@"Set indicator width multiplier to %@", new]];
}

- (IBAction)heightDidStep:(NSStepper *)sender{
    sender.doubleValue = ROUND_DP(sender.doubleValue, 2);
    NSNumber *new = [NSNumber numberWithDouble:sender.doubleValue];
    self.heightLabel.stringValue = [new stringValue];
    [self setPendingChangeForKey:&kSODockIndicatorHeightMultiplier
                           value:new
                            note:[NSString stringWithFormat:@"Set indicator height multiplier to %@", new]];
}

- (void)mouseDown:(NSEvent *)event{
    [self.view.window makeFirstResponder:nil];
}
@end
