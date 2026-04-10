//Created by Salty on 2/16/26.

#import "SORetinaDisplayPageController.h"

@implementation SORetinaDisplayPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    self.retinaDisplaySupportToggle.state =
        [[self getBaselineForEncodedKey:&kSODockUsesRetinaResourcesWhereRequested] boolValue] ?
            NSControlStateValueOn : NSControlStateValueOff;
}

- (IBAction)toggleRetinaDisplayAssetSupport:(NSButton *)sender{
    [self setPendingBoolChangeForKey:&kSODockUsesRetinaResourcesWhereRequested
                             enabled:sender.state == NSControlStateValueOn ? YES : NO
                                note:[NSString stringWithFormat:@"Set Retina Display asset support to %ld", (long)sender.state]];
}

@end
