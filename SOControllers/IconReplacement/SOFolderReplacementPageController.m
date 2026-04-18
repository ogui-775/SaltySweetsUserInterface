//Created by Salty on 4/17/26.

#import "SOFolderReplacementPageController.h"

@interface SOFolderReplacementPageController ()
@property (strong) NSMutableArray<UTType *> * currentFolderTypes;
@property (weak) UTType * currentDisplayedType;
@end

@implementation SOFolderReplacementPageController
const SOEncodedKeyPath tDefaultBackFlap = {
    .rootKey = &kSOIconsFolderDict,
    .components = @[@"com.apple.icon-package.folder.back-flap"]
};
const SOEncodedKeyPath tDefaultFrontFlap = {
    .rootKey = &kSOIconsFolderDict,
    .components = @[@"com.apple.icon-package.folder.front-flap"]
};

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.folderScrollerCollection registerClass:[SOFolderItem class]
                           forItemWithIdentifier:@"FolderItem"];
    
    self.currentFolderTypes = [NSMutableArray array];
    UTType * folderType = [UTType typeWithIdentifier:@"public.folder"];
    [UTType _enumerateAllDeclaredTypesUsingBlock:^(UTType * type) {
        if ([type conformsToType:folderType]){
            [self.currentFolderTypes addObject:type];
        }
    }];
    
    [self refreshOrLoadBaseline];
    [self.folderScrollerCollection setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
    [AppDelegate registerUndoManagerForClear:self.undoManager withController:self];
    
    if (!@available(macOS 26, *))
        [self setFlapsHidden:YES];
}

- (void)refreshOrLoadBaseline{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.folderScrollerCollection reloadData];
    });
}

- (void)setFlapsHidden:(BOOL)hidden{
    if (!@available(macOS 26, *)){
        if (!hidden)
            return;
    }
    
    self.backFlapWell.hidden = hidden;
    self.frontFlapWell.hidden = hidden;
    self.backFlapWellLabel.hidden = hidden;
    self.frontFlapWellLabel.hidden = hidden;
    self.fullVariantSwitch.hidden = hidden;
    self.fullVariantSwitchLabel.hidden = hidden;
    self.frontFlapWellAdditionalLabel.hidden = hidden;
    self.backFlapWellAdditionalLabel.hidden = hidden;
    self.folderPaperSegmented.enabled = !hidden;
    self.compositeButton.hidden = hidden;
}

- (IBAction)compositeButtonWasPressed:(NSButton *)sender{
    
}

- (IBAction)fullVariantSwitchWasFlipped:(NSSwitch *)sender{
    [self.folderScrollerCollection reloadData];
    [self.folderPaperSegmented setSelectedSegment:0];
    [self folderPaperSegmentedWasSwitched:self.folderPaperSegmented];
    BOOL variant = sender.state == NSControlStateValueOn;
    [self.folderWell setImage:[self imageForVariant:variant UTI:self.currentDisplayedType.identifier] ?:
     [[NSWorkspace sharedWorkspace] iconForContentType:self.currentDisplayedType]];
}

- (IBAction)folderPaperSegmentedWasSwitched:(NSSegmentedControl *)sender{
    NSUInteger index = sender.indexOfSelectedItem;
    BOOL fullVariant = self.fullVariantSwitch.state == NSControlStateValueOn;
    if (index == 0){
        self.compositeButton.enabled = NO;
        self.folderWell.tag = 0;
        self.currentFolderTypeLabel.stringValue = self.currentDisplayedType.identifier;
        self.folderWell.image = [self imageForVariant:fullVariant UTI:self.currentDisplayedType.identifier] ?:
                                [[NSWorkspace sharedWorkspace] iconForContentType:self.currentDisplayedType];
    } else {
        self.folderWell.tag = 1;
        self.compositeButton.enabled = YES;
        NSImage * paperCustom = [self paperForUTI:self.currentDisplayedType.identifier];
        if (!paperCustom){
            self.currentFolderTypeLabel.stringValue = @"Using Default";
            const SOEncodedKeyPath tDefaultPaper = {
                .rootKey = &kSOIconsFolderDict,
                .components = @[@"com.apple.icon-package.folder.paper-sheet"]
            };
            self.folderWell.image = [self loadImageForEncodedKeypath:&tDefaultPaper];
            return;
        }
        self.folderWell.image = [self paperForUTI:self.currentDisplayedType.identifier];
        self.currentFolderTypeLabel.stringValue = @"Using Custom";
    }
}

- (IBAction)actionOnFlapWell:(SODragAwareImageView *)sender{
    BOOL isFrontFlap = sender.tag == 1;
    
    NSString * composite = self.currentDisplayedType.identifier;
    composite = isFrontFlap ? [composite stringByAppendingString:@".front-flap"] :
                              [composite stringByAppendingString:@".back-flap"];
    
    const SOEncodedKeyPath tFlap = {
        .rootKey = &kSOIconsFolderDict,
        .components = @[composite]
    };
    
    [self.undoManager registerUndoWithTarget:self
                                     handler:^void(SOFolderReplacementPageController * undoSender){
        sender.image = [self loadImageForEncodedKeypath:&tFlap] ?: isFrontFlap ?
        [self loadImageForEncodedKeypath:&tDefaultFrontFlap] : [self loadImageForEncodedKeypath:&tDefaultBackFlap];
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
    }];
    [self.undoManager setActionName:@"Set Flap"];
    
    [self setPendingIconResourceChangeForKeypath:&tFlap
                                        resource:[NSData dataWithContentsOfURL:sender.draggedFileURL]
                                        filename:sender.draggedFileURL.lastPathComponent
                                            note:[NSString stringWithFormat:@"Set %@ to %@",
                                                  composite,
                                                  sender.draggedFileURL.lastPathComponent]];
}

- (IBAction)actionOnFolderWell:(SODragAwareImageView *)sender{
    BOOL isPaperSheet  = sender.tag == 1;
    BOOL isFullVariant = self.fullVariantSwitch.state == NSControlStateValueOn;
    NSString * composite = self.currentDisplayedType.identifier;
    
    if (isPaperSheet)
        composite = [composite stringByAppendingString:@".paper-sheet"];
    else if (isFullVariant && !isPaperSheet)
        composite = [composite stringByAppendingString:@".full"];
    
    const SOEncodedKeyPath tFolder = {
        .rootKey = &kSOIconsFolderDict,
        .components = @[composite]
    };
    
    [self.undoManager registerUndoWithTarget:self
                                     handler:^void(SOFolderReplacementPageController * undoSender){
        sender.image = [self loadImageForEncodedKeypath:&tFolder] ?: [[NSWorkspace sharedWorkspace] iconForContentType:self.currentDisplayedType];
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
    }];
    [self.undoManager setActionName:[NSString stringWithFormat:@"Set %@", isPaperSheet ? @"Paper" : @"Folder"]];
    
    [self setPendingIconResourceChangeForKeypath:&tFolder
                                        resource:[NSData dataWithContentsOfURL:sender.draggedFileURL]
                                        filename:[sender.draggedFileURL lastPathComponent]
                                            note:[NSString stringWithFormat:@"Set %@ to %@",
                                                  composite,
                                                  sender.draggedFileURL.lastPathComponent]];
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    return self.currentFolderTypes.count;
}

- (NSImage *)paperForUTI:(NSString *)uti{
    NSString * composite = [uti stringByAppendingString:@".paper-sheet"];
    
    const SOEncodedKeyPath tPaper = {
        .rootKey = &kSOIconsFolderDict,
        .components = @[composite]
    };
    
    NSImage * ret = [self loadImageForEncodedKeypath:&tPaper];
    
    return ret;
}

- (NSImage *)imageForVariant:(BOOL)full UTI:(NSString *)uti{
    NSString * composite = full ? [uti stringByAppendingString:@".full"] : uti;
    
    const SOEncodedKeyPath tFolder = {
        .rootKey = &kSOIconsFolderDict,
        .components = @[composite]
    };
    
    NSImage * ret = [self loadImageForEncodedKeypath:&tFolder];
    if (!ret)
        return nil;
    
    [ret setSize:CGSizeMake(32, 32)];
    return ret;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    SOFolderItem * item = [collectionView makeItemWithIdentifier:@"FolderItem"
                                                    forIndexPath:indexPath];
    NSUInteger index = indexPath.item;
    item.assignedType = self.currentFolderTypes[index];
    item.imageView.image = self.fullVariantSwitch.state == NSControlStateValueOn ?
        [self imageForVariant:YES UTI:item.assignedType.identifier] ?: [[NSWorkspace sharedWorkspace] iconForContentType:item.assignedType]:
        [self imageForVariant:NO  UTI:item.assignedType.identifier] ?: [[NSWorkspace sharedWorkspace] iconForContentType:item.assignedType];
    
    item.textField.stringValue = [[item.assignedType.identifier stringByReplacingOccurrencesOfString:@"com.apple."
                                                                                          withString:@""]
                                                                stringByReplacingOccurrencesOfString:@"-folder"
                                                                                          withString:@""];
    item.parentConfigurableController = self;
    return item;
}

- (void)selectedFolderDidChange:(SOFolderItem *)sender{
    [self setCurrentDisplayedType:sender.assignedType];
    [self.folderPaperSegmented setSelectedSegment:0];
    [self folderPaperSegmentedWasSwitched:self.folderPaperSegmented];
    
    if ([sender.assignedType.identifier containsString:@"trash"])
        [self setFlapsHidden:YES];
    else
        [self setFlapsHidden:NO];
    
    self.currentFolderTypeLabel.stringValue = sender.assignedType.identifier;
    self.folderWell.image = sender.imageView.image;
    
    if (!@available(macOS 26, *))
        return;
    
    NSString * frontComposite = [NSString stringWithFormat:@"%@.front-flap", sender.assignedType.identifier];
    NSString * backComposite = [NSString stringWithFormat:@"%@.back-flap", sender.assignedType.identifier];
    const SOEncodedKeyPath tFrontFlap = {
        .rootKey = &kSOIconsFolderDict,
        .components = @[frontComposite]
    };
    const SOEncodedKeyPath tBackFlap = {
        .rootKey = &kSOIconsFolderDict,
        .components = @[backComposite]
    };
    
    self.backFlapWell.image  = [self loadImageForEncodedKeypath:&tBackFlap];
    self.frontFlapWell.image = [self loadImageForEncodedKeypath:&tFrontFlap];
    
    if (!self.backFlapWell.image){
        self.backFlapWell.image = [self loadImageForEncodedKeypath:&tDefaultBackFlap];
        [self.backFlapWellAdditionalLabel setStringValue:@"Using Default"];
    } else {
        [self.backFlapWellAdditionalLabel setStringValue:@"Using Custom"];
    }
    
    if (!self.frontFlapWell.image){
        self.frontFlapWell.image = [self loadImageForEncodedKeypath:&tDefaultFrontFlap];
        [self.frontFlapWellAdditionalLabel setStringValue:@"Using Default"];
    } else {
        [self.frontFlapWellAdditionalLabel setStringValue:@"Using Custom"];
    }
}

@end

@implementation SOFolderItem
- (void)loadView{
    self.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    self.view.wantsLayer = YES;
    
    NSTextField * textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 10, 70, 15)];
    textField.drawsBackground = NO;
    textField.editable = NO;
    textField.bezeled = NO;
    textField.font = [NSFont fontWithName:@"Helvetica" size:12];
    textField.alignment = NSTextAlignmentCenter;
    self.textField = textField;
    
    SODragAwareImageView * imageView = [[SODragAwareImageView alloc] initWithFrame:CGRectMake(10, 20, 50, 50)];
    imageView.editable = NO;
    self.imageView = imageView;
    [self.view addSubview:self.textField];
    [self.view addSubview:self.imageView];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];

    if (selected){
        [self.view.layer setBackgroundColor:NSColor.selectedControlColor.CGColor];
        [self.parentConfigurableController selectedFolderDidChange:self];
    }
    else
        [self.view.layer setBackgroundColor:NSColor.clearColor.CGColor];
}
@end
