//Created by Salty on 8/12/26.

#import <Cocoa/Cocoa.h>
#import <SharedBundles/SharedBundles.h>
#import <CoreImage/CIFilterBuiltins.h>

#import "SOPackViewItem.h"
#import "../../Services/SOAtomicAccessPoint.h"
#import "SOTagSourceController.h"

@interface SOPackViewController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource, NSToolbarItemValidation>
- (instancetype)initWithParentWindowController:(NSWindowController *)wc;
- (IBAction)showDrawer:(id)sender;
- (void)updateContents;
@end
