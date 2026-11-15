//Created by Salty on 8/7/26.

#import "SOMainMenuView.h"
#import "SODisplayCurrentsPageController.h"
#import "SONavigatorBarItem.h"
#import "SOCollectionViewItem.h"

static NSString * const SOMainMenuSectionHeaderKind = @"SOMainMenuSectionHeader";
static NSString * const SOMainMenuBackgroundKindA = @"SOMainMenuBackgroundA";
static NSString * const SOMainMenuBackgroundKindB = @"SOMainMenuBackgroundB";

#pragma mark - Header

@interface SOMainMenuSectionHeader : NSView
@property (strong) NSString *title;
@property (assign, nonatomic) BOOL showsTopDivider;
@end

@implementation SOMainMenuSectionHeader
@synthesize title = _title;

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    [self setNeedsDisplay:YES];
}

- (NSString *)title{
    return _title;
}

- (void)setShowsTopDivider:(BOOL)showsTopDivider {
    _showsTopDivider = showsTopDivider;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:[NSFont smallSystemFontSize] weight:NSFontWeightLight],
        NSForegroundColorAttributeName: NSColor.labelColor };
    
    NSRect textRect = NSMakeRect( 15.0,
                                 -8.0,
                                 NSWidth(self.bounds) - 52.0,
                                 NSHeight(self.bounds) );
    [self.title drawInRect:textRect withAttributes:attributes];
    
    if (self.showsTopDivider) {
        [[NSColor colorWithWhite:0.9 alpha:1] setFill];
        CGFloat y = self.isFlipped ? 0.0 : NSHeight(self.bounds) - 1.0;
        NSRectFill(NSMakeRect(0.0, y, NSWidth(self.bounds), 1.0));
    }
}

@end

#pragma mark - Background A

@interface SOMainMenuSectionBackgroundA : NSView
@end

@implementation SOMainMenuSectionBackgroundA
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor colorWithWhite:0.0 alpha:0.05] setFill];
    
    NSRectFill(self.bounds);
}
@end

#pragma mark - Background B

@interface SOMainMenuSectionBackgroundB : NSView
@end

@implementation SOMainMenuSectionBackgroundB
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor colorWithWhite:0.0 alpha:0] setFill];
    NSRectFill(self.bounds);
}
@end

#pragma mark - Layout

@interface SOMainMenuLayout : NSCollectionViewCompositionalLayout
- (instancetype)initCustom;
@end

@implementation SOMainMenuLayout
- (instancetype)initCustom {
    self = [super initWithSectionProvider:^NSCollectionLayoutSection *(NSInteger sectionIndex, id environment) {
        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:
                                            [NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                          heightDimension:
                                            [NSCollectionLayoutDimension absoluteDimension:35]];
        
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
        
        NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:
                                             [NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                           heightDimension:
                                             [NSCollectionLayoutDimension fractionalHeightDimension:0.20]];
        
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize
                                                                                        subitem:item
                                                                                          count:8];
        
        NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
        
        section.contentInsets = NSDirectionalEdgeInsetsMake(0.0, 10.0, 5.0, 10.0);
        section.supplementariesFollowContentInsets = NO;
        
        NSCollectionLayoutSize *headerSize =
            [NSCollectionLayoutSize
                sizeWithWidthDimension:
                    [NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                heightDimension:
                    [NSCollectionLayoutDimension absoluteDimension:25.0]];

        NSCollectionLayoutBoundarySupplementaryItem *header =
            [NSCollectionLayoutBoundarySupplementaryItem
                boundarySupplementaryItemWithLayoutSize:headerSize
                elementKind:SOMainMenuSectionHeaderKind
                alignment:NSRectAlignmentTop];

        section.boundarySupplementaryItems = @[header];
        
        group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:10];
        
        NSString *backgroundKind =
        (sectionIndex % 2 == 0) ? SOMainMenuBackgroundKindA
                                : SOMainMenuBackgroundKindB;
        
        NSCollectionLayoutDecorationItem *background = [NSCollectionLayoutDecorationItem backgroundDecorationItemWithElementKind:backgroundKind];
        
        section.decorationItems = @[background];
        
        return section;
    }];
    
    if (self) {
        [self registerClass:[SOMainMenuSectionBackgroundA class]
    forDecorationViewOfKind:SOMainMenuBackgroundKindA];
        
        [self registerClass:[SOMainMenuSectionBackgroundB class]
    forDecorationViewOfKind:SOMainMenuBackgroundKindB];
    }
    
    return self;
}
@end

#pragma mark - Main Menu View

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
            header.showsTopDivider = NO;
            break;

        case 1:
            header.title = @"Dock";
            header.showsTopDivider = YES;
            break;

        case 2:
            header.title = @"SaltySweets";
            header.showsTopDivider = YES;
            break;
    }

    return header;
}
@end
