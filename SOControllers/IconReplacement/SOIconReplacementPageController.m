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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.applicationFolderPaths = [NSMutableArray arrayWithArray:[AppDelegate applicationFolderPaths]];
        [self.appsCollection reloadData];
    });
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

    [(SOAppItemImageView *)item.imageView ensureGlowLayer];

    NSString * baseline = nil;
    
    if (bundleForView.bundleIdentifier) {
        const SOEncodedKeyPath tBundle = {
            .rootKey = &kSOIconsBundleDict,
            .components = @[bundleForView.bundleIdentifier]
        };
        
        baseline = [self getBaselineForEncodedKeypath:&tBundle];
    }
    
    if (baseline){
        if ([[baseline pathExtension] isEqualToString:@"sicon"]){
            SOSiconBundle *bundle = [SOSiconBundle bundleWithURL:[[[AppDelegate currentIconThemeBundle] resourceURL] URLByAppendingPathComponent:baseline]];
            CGImageRef img = [bundle CGImageForSize:CGSizeMake(128, 128)
                                           isRetina:self.view.window.backingScaleFactor > 1 ? YES : NO
                                             isDark:[NSApp.effectiveAppearance.name containsString:@"Dark"]
                                         isSelected:NO];
            
            if (img){
                item.imageView.image = [[NSImage alloc] initWithCGImage:img size:CGSizeMake(0, 0)];
                CGImageRelease(img);
            }
        } else
        item.imageView.image =
            [[NSImage alloc] initWithData:[[AppDelegate currentIconThemeBundle] dataForFileNamed:baseline withError:nil]];
        
        [(SOAppItemImageView *)item.imageView setIsReplaced:YES];
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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AppDelegate registerUndoManagerForClear:self.undoManager withController:self];
    });
    
    NSString * bundleId = [sender parentItem].assignedBundle.bundleIdentifier;
    const SOEncodedKeyPath tBundlePath = {
        .rootKey = &kSOIconsBundleDict,
        .components = @[bundleId]
    };
    
    if (sender.image){
        if ([[sender.draggedFileURL pathExtension] isEqualToString:@"sicon"]){
            SOSiconBundle *bundle = [SOSiconBundle bundleWithURL:sender.draggedFileURL];
            CGImageRef img = [bundle CGImageForIndex:0];
            sender.image = [[NSImage alloc] initWithCGImage:img size:CGSizeMake(0, 0)];
            CGImageRelease(img);
        }
        
        [self.undoManager registerUndoWithTarget:self handler:^void(SOIconReplacementPageController * controller){
            [sender setImage:sender.originalSetImage];
            if ([self getBaselineForEncodedKeypath:&tBundlePath])
                [sender setIsReplaced:YES];
            else
                [sender setIsReplaced:NO];
            [self.pendingChangeArray removeObject:self.pendingChangeArray.lastObject];
            [self.changeDelegate contentDidChangeState:self];
        }];
        [self.undoManager setActionName:[NSString stringWithFormat:@"%@ Set Icon", bundleId]];
        
        [self setPendingIconResourceChangeForKeypath:&tBundlePath
                                            resource:[NSData dataWithContentsOfURL:sender.draggedFileURL]
                                            filename:[sender.draggedFileURL lastPathComponent]
                                                note:[NSString stringWithFormat:@"Set icon for %@ to %@",
                                                      bundleId,
                                                      sender.draggedFileURL.lastPathComponent]];
        
        [sender setIsPendingReplace:YES];
    } else {
        id baseline = [self getBaselineForEncodedKeypath:&tBundlePath];
        if (!baseline){
            sender.image = sender.originalSetImage;
            return;
        }

        [self.undoManager registerUndoWithTarget:self handler:^void(SOIconReplacementPageController * controller){
            [sender setImage:sender.originalSetImage];
            [sender setIsReplaced:YES];
            [self.pendingChangeArray removeObject:self.pendingChangeArray.lastObject];
            [self.changeDelegate contentDidChangeState:self];
        }];
        [self.undoManager setActionName:[NSString stringWithFormat:@"%@ Clear Icon", bundleId]];
        
        [self setPendingIconResourceChangeForKeypath:&tBundlePath
                                            resource:nil
                                            filename:nil
                                                note:[NSString stringWithFormat:@"Cleared icon for %@",
                                                      bundleId]];
        [sender setIsPendingRemove:YES];
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
               completionHandler:^void(NSModalResponse returnCode){
        self.applicationFolderPaths = self.folderSheetController.listContents;
        
        [AppDelegate setApplicationFolderPaths:self.applicationFolderPaths];
        
        [self.folderComboBox reloadData];
        NSInteger idx = [self.folderComboBox indexOfSelectedItem];
        NSInteger count = [self.applicationFolderPaths count];
        if (idx > (count - 1)){
            [self.folderComboBox selectItemAtIndex:count];
            [self folderSelectionDidChange:self.folderComboBox];
        }

        [self.appsCollection reloadData];
        return;
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

- (void)prepareForReuse{
    [super prepareForReuse];
    [self.imageView prepareForReuse];
}
@end

@implementation SOAppItemImageView

@synthesize isReplaced = _isReplaced;
@synthesize isPendingRemove = _isPendingRemove;
@synthesize isPendingReplace = _isPendingReplace;

- (void)awakeFromNib{
    [super awakeFromNib];
    
}

- (void)ensureGlowLayer {
    if (self.glowShadowLayer) return;

    self.wantsLayer = YES;

    self.glowShadowLayer = [CALayer layer];
    self.glowShadowLayer.masksToBounds = NO;
    self.glowShadowLayer.shadowOffset = CGSizeZero;
    self.glowShadowLayer.shadowRadius = 6;
    self.glowShadowLayer.backgroundColor = NSColor.clearColor.CGColor;

    [self.layer addSublayer:self.glowShadowLayer];
}

- (void)layout {
    [super layout];

    if (!self.glowShadowLayer) return;

    CGFloat cornerRadius = 5.0;
    CGRect bounds = self.bounds;

    self.glowShadowLayer.frame = bounds;

    CGPathRef shadowPath = CGPathCreateWithRoundedRect(bounds, cornerRadius, cornerRadius, nil);
    self.glowShadowLayer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);

    CAShapeLayer * glowMask = [CAShapeLayer layer];
    glowMask.frame = bounds;
    glowMask.fillRule = kCAFillRuleEvenOdd;

    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGRect outerRect = CGRectInset(bounds, -30, -30);
    CGPathAddRect(maskPath, nil, outerRect);

    CGPathRef innerPath = CGPathCreateWithRoundedRect(bounds, cornerRadius, cornerRadius, nil);
    CGPathAddPath(maskPath, nil, innerPath);

    glowMask.path = maskPath;
    self.glowShadowLayer.mask = glowMask;

    CGPathRelease(innerPath);
    CGPathRelease(maskPath);
}

- (BOOL)isReplaced{
    return _isReplaced;
}

- (void)setIsReplaced:(BOOL)isReplaced{
    _isReplaced = isReplaced;
    
    if (isReplaced){
        _isPendingRemove = NO;
        _isPendingReplace = NO;
    } else {
        self.glowShadowLayer.shadowOpacity = 0;
    }
    
    if (!self.glowShadowLayer || !isReplaced)
        return;
    
    self.glowShadowLayer.shadowOpacity = 0.7;
    self.glowShadowLayer.shadowColor = NSColor.greenColor.CGColor;
}

- (BOOL)isPendingRemove{
    return _isPendingRemove;
}

- (void)setIsPendingRemove:(BOOL)isPendingRemove{
    _isPendingRemove = isPendingRemove;
    
    if (isPendingRemove){
        _isReplaced = NO;
        _isPendingReplace = NO;
    }
    
    if (!self.glowShadowLayer)
        return;
    
    self.glowShadowLayer.shadowOpacity = 0.7;
    self.glowShadowLayer.shadowColor = NSColor.redColor.CGColor;
}

- (BOOL)isPendingReplace{
    return _isPendingReplace;
}

- (void)setIsPendingReplace:(BOOL)isPendingReplace{
    _isPendingReplace = isPendingReplace;
    
    if (isPendingReplace){
        _isReplaced = NO;
        _isPendingRemove = NO;
    }
    
    if (!self.glowShadowLayer)
        return;
    
    self.glowShadowLayer.shadowOpacity = 0.7;
    self.glowShadowLayer.shadowColor = NSColor.orangeColor.CGColor;
}

- (void)prepareForReuse {
    _isReplaced = NO;
    _isPendingRemove = NO;
    _isPendingReplace = NO;

    self.glowShadowLayer.shadowOpacity = 0;
    self.glowShadowLayer.shadowColor = nil;
}
@end
