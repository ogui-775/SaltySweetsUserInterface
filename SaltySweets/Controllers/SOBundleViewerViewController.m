//Created by Salty on 9/18/26.

#import "SOBundleViewerViewController.h"
#import "SOBundleViewerController.h"
#import "../Services/SOAtomicAccessPoint.h"
#import "SOTagSourceController.h"
#import "SOPackViewItem.h"

@interface SOBundleViewerViewController ()
@property (strong) NSMutableArray<SOSiconPackBundle *> *packs;
@property (strong) NSArray<NSURL *> *currnetlyViewedPackContents;
@property (weak)   SOSiconPackBundle *currentlyViewedPack;
@property (strong) SOTagSourceController *colorSpaceTagsController;
@property (strong) SOTagSourceController *imagePropertiesTagsController;
@end

@implementation SOBundleViewerViewController
- (void)awakeFromNib{
    [super awakeFromNib];
    [self updateContents];
    
    NSClickGestureRecognizer *doubleClicker = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(doubleClicked:)];
    doubleClicker.numberOfClicksRequired = 2;
    [self.collectionView addGestureRecognizer:doubleClicker];

    NSTextField *tagsTitle = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 180, 20)];
    tagsTitle.editable = NO;
    tagsTitle.selectable = NO;
    tagsTitle.usesSingleLineMode = YES;
    tagsTitle.stringValue = @"Item Tags";

    _colorSpaceTagsController = [[SOTagSourceController alloc] initWithTagSourceType:SOTagSourceTypeColorSpace
                                                                            tagArray:@[
        @"Display P3",
        @"sRGB",
        @"Greyscale",
        @"B&W"
    ]];

    _imagePropertiesTagsController = [[SOTagSourceController alloc] initWithTagSourceType:SOTagSourceTypeNSImageProperties
                                                                                 tagArray:@[
        @"Template"
    ]];

    [_tagsStack addView:tagsTitle inGravity:NSStackViewGravityTop];
    [_tagsStack addView:_colorSpaceTagsController.view inGravity:NSStackViewGravityTop];
    [_tagsStack addView:_imagePropertiesTagsController.view inGravity:NSStackViewGravityTop];

    [_colorSpaceTagsController.view setContentHuggingPriority:NSLayoutPriorityRequired
                                                 forOrientation:NSLayoutConstraintOrientationVertical];
    
    [_imagePropertiesTagsController.view setContentHuggingPriority:NSLayoutPriorityRequired
                                                      forOrientation:NSLayoutConstraintOrientationVertical];
    
    [[SOAtomicAccessPoint sharedInstance] setPackViewController:self];

    [_collectionView reloadData];
    
    [_collectionView registerForDraggedTypes:@[@"com.saltysoft.SaltySweets.boundproperties"]];
}

- (void)doubleClicked:(NSClickGestureRecognizer *)gesture {
    if (self.currentlyViewedPack)
        return;

    NSPoint point = [gesture locationInView:self.collectionView];

    NSIndexPath *indexPath =
        [self.collectionView indexPathForItemAtPoint:point];

    if (!indexPath)
        return;

    if (indexPath.item >= self.packs.count)
        return;

    self.currentlyViewedPack = self.packs[indexPath.item];
    self.currnetlyViewedPackContents =
        self.currentlyViewedPack.iconURLs;

    [self.collectionView reloadData];

    self.backButton.enabled = YES;
    self.packDisplayLabel.stringValue =
        self.currentlyViewedPack.packNameAndAuthor;
    self.packDisplayLabel.hidden = NO;
}

- (void)updateContents{
    if (!self.packs)
        self.packs = [NSMutableArray array];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *packURL = [NSURL fileURLWithPath:[SOAtomicAccessPoint sharedInstance].iconPackBundleDirectory
                                isDirectory:YES];
    
    [_packs removeAllObjects];
    
    NSArray<NSURL *> *packDirURLS = [fm contentsOfDirectoryAtURL:packURL
                                      includingPropertiesForKeys:nil
                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                           error:nil];
    
    for (NSURL *url in packDirURLS){
        if (![[url pathExtension] isEqualToString:@"siconpack"])
            continue;
        
        [_packs addObject:[[SOSiconPackBundle alloc] initWithURL:url]];
    }
    
    self.currentlyViewedPack = nil;
    [self.collectionView reloadData];
    self.backButton.enabled = NO;
    self.packDisplayLabel.stringValue = @"";
    self.packDisplayLabel.hidden = YES;
}

- (void)goBack:(NSButton *)sender{
    self.currentlyViewedPack = nil;
    self.currnetlyViewedPackContents = nil;
    [self.collectionView reloadData];
    self.backButton.enabled = NO;
    self.packDisplayLabel.stringValue = @"";
    self.packDisplayLabel.hidden = YES;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = indexPath.item;
    
    if (self.currentlyViewedPack){
        NSURL *url = [self.currnetlyViewedPackContents objectAtIndex:idx];
        SOPackViewItem *item = [[SOPackViewItem alloc] initWithName:[url lastPathComponent]
                                                                URL:url];
        item.hasTags = [[self.currentlyViewedPack tagsPlist] objectForKey:[url lastPathComponent]];
        return item;
    }
    
    SOSiconPackBundle *bundle = [self.packs objectAtIndex:idx];
    SOPackViewItem *item = [[SOPackViewItem alloc] initWithName:[bundle.bundleURL lastPathComponent].stringByDeletingPathExtension
                                                            URL:bundle.bundleURL];
    return item;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (self.currentlyViewedPack)
        return [self.currnetlyViewedPackContents count];
    
    return [self.packs count];
}

#pragma mark - Pasteboard

- (BOOL)collectionView:(NSCollectionView *)collectionView
canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
             withEvent:(NSEvent *)event{
    if (!self.currnetlyViewedPackContents)
        return NO;
    
    return YES;
}

- (id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView
       pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger idx = indexPath.item;
    SOPackViewItem *item = (SOPackViewItem *)[self.collectionView itemAtIndex:idx];

    return item;
}

-(NSDragOperation)collectionView:(NSCollectionView *)collectionView
                    validateDrop:(id<NSDraggingInfo>)draggingInfo
               proposedIndexPath:(NSIndexPath **)proposedDropIndexPath
                   dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation{
    if (!self.currentlyViewedPack)
        return NSDragOperationNone;
    
    NSPasteboard *pb = [draggingInfo draggingPasteboard];
    
    if ([pb pasteboardItems]){
        id item = [pb pasteboardItems].firstObject;
        
        if (!item)
            return NSDragOperationNone;
        
        NSDictionary *plist = [item propertyListForType:@"com.saltysoft.SaltySweets.boundproperties"];
        
        if (!plist)
            return NSDragOperationNone;
        
        return NSDragOperationLink;
    }
    return NSDragOperationNone;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView
            acceptDrop:(id<NSDraggingInfo>)draggingInfo
             indexPath:(NSIndexPath *)indexPath
         dropOperation:(NSCollectionViewDropOperation)dropOperation{
    SOPackViewItem *droppedOnItem = (SOPackViewItem *)[self.collectionView itemAtIndexPath:indexPath];
    
    if (!droppedOnItem)
        return NO;
    
    NSURL *itemURL = [droppedOnItem URL];
    
    if (!itemURL)
        return NO;
    
    NSPasteboard *pb = [draggingInfo draggingPasteboard];
    NSDictionary *plist = nil;
    
    if ([pb pasteboardItems]){
        id item = [pb pasteboardItems].firstObject;
        
        if (!item)
            return NO;
        
         plist = [item propertyListForType:@"com.saltysoft.SaltySweets.boundproperties"];
        
        if (!plist)
            return NO;
    }
    
    SOSiconPackBundle *pack = [[SOSiconPackBundle alloc] initWithURL:self.currentlyViewedPack.bundleURL];
    
    NSMutableDictionary *tagsDict = [pack tagsPlist];
    NSMutableDictionary *iconTags = [tagsDict objectForKey:itemURL.lastPathComponent] ?: [NSMutableDictionary dictionary];
    
    [iconTags setObject:plist.allValues[0] forKey:plist.allKeys[0]];
    [tagsDict setObject:iconTags forKey:itemURL.lastPathComponent];
    
    NSError *err = nil;
    [pack writeToTagsPlist:tagsDict
                 withError:&err];
    
    droppedOnItem.hasTags = YES;
    
    if (!err)
        return YES;
    
    return NO;
}
@end
