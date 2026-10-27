//Created by Salty on 9/18/26.

#import "SOTagPopoverController.h"
#import "SOPackViewItem.h"

@interface SOTagPopoverController ()
@property (weak) SOPackViewItem *parentItem;
@end

@implementation SOTagPopoverController
- (instancetype)initWithSourceItem:(SOPackViewItem *)item{
    self = [super initWithNibName:@"SOTagPopoverView"
                           bundle:nil];
    if (self){
        self.parentItem = item;
        self.name = item.name;
    }
    return self;
}

- (IBAction)closePopover:(id)sender{
    [self.view.window close];
}
- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    return [NSCollectionViewItem new];
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    return 0;
}
@end
