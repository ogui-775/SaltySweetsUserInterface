//Created by Salty on 2/23/26.

#import "SOIconReplacementPageController.h"

@interface SOIconReplacementPageController ()
@property (strong) NSArray<NSBundle *> * currentFolderApps;
@end

@implementation SOIconReplacementPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.appsCollection registerClass:[SOAppItem class]
                 forItemWithIdentifier:@"AppItem"];

    [self.folderComboBox setStringValue:@"/Applications/"];
    NSURL * applicationsURL = [NSURL URLWithString:@"/Applications/"];
    self.currentFolderApps = GetAppsForFolderAtURL(applicationsURL);

    self.lastSelectedFolder = self.folderComboBox.stringValue;

    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    self.applicationFolderPaths = [NSMutableArray arrayWithArray:[AppDelegate applicationFolderPaths]];
    [self.appsCollection reloadData];
}

- (void)mouseDown:(NSEvent *)event{
    [self.view.window makeFirstResponder:self.appsCollection];
}

- (void)keyUp:(NSEvent *)event {
    NSString * chars = event.charactersIgnoringModifiers;
    if (chars.length <= 0) return;

    unichar c = [chars characterAtIndex:0];
    if (!(c >= 'a' && c <= 'z')) return;

    NSUInteger matchIndex = [self.currentFolderApps indexOfObjectPassingTest:^BOOL(NSBundle * obj,
                                                                                   NSUInteger idx,
                                                                                   BOOL *stop) {
        NSString * name = [[[obj bundlePath] lastPathComponent] stringByDeletingPathExtension];
        if (name.length > 0) {
            NSString * firstLetter = [[name substringToIndex:1] lowercaseString];
            return [firstLetter isEqualToString:[chars lowercaseString]];
        }
        return NO;
    }];

    if (matchIndex != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:matchIndex inSection:0];
        NSSet * indexPaths = [NSSet setWithObject:indexPath];
        
        [self.appsCollection scrollToItemsAtIndexPaths:indexPaths
                                        scrollPosition:NSCollectionViewScrollPositionTop];
        
        [self.appsCollection selectItemsAtIndexPaths:indexPaths
                                      scrollPosition:NSCollectionViewScrollPositionNone];

    }
}

- (IBAction)folderSelectionDidChange:(NSComboBox *)sender{
    if ([sender.stringValue isEqualToString:self.lastSelectedFolder])
        return;
    
    self.lastSelectedFolder = sender.stringValue;
    
    NSString * expandedPath = [sender.stringValue stringByExpandingTildeInPath];
    NSURL * applicationsURL = [NSURL fileURLWithPath:expandedPath isDirectory:YES];
    self.currentFolderApps = GetAppsForFolderAtURL(applicationsURL);
    [self.appsCollection reloadData];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox{
    return self.applicationFolderPaths.count;
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index{
    return self.applicationFolderPaths[index];
}

NSArray<NSBundle *> * GetAppsForFolderAtURL(NSURL * url){
    NSMutableArray<NSBundle *> * retArray = [NSMutableArray array];
    CFArrayRef bundles = CFBundleCreateBundlesFromDirectory(kCFAllocatorDefault, (__bridge CFURLRef)url, CFSTR(".app"));
    NSUInteger count = CFArrayGetCount(bundles);
    for (NSUInteger i = 0; i < count; i++){
        CFURLRef cfURL = CFBundleCopyBundleURL((CFBundleRef)CFArrayGetValueAtIndex(bundles, i));
        NSURL * nsURL = CFBridgingRelease(cfURL);
        [retArray addObject:[NSBundle bundleWithURL:nsURL]];
    }
    CFRelease(bundles);
    
    [retArray sortUsingComparator:^NSComparisonResult(NSBundle * obj1, NSBundle *  obj2) {
        NSString * b1Name = [[obj1.bundlePath lastPathComponent] stringByDeletingPathExtension];
        NSString * b2Name = [[obj2.bundlePath lastPathComponent] stringByDeletingPathExtension];
        
        return [[b1Name localizedLowercaseString] localizedCompare:[b2Name localizedLowercaseString]];
    }];
    
    return retArray.copy;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
             itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {

    NSCollectionViewItem * item =
        [collectionView makeItemWithIdentifier:@"AppItem" forIndexPath:indexPath];

    NSUInteger index = indexPath.item;
    NSBundle * bundleForView = self.currentFolderApps[index];

    item.textField.stringValue = [[bundleForView.bundlePath lastPathComponent] stringByDeletingPathExtension];
    
    NSString * baseline = nil;
    
    if (bundleForView.bundleIdentifier) {
        const SOEncodedKeyPath tBundle = {
            .rootKey = &kSOIconsBundleDict,
            .components = @[bundleForView.bundleIdentifier]
        };
        
        baseline = [self getBaselineForEncodedKeypath:&tBundle];
    }
    
    if (baseline){
        item.imageView.image =
            [[NSImage alloc] initWithContentsOfFile:[[AppDelegate iconsDir] stringByAppendingPathComponent:baseline]];
    } else {
        item.imageView.image =
            [[NSWorkspace sharedWorkspace] iconForFile:bundleForView.bundlePath];
    }

    item.imageView.editable = YES;

    [(SOAppItem *)item setAssignedBundle:bundleForView];
    [(SOAppItemImageView *)item.imageView setTarget:self];
    [(SOAppItemImageView *)item.imageView setAction:@selector(imageViewDidGetAltered:)];
    [(SOAppItemImageView *)item.imageView setParentItem:(SOAppItem *)item];
    [(SOAppItemImageView *)item.imageView setOriginalSetImage:item.imageView.image];
        
    return item;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.currentFolderApps.count;
}

- (IBAction)imageViewDidGetAltered:(SOAppItemImageView *)sender{
    if (sender.image){
        NSString * bundleId = [sender parentItem].assignedBundle.bundleIdentifier;
        
        const SOEncodedKeyPath tBundlePath = {
            .rootKey = &kSOIconsBundleDict,
            .components = @[bundleId]
        };
        
        [self setPendingIconResourceChangeForKeypath:&tBundlePath
                                            resource:[NSData dataWithContentsOfURL:sender.draggedFileURL]
                                            filename:[sender.draggedFileURL lastPathComponent]
                                                note:[NSString stringWithFormat:@"Set icon for %@ to %@",
                                                      bundleId,
                                                      sender.draggedFileURL.lastPathComponent]];
    } else {
        NSString * bundleId = [sender parentItem].assignedBundle.bundleIdentifier;
        
        const SOEncodedKeyPath tBundlePath = {
            .rootKey = &kSOIconsBundleDict,
            .components = @[bundleId]
        };
        
        if (![self getBaselineForEncodedKeypath:&tBundlePath]){
            sender.image = sender.originalSetImage;
            return;
        }
        
        [self setPendingIconResourceChangeForKeypath:&tBundlePath
                                            resource:nil
                                            filename:nil
                                                note:[NSString stringWithFormat:@"Cleared icon for %@",
                                                      bundleId]];
    }
}

- (IBAction)folderEditWasPressed:(NSButton *)sender{
    if (!self.folderSheetController){
        self.folderSheetController = [[SOListEditorSheetController alloc] initWithListContents:self.applicationFolderPaths
                                                                                          name:@"Edit Folders"];
        [self.folderSheetController window];
        [self.folderSheetController setSheetParent:self.view.window];
    }
    
    [self.view.window beginSheet:self.folderSheetController.window
               completionHandler:^(NSModalResponse returnCode) {
        self.applicationFolderPaths = self.folderSheetController.listContents;
        
        [AppDelegate setApplicationFolderPaths:self.applicationFolderPaths];
        
        [self.folderComboBox reloadData];
        if ([self.folderComboBox indexOfSelectedItem] > self.applicationFolderPaths.count - 1){
            [self.folderComboBox selectItemAtIndex:self.applicationFolderPaths.count - 1];
            [self folderSelectionDidChange:self.folderComboBox];
        }

        [self.appsCollection reloadData];
    }];
}

@end

@implementation SOAppItem

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 120)];

    SOAppItemImageView * imageView = [[SOAppItemImageView alloc] initWithFrame:CGRectMake(20, 30, 60, 60)];
    NSTextField * textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];

    textField.editable = NO;
    textField.bezeled = NO;
    textField.drawsBackground = NO;

    self.imageView = imageView;
    self.imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.textField = textField;
    [self.textField setFont:[NSFont fontWithName:@"Helvetica" size:12]];
    [self.textField setAlignment:NSTextAlignmentCenter];
    [self.textField setLineBreakMode:NSLineBreakByWordWrapping];

    [self.view addSubview:imageView];
    [self.view addSubview:textField];
}

@end

@implementation SOAppItemImageView
- (void)awakeFromNib{
    [self registerForDraggedTypes:@[NSPasteboardTypeURL]];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard * pBoard = [sender draggingPasteboard];
    
    if ([[pBoard types] containsObject:NSPasteboardTypeFileURL]) {
        id files = [pBoard propertyListForType:NSPasteboardTypeFileURL];
        NSURL * fileURL = [NSURL URLWithString:[files isKindOfClass:NSArray.class] ? [files firstObject] : (NSString *)files];
        [self setDraggedFileURL:fileURL];
    }
    
    return [super performDragOperation:sender];
}
@end
