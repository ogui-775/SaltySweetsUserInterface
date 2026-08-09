//Created by Salty on 8/7/26.

#import "SOMainMenuView.h"

@interface SOMainMenuView ()
@property (strong) NSDictionary<NSNumber *, NSArray *> *itemsBySectionIndex;
@end

@implementation SOMainMenuView
- (void)finishInitWithItemDictionary:(NSDictionary<NSNumber *,
                                      NSArray<SONavigatorBarItem *> *> *)dictionary{
    if (!dictionary)
        return;
    
    self.itemsBySectionIndex = dictionary;
    self.collectionView.collectionViewLayout = [[SOMainMenuLayout alloc] initCustom];
    
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView{
    return [[self.itemsBySectionIndex allKeys] count];
}

- (SOCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    SOCollectionViewItem *item = [[SOCollectionViewItem alloc] init];
    
    NSInteger section = indexPath.section;
    NSInteger index   = indexPath.item;
    
    NSArray<SONavigatorBarItem *> *sourceItems = [self.itemsBySectionIndex objectForKey:@(section)];
    
    SONavigatorBarItem *sourceItem = sourceItems[index];
    item.imageView.image       = sourceItem.image;
    item.textField.stringValue = sourceItem.label;
    item.boundController       = sourceItem.viewController;
    
    return item;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (!self.itemsBySectionIndex)
        return 0;
    
    return [[self.itemsBySectionIndex objectForKey:@(section)] count];
}

- (void)collectionView:(NSCollectionView *)collectionView
didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    [NSApp sendAction:self.action
                   to:self.delegate
                 from:self];
    [self.collectionView deselectAll:nil];
}

- (NSView *)collectionView:(NSCollectionView *)collectionView
    viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind
                          atIndexPath:(NSIndexPath *)indexPath {
    SOMainMenuSectionHeader *header =
        [collectionView makeSupplementaryViewOfKind:kind
                                       withIdentifier:@"SOMainMenuSectionHeader"
                                         forIndexPath:indexPath];

    switch (indexPath.section) {
        case 0:
            header.title = @"Home";
            break;

        case 1:
            header.title = @"Dock";
            break;

        case 2:
            header.title = @"Icons";
            break;
    }

    return header;
}
@end
