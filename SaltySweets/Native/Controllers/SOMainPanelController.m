//Created by Salty on 8/2/26.

#import "SOMainPanelController.h"

@implementation SOMainPanelController
- (void)awakeFromNib{
    [super awakeFromNib];

    NSVisualEffectView *backgroundView = [[NSVisualEffectView alloc] initWithFrame:self.view.bounds];
    backgroundView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    backgroundView.material = NSVisualEffectMaterialWindowBackground;
    backgroundView.state = NSVisualEffectStateActive;

    [self.view addSubview:backgroundView positioned:NSWindowBelow relativeTo:nil];
}
@end
