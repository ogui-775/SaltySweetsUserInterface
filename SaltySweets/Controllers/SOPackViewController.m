//Created by Salty on 8/12/26.

#import "SOPackViewController.h"
#import "../SONavigatorBarMaster.h"
#import "SOWindowController.h"
#import "SOPackViewItem.h"
#import "../Services/SOAtomicAccessPoint.h"
#import "SOTagSourceController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface SOPackViewController ()
@property (strong) NSDrawer *drawer;
@property (weak)   NSWindowController *parentWindowController;
@property (strong) NSMutableArray<SOSiconPackBundle *> *packs;
@property (strong) NSArray<NSURL *> *currnetlyViewedPackContents;
@property (weak)   SOSiconPackBundle *currentlyViewedPack;
@property (strong) NSCollectionView *collectionView;
@property (strong) NSScrollView *scroller;
@property (strong) NSButton *backButton;
@property (strong) NSView *drawerBannerBar;
@property (strong) NSTextField *packDisplayLabel;
@property (strong) NSScrollView *tagsStackEnclosure;
@property (strong) NSStackView *tagsStack;
@property (strong) SOTagSourceController *colorSpaceTagsController;
@property (strong) SOTagSourceController *imagePropertiesTagsController;
@end

@implementation SOPackViewController
- (instancetype)initWithParentWindowController:(NSWindowController *)wc{
    self = [super initWithNibName:@"SOPackViewPage"
                           bundle:nil];
    if (self){
        _drawer = [[NSDrawer alloc] initWithContentSize:CGSizeMake(600,
                                                                   400)
                                          preferredEdge:NSMaxXEdge];
        _parentWindowController = wc;
        _drawer.parentWindow = self.parentWindowController.window;
        _scroller = [[NSScrollView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
        _scroller.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        _scroller.hasVerticalScroller = YES;
        _scroller.hasHorizontalScroller = NO;
        _scroller.drawsBackground = NO;
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *packURL = [NSURL fileURLWithPath:[SOAtomicAccessPoint sharedInstance].iconPackBundleDirectory
                                    isDirectory:YES];
        
        NSArray<NSURL *> *packDirURLS = [fm contentsOfDirectoryAtURL:packURL
                                          includingPropertiesForKeys:nil
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                               error:nil];
        
        _packs = [NSMutableArray array];
        
        for (NSURL *url in packDirURLS){
            if (![[url pathExtension] isEqualToString:@"siconpack"])
                continue;
            
            [_packs addObject:[[SOSiconPackBundle alloc] initWithURL:url]];
        }
        
        _collectionView = [[NSCollectionView alloc] initWithFrame:_drawer.contentView.bounds];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.selectable = YES;
        _collectionView.backgroundColors = @[NSColor.clearColor];
        
        NSClickGestureRecognizer *doubleClicker = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(doubleClicked:)];
        doubleClicker.numberOfClicksRequired = 2;
        [self.collectionView addGestureRecognizer:doubleClicker];
        
        NSCollectionViewFlowLayout *cvl = [[NSCollectionViewFlowLayout alloc] init];
        cvl.sectionInset = NSEdgeInsetsMake(5, 5, 35, 5);
        cvl.itemSize = CGSizeMake(100, 80);
        _collectionView.collectionViewLayout = cvl;
        _collectionView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

        _backButton = [[NSButton alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        _backButton.image = [NSImage imageWithSystemSymbolName:@"arrowshape.backward.circle.fill" accessibilityDescription:nil];
        _backButton.imageScaling = NSImageScaleProportionallyUpOrDown;
        _backButton.target = self;
        _backButton.action = @selector(goBack:);
        _backButton.bezelStyle = NSBezelStyleCircular;
        _backButton.enabled = NO;
        
        _drawerBannerBar = [[NSView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    40,
                                                                    40)];
        _drawerBannerBar.autoresizingMask = NSViewWidthSizable;
        [_drawerBannerBar addSubview:_backButton];
        
        _packDisplayLabel = [[NSTextField alloc] initWithFrame:CGRectMake(10, 10, 380, 20)];
        _packDisplayLabel.editable = NO;
        _packDisplayLabel.drawsBackground = YES;
        _packDisplayLabel.bordered = NO;
        _packDisplayLabel.alignment = NSCenterTextAlignment;
        _packDisplayLabel.hidden = YES;
        _packDisplayLabel.bezeled = YES;
        _packDisplayLabel.bezelStyle = NSTextFieldRoundedBezel;
        _packDisplayLabel.autoresizingMask = NSViewWidthSizable;
        
        _tagsStackEnclosure = [[NSScrollView alloc] initWithFrame:CGRectMake(400, 0, 200, 400)];
        _tagsStackEnclosure.drawsBackground = NO;
        _tagsStackEnclosure.autoresizingMask = NSViewHeightSizable | NSViewMinXMargin;
        
        _tagsStack = [[NSStackView alloc] initWithFrame:CGRectMake(0, 0, 200, 400)];
        
        [_tagsStackEnclosure setDocumentView:_tagsStack];
        
        _tagsStack.orientation = NSUserInterfaceLayoutOrientationVertical;
        _tagsStack.autoresizingMask = NSViewHeightSizable | NSViewMinXMargin;
        _tagsStack.translatesAutoresizingMaskIntoConstraints = YES;
        _tagsStack.spacing = 5;
        _tagsStack.edgeInsets = NSEdgeInsetsMake(5, 5, 5, 5);
        _tagsStack.distribution = NSStackViewDistributionFillEqually;
        
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
        
        [_drawer.contentView addSubview:_tagsStackEnclosure];
        [_drawer.contentView addSubview:_scroller];
        [_scroller setDocumentView:_collectionView];
        [_scroller addSubview:_drawerBannerBar];
        [_drawer.contentView addSubview:_packDisplayLabel];
        [[SOAtomicAccessPoint sharedInstance] setPackViewController:self];
        
        self.view = _drawer.contentView;
        [_collectionView reloadData];
        
        [_collectionView registerForDraggedTypes:@[@"com.saltysoft.SaltySweets.boundproperties"]];
    }
    return self;
}

- (IBAction)showDrawer:(id)sender{
    if (self.drawer.state == 2)
        [self.drawer close];
    else
        [self.drawer open];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)item{
    if ([[item itemIdentifier] isEqualToString:@"drawerControl"]){
        BOOL shouldShowDrawer = [self shouldShowDrawer];
        if (!shouldShowDrawer)
            [self.drawer close];
        
        return shouldShowDrawer;
    }
    
    return YES;
}

- (BOOL)shouldShowDrawer{
    SOWindowController *wc = (SOWindowController *)self.parentWindowController;
    if (wc.navigatorBarMaster){
        return !wc.navigatorBarMaster.isMainMenuShown;
    }
    
    return YES;
}

- (void)updateContents{
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

#pragma clang diagnostic pop
