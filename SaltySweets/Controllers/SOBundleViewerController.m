//Created by Salty on 9/18/26.

#import "SOBundleViewerController.h"
#import "SOBundleViewerViewController.h"

@implementation SOBundleViewerController
- (instancetype)init{
    self = [super initWithWindowNibName:@"BundleViewerWindow"];
    if (self){
        self.contentViewController = [[SOBundleViewerViewController alloc] initWithNibName:@"SOBundleViewerView"
                                                                                    bundle:nil];
        SOBundleViewerViewController *vc = (SOBundleViewerViewController *)self.contentViewController;
        vc.backButton = self.window.toolbar.items[0];
        vc.backButton.autovalidates = NO;
        vc.backButton.enabled = NO;
    }
    return self;
}

- (IBAction)viewGoBack:(id)sender{
    SOBundleViewerViewController *vc = (SOBundleViewerViewController *)self.contentViewController;
    
    [vc goBack:sender];
}
@end
