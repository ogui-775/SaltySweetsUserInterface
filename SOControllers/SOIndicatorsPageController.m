//Created by Salty on 2/23/26.

#import "SOIndicatorsPageController.h"

@implementation SOIndicatorsPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    self.scale2xImageWell.enabled = [[self getBaselineForEncodedKey:&kSODockUsesRetinaResourcesWhereRequested] boolValue];

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
@end
