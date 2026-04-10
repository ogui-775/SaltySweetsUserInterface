//Created by Salty on 2/22/26.

#import "SOIconHeightPageController.h"

@implementation SOIconHeightPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    CGFloat heightMultipler = [[self getBaselineForEncodedKey:&kSODockTileOriginYMultiplier] floatValue];
    self.heightSlider.floatValue = heightMultipler;
    self.heightTextField.floatValue = heightMultipler;
    [(NSNumberFormatter *)self.heightTextField.formatter setNumberStyle:NSNumberFormatterPercentStyle];
}

- (IBAction)heightModifierPercentageChanged:(NSControl *)sender{
    if (sender.floatValue < -2)
        sender.floatValue = -21;
    
    if (sender.floatValue > 2)
        sender.floatValue = 2;
    
    float newSetModifier = sender.floatValue;
    self.heightSlider.floatValue = newSetModifier;
    self.heightTextField.floatValue = newSetModifier;
    
    [self setPendingChangeForKey:&kSODockTileOriginYMultiplier
                           value:@(sender.floatValue)
                            note:[NSString stringWithFormat:@"Set dock tile origin Y multiplier to %f", sender.floatValue]];
}

@end
