//Created by Salty on 7/31/26.

#import "SONavigatorBar.h"

@interface SONavigatorBar ()
@property (strong, nonatomic) NSArray<SONavigatorBarItem *> *currentOptions;
@property (weak, nonatomic) SONavigatorBarItem *currentlySelectedOption;
@end

@interface SONavigatorBarItemView : NSCollectionViewItem
@property (weak) SONavigatorBar *delegate;
@property (weak) SONavigatorBarItem *item;
@end

@implementation SONavigatorBar
- (void)finishInitWithOptions:(NSArray<SONavigatorBarItem *> *)itemArray{
    if (self && itemArray && [itemArray count] > 0){
        self.currentOptions = itemArray;
        self.currentlySelectedOption = itemArray[0];
        [self.navigationCollectionView reloadData];
        self.navigationCollectionView.selectable = YES;
        
        [self navigateTo:self.currentlySelectedOption];
        [self.navigationCollectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
        [(SONavigatorBarStretchyView *)self.view setInnerView:self];
    }
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.currentOptions count];
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger idx = indexPath.item;
    SONavigatorBarItem *baseBarItem = [self.currentOptions objectAtIndex:idx];
    
    if (!baseBarItem)
        return nil;
    
    CGRect boundsBox = CGRectMake(0,
                                  0,
                                  self.navigationCollectionView.bounds.size.height,
                                  self.navigationCollectionView.bounds.size.height);

    NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    
    if (boundsBox.size.width < [baseBarItem.title sizeWithAttributes:attributes].width)
        boundsBox.size.width = [baseBarItem.title sizeWithAttributes:attributes].width + 10;
    
    SONavigatorBarItemView *item = [[SONavigatorBarItemView alloc] init];
    item.delegate = self;
    item.item = baseBarItem;
    
    NSView *itemView = [[NSView alloc] initWithFrame:boundsBox];
    
    item.view = itemView;
    [itemView setWantsLayer:YES];
    itemView.layer.borderWidth = 2;
    itemView.layer.borderColor = NSColor.clearColor.CGColor;
    itemView.layer.cornerRadius = 5;
    
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:CGRectMake(0,
                                                                           boundsBox.size.height * 0.45,
                                                                           boundsBox.size.width,
                                                                           boundsBox.size.height * 0.5)];
    
    imageView.image = baseBarItem.image;
    item.imageView = imageView;
    imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    [itemView addSubview:imageView];

    NSTextField *textView = [[NSTextField alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          boundsBox.size.width + 1,
                                                                          boundsBox.size.height * 0.5)];

    textView.stringValue = baseBarItem.title;
    textView.editable = NO;
    textView.bordered = NO;
    textView.refusesFirstResponder = YES;
    textView.usesSingleLineMode = YES;
    textView.alignment = NSTextAlignmentCenter;
    textView.backgroundColor = NSColor.clearColor;

    item.textField = textView;
    [itemView addSubview:textView];
    
    return item;
}

- (void)replaceCurrentOptionsWithArray:(NSArray<SONavigatorBarItem *> *)itemArray{
    if (!itemArray || [itemArray count] < 1)
        return;
    
    self.currentOptions = itemArray;
    self.currentlySelectedOption = itemArray[0];
    
    [self.navigationCollectionView.collectionViewLayout invalidateLayout];
    [self.navigationCollectionView reloadData];
    
    [self navigateTo:self.currentlySelectedOption];
    [self.navigationCollectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (void)navigateTo:(SONavigatorBarItem *)item{
    [[SOViewPane defaultInstance] requestPageChangeTo:item.boundController];
}

- (NSSize)collectionView:(NSCollectionView *)collectionView
                  layout:(NSCollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger idx = indexPath.item;
    if (idx >= [self.currentOptions count]) {
        return NSMakeSize(collectionView.bounds.size.height, collectionView.bounds.size.height);
    }
    SONavigatorBarItem *item = [self.currentOptions objectAtIndex:idx];
    NSString *title = item.title ? item.title : @"";
    
    NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    
    NSSize textSize = [title sizeWithAttributes:attributes];
    
    CGFloat horizontalPadding = 10.0;
    CGFloat calculatedWidth = textSize.width + horizontalPadding;
    
    CGFloat barHeight = collectionView.bounds.size.height;
    if (calculatedWidth < barHeight) {
        calculatedWidth = barHeight;
    }
    
    return NSMakeSize(calculatedWidth, barHeight);
}

- (NSEdgeInsets)collectionView:(NSCollectionView *)collectionView
                        layout:(NSCollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    NSInteger itemCount = [self.currentOptions count];
    if (itemCount == 0) {
        return NSEdgeInsetsZero;
    }
    
    CGFloat totalItemsWidth = 0.0;
    for (NSInteger idx = 0; idx < itemCount; idx++) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:idx inSection:section];
        NSSize itemSize = [self collectionView:collectionView
                                        layout:collectionViewLayout
                        sizeForItemAtIndexPath:path];
        totalItemsWidth += itemSize.width;
    }
    
    CGFloat interItemSpacing = 10.0;
    CGFloat totalSpacing = (itemCount - 1) * interItemSpacing;
    CGFloat totalContentWidth = totalItemsWidth + totalSpacing;
    
    CGFloat collectionViewWidth = collectionView.bounds.size.width;
    if (collectionViewWidth > totalContentWidth) {
        CGFloat leftInset = (collectionViewWidth - totalContentWidth) / 2.0;
        return NSEdgeInsetsMake(0, leftInset, 0, leftInset);
    }
    
    return NSEdgeInsetsZero;
}
@end

@implementation SONavigatorBarItemView
- (void)setSelected:(BOOL)selected{
    if (!selected){
        self.view.layer.borderColor = [NSColor clearColor].CGColor;
        [self.view.layer removeAllAnimations];
        return;
    }
    
    CAKeyframeAnimation *selectionGlow = [[CAKeyframeAnimation alloc] init];
    selectionGlow.duration = 2.0;
    selectionGlow.autoreverses = YES;
    selectionGlow.repeatCount = INFINITY;
    selectionGlow.values = @[
        (id)NSColor.selectedControlColor.CGColor,
        (id)NSColor.clearColor.CGColor,
        (id)NSColor.selectedControlColor.CGColor
    ];
    
    [self.view.layer addAnimation:selectionGlow
                           forKey:@"borderColor"];
    
    [self.delegate setCurrentlySelectedOption:self.item];
    [self.delegate navigateTo:self.delegate.currentlySelectedOption];
}
@end

@implementation SONavigatorBarStretchyView
- (void)setFrame:(NSRect)frame{
    [super setFrame:frame];
    
    if ([self.innerView isKindOfClass:SONavigatorBar.class]){
        SONavigatorBar *innerView = (SONavigatorBar *)self.innerView;
        
        [[innerView navigationCollectionView].collectionViewLayout invalidateLayout];
        [[innerView navigationCollectionView] setFrame:CGRectMake(0,
                                                                     0,
                                                                     frame.size.width,
                                                                     frame.size.height)];
    }
}
@end
