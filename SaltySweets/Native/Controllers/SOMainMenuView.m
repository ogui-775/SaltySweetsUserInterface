//Created by Salty on 8/7/26.

#import "SOMainMenuView.h"
#import "SODisplayCurrentsPageController.h"

@interface SOMainMenuView ()
@property (strong) NSDictionary<NSNumber *, NSArray *> *itemsBySectionIndex;
@property (strong) SODisplayCurrentsPageController *contentsController;
@end

@implementation SOMainMenuView
- (void)finishInitWithItemDictionary:(NSDictionary<NSNumber *,
                                      NSArray<SONavigatorBarItem *> *> *)dictionary{
    if (!dictionary)
        return;
    
    self.itemsBySectionIndex = dictionary;
    self.collectionView.collectionViewLayout = [[SOMainMenuLayout alloc] initCustom];
    
    [self.collectionView reloadData];
    
    [self.view addSubview:self.contentsController.view
               positioned:NSWindowAbove
               relativeTo:self.collectionView];
    
    NSUInteger viewWidth = [[self view] bounds].size.width;
    NSUInteger contentWidth = [[[self contentsController] view] bounds].size.width;
    NSUInteger contentHeight = [[[self contentsController] view] bounds].size.height;
    
    [self.contentsController.view setFrame:CGRectMake(viewWidth - contentWidth - 5,
                                                      10,
                                                      contentWidth,
                                                      contentHeight)];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.contentsController = [[SODisplayCurrentsPageController alloc] init];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView{
    return [[self.itemsBySectionIndex allKeys] count];
}

- (SOCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    SOCollectionViewItem *item = [SOCollectionViewItem new];
    
    NSInteger section = indexPath.section;
    NSInteger index   = indexPath.item;
    
    NSArray<SONavigatorBarItem *> *sourceItems = [self.itemsBySectionIndex objectForKey:@(section)];
    
    SONavigatorBarItem *sourceItem = sourceItems[index];
    item.innerButton.image          = sourceItem.image;
    item.innerButton.title          = sourceItem.label;
    item.innerButton.action         = self.action;
    item.innerButton.target         = self.delegate;
    item.innerButton.collectionView = self.collectionView;
    item.boundController            = sourceItem.viewController;
    
    if ([[sourceItem identifier] isEqualToString:@"siconstudio"])
        item.isSiconStudioButton = YES;
    
    return item;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (!self.itemsBySectionIndex)
        return 0;
    
    return [[self.itemsBySectionIndex objectForKey:@(section)] count];
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
            header.title = @"Icons";
            break;

        case 1:
            header.title = @"Dock";
            break;

        case 2:
            header.title = @"SaltySweets";
            break;
    }

    return header;
}
@end
