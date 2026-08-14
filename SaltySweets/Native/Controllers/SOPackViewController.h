//Created by Salty on 8/12/26.

#import <Cocoa/Cocoa.h>
#import <SharedBundles/SharedBundles.h>

#import "SOPackViewItem.h"
#import "../../Services/SOAtomicAccessPoint.h"

@interface SOPackViewController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource>
- (instancetype)initWithParentWindowController:(NSWindowController *)wc;
- (IBAction)showDrawer:(id)sender;
@end
