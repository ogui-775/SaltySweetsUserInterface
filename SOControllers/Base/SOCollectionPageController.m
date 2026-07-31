//Created by Salty on 7/24/26.

#import "SOCollectionPageController.h"

@implementation SOCollectionPageController
- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    self.authorNameLabel.stringValue = @"test";
}

- (IBAction)infoWasPressed:(NSButton *)sender{
    NSLog(@"Info");
}
@end
