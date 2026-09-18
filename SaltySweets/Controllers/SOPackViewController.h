//Created by Salty on 8/12/26.

#import <Cocoa/Cocoa.h>
#import <SharedBundles/SharedBundles.h>
#import <CoreImage/CIFilterBuiltins.h>

@interface SOPackViewController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource, NSToolbarItemValidation, NSDraggingDestination>
- (instancetype)initWithParentWindowController:(NSWindowController *)wc;
- (IBAction)showDrawer:(id)sender;
- (void)updateContents;
@end
