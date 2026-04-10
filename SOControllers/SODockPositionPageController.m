//Created by Salty on 2/7/26.

#import "SODockPositionPageController.h"

@implementation SODockPositionPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    CGFloat widthBaseline       = [[self getBaselineForEncodedKey:&kSODockWidthExtension] doubleValue];
    self.widthInputBox.doubleValue = widthBaseline;
    self.widthSlider.doubleValue   = widthBaseline;
    
    CGFloat originBaseline      = [[self getBaselineForEncodedKey:&kSODockBackgroundOriginY] doubleValue];
    self.originInputBox.doubleValue = originBaseline;
    self.originSlider.doubleValue   = originBaseline;
}

- (IBAction)setExtensionAmount:(NSTextField *)sender{
    self.widthInputBox.doubleValue = sender.doubleValue;
    self.widthSlider.doubleValue   = sender.doubleValue;
    
    [self setPendingChangeForKey:&kSODockWidthExtension
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set width extension amount to %f", sender.doubleValue]];
}

- (IBAction)setOriginModifier:(NSTextField *)sender{
    self.originSlider.doubleValue   = sender.doubleValue;
    self.originInputBox.doubleValue = sender.doubleValue;
    
    [self setPendingChangeForKey:&kSODockBackgroundOriginY
                           value:@(sender.doubleValue)
                            note:[NSString stringWithFormat:@"Set origin modifier amount to %f", sender.doubleValue]];
}
@end
