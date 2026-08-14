//Created by Salty on 8/12/26.

#import "SOPackViewController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface SOPackViewController ()
@property (strong) NSDrawer *drawer;
@property (weak) NSWindowController *parentWindowController;
@property (strong) NSMutableArray<SOSiconPackBundle *> *packs;
@property (strong) NSArray<NSURL *> *currnetlyViewedPackContents;
@property (weak) SOSiconPackBundle *currentlyViewedPack;
@property (strong) NSCollectionView *collectionView;
@property (strong) NSScrollView *scroller;
@property (strong) NSButton *backButton;
@property (strong) NSView *drawerBannerBar;
@end

@implementation SOPackViewController

@synthesize currentlyViewedPack = _currentlyViewedPack;

- (instancetype)initWithParentWindowController:(NSWindowController *)wc{
    self = [super initWithNibName:@"SOPackViewPage"
                           bundle:nil];
    if (self){
        _drawer = [[NSDrawer alloc] initWithContentSize:CGSizeMake(400,
                                                                   400)
                                          preferredEdge:NSMaxXEdge];
        _parentWindowController = wc;
        _drawer.parentWindow = self.parentWindowController.window;
        _scroller = [[NSScrollView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
        _scroller.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        _scroller.hasVerticalScroller = YES;
        _scroller.hasHorizontalScroller = NO;
        
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
        
        NSClickGestureRecognizer *doubleClicker = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(doubleClicked:)];
        doubleClicker.numberOfClicksRequired = 2;
        
        [_collectionView addGestureRecognizer:doubleClicker];
        NSCollectionViewFlowLayout *cvl = [[NSCollectionViewFlowLayout alloc] init];
        cvl.sectionInset = NSEdgeInsetsMake(5, 5, 5, 5);
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
        
        [_drawer.contentView addSubview:_scroller];
        [_scroller setDocumentView:_collectionView];
        [_scroller addSubview:_drawerBannerBar];
        
        self.view = _drawer.contentView;
        [_collectionView reloadData];
    }
    return self;
}

- (IBAction)showDrawer:(id)sender{
    if (self.drawer.state == 2)
        [self.drawer close];
    else
        [self.drawer open];
}

- (void)doubleClicked:(NSClickGestureRecognizer *)gesture {
    if (gesture.state != NSGestureRecognizerStateEnded) {
        return;
    }

    if (!self.currentlyViewedPack){
        NSInteger idx = [self.collectionView selectionIndexes].firstIndex;
        
        self.currentlyViewedPack = self.packs[idx];
        [self.collectionView reloadData];
        
        if (self.currentlyViewedPack)
            self.backButton.enabled = YES;
    }
}

- (void)goBack:(NSButton *)sender{
    self.currentlyViewedPack = nil;
    [self.collectionView reloadData];
    self.backButton.enabled = NO;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
             itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = indexPath.item;
    
    if (self.currentlyViewedPack){
        NSURL *url = [self.currnetlyViewedPackContents objectAtIndex:idx];
        SOPackViewItem *item = [[SOPackViewItem alloc] initWithName:[url lastPathComponent]
                                                                URL:url];
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

- (void)setCurrentlyViewedPack:(SOSiconPackBundle *)currentlyViewedPack{
    if (currentlyViewedPack){
        _currentlyViewedPack = currentlyViewedPack;
        _currnetlyViewedPackContents = [_currentlyViewedPack iconURLs];
    } else {
        _currentlyViewedPack = nil;
        _currnetlyViewedPackContents = nil;
    }
}

- (SOSiconPackBundle *)currentlyViewedPack{
    return _currentlyViewedPack;
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
    
    if (!item)
        return nil;
    
    
    NSPasteboardItem *pb = [[NSPasteboardItem alloc] init];
    
    if (item.URL)
        [pb setString:item.URL.absoluteString forType:NSPasteboardTypeURL];
    
    if (item.imageView.image) {
        NSData *tiffData = [item.imageView.image TIFFRepresentation];
        if (tiffData)
            [pb setData:tiffData forType:NSPasteboardTypeTIFF];
    }
    
    return pb;
}
@end

#pragma clang diagnostic pop
