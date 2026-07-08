//Created by Salty on 6/21/26.

#import "SOSidebarIconReplacementPageController.h"

@interface SOSidebarItem : NSObject
@property (strong, nonatomic) NSURL *sourceFileURL;
@property (strong, nonatomic) NSImage *displayImage;
@property (strong, nonatomic) NSString *itemString;
@property (assign) BOOL isUnsavedItem;

- (instancetype)initWithURL:(NSURL *)url isNew:(BOOL)isNew;
@end

@implementation SOSidebarItem

- (instancetype)initWithURL:(NSURL *)url isNew:(BOOL)isNew{
    self = [super init];
    if (self){
        self.sourceFileURL = url;
        self.isUnsavedItem = isNew;
        self.itemString = @"Replace me!";
        
        if (!url)
            return self;
        
        if ([[url pathExtension] isEqualToString:@"sicon"]){
            SOSiconBundle *siconRef = [[SOSiconBundle alloc] initWithURL:url];
            CGImageRef cgImg = [siconRef CGImageForIndex:0];
            NSImage *nsImg = [[NSImage alloc] initWithCGImage:cgImg size:CGSizeMake(0, 0)];
            CGImageRelease(cgImg);
            self.displayImage = nsImg;
        } else {
            self.displayImage = [[NSImage alloc] initWithContentsOfURL:url];
        }
    }
    return self;
}

- (void)setSourceFileURL:(NSURL *)sourceFileURL{
    _sourceFileURL = sourceFileURL;
    
    if ([[sourceFileURL pathExtension] isEqualToString:@"sicon"]){
        SOSiconBundle *siconRef = [[SOSiconBundle alloc] initWithURL:sourceFileURL];
        CGImageRef cgImg = [siconRef CGImageForIndex:0];
        NSImage *nsImg = [[NSImage alloc] initWithCGImage:cgImg size:CGSizeMake(0, 0)];
        CGImageRelease(cgImg);
        _displayImage = nsImg;
    } else {
        _displayImage = [[NSImage alloc] initWithContentsOfURL:sourceFileURL];
    }
}

@end

#pragma mark - Real controller tings

@interface SOSidebarIconReplacementPageController ()
@property (strong, nonatomic) SOObservableDictionary *mutableDict;
@property (strong, nonatomic) NSMutableArray<NSString *> *baselineKeys;
@end

@implementation SOSidebarIconReplacementPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [AppDelegate registerUndoManagerForClear:self.undoManager withController:self];
    self.mutableDict = [[SOObservableDictionary alloc] initWithDelegate:self];
    self.baselineKeys = [NSMutableArray array];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    [self.baselineKeys removeAllObjects];
    
    NSDictionary *freshDict = [self getBaselineForEncodedKey:&kSOIconsSidebarDict];
    NSArray<NSString *> *freshKeys = [[freshDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    self.baselineKeys = [freshKeys mutableCopy];
    
    for (NSUInteger idx = 0; idx < [self.baselineKeys count]; idx++){
        NSString *key = self.baselineKeys[idx];
        NSURL *itemUrl = [[[AppDelegate currentIconThemeBundle] resourceURL] URLByAppendingPathComponent:freshDict[key]];
        
        SOSidebarItem *item = [[SOSidebarItem alloc] initWithURL:itemUrl isNew:NO];
        [item setItemString:key];
        
        [self.mutableDict setObject:item forKey:@(idx)];
    }
    
    [self.sidebarContainer reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.mutableDict count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    SOSidebarItem *item = [self.mutableDict objectForKey:@(row)];
    if ([[tableColumn identifier] isEqualToString:@"col0"]){
        return item.displayImage;
    } else {
        return item.itemString;
    }
}

- (IBAction)tableViewWasClicked:(NSTableView *)sender{
    SOSidebarItem *item = [self.mutableDict objectForKey:@(sender.selectedRow)];
    
    self.imageView.image = item.displayImage;
    self.labelView.stringValue = [item.sourceFileURL lastPathComponent];
}

- (IBAction)addLineWasPressed:(NSButton *)sender{
    SOSidebarItem *newItem = [[SOSidebarItem alloc] initWithURL:nil isNew:YES];
    
    [self.mutableDict setObject:newItem forKey:@(self.sidebarContainer.numberOfRows)];
    
    [self.sidebarContainer reloadData];
}

- (IBAction)removeLineWasPressed:(NSButton *)sender{
    self.imageView.image = nil;
    
    if ([[self.mutableDict objectForKey:@(self.sidebarContainer.selectedRow)] isUnsavedItem]){
        [self.mutableDict removeObjectForKey:@(self.sidebarContainer.selectedRow)];
        [self.sidebarContainer reloadData];
        return;
    }
    
    SOSidebarItem *itemForRm = [self.mutableDict objectForKey:@(self.sidebarContainer.selectedRow)];
    
    [self.undoManager registerUndoWithTarget:self handler:^(SOSidebarIconReplacementPageController *c){
        [self.mutableDict setObject:itemForRm forKey:@(self.sidebarContainer.numberOfRows)];
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
        [self.sidebarContainer reloadData];
    }];
    [self.undoManager setActionName:[NSString stringWithFormat:@"Removed %@", itemForRm.itemString]];
    
    [self.mutableDict removeObjectForKey:@(self.sidebarContainer.selectedRow)];
    
    SOEncodedKeyPath tRm = {
        .rootKey = &kSOIconsSidebarDict,
        .components = @[itemForRm.itemString]
    };
    
    [self setPendingIconResourceChangeForKeypath:&tRm
                                        resource:nil
                                        filename:nil
                                            note:[NSString stringWithFormat:@"Removed %@",
                                                  itemForRm.itemString]];
}

- (IBAction)imageWellWasInteractedWith:(SODragAwareImageView *)sender{
    SOSidebarItem *selectedItem = [self.mutableDict objectForKey:@(self.sidebarContainer.selectedRow)];
    
    if (!selectedItem){
        self.imageView.image = nil;
        return;
    }
    
    if ([[sender.draggedFileURL pathExtension] isEqualToString:@"sicon"]){
        sender.image = [SOSiconBundle NSImageOrNilForURL:sender.draggedFileURL];
    }
    
    SOEncodedKeyPath tNewPath = {
        .rootKey = &kSOIconsSidebarDict,
        .components = @[selectedItem.itemString]
    };
    
    if (!sender.image && !selectedItem.isUnsavedItem){
        NSURL *originalSourceFileURL = selectedItem.sourceFileURL;
        NSInteger currentRow = [self.sidebarContainer selectedRow];
        NSImage *currentImage = selectedItem.displayImage;
        
        [self.undoManager registerUndoWithTarget:self handler:^(SOSidebarIconReplacementPageController *c){
            if ([self.sidebarContainer selectedRow] == currentRow){
                [self.imageView setImage:currentImage];
            }
            
            [selectedItem setSourceFileURL:originalSourceFileURL];
            [self.pendingChangeArray removeLastObject];
            [self.changeDelegate contentDidChangeState:self];
            [self.sidebarContainer reloadData];
        }];
        [self.undoManager setActionName:[NSString stringWithFormat:@"Remove %@", selectedItem.itemString]];
        
        [self setPendingIconResourceChangeForKeypath:&tNewPath
                                            resource:nil
                                            filename:nil
                                                note:[NSString stringWithFormat:@"Removed %@",
                                                      selectedItem.itemString]];
        
        [selectedItem setSourceFileURL:nil];
        [self.sidebarContainer reloadData];
        return;
    } else if (!sender.image){
        NSURL *originalSourceFileURL = selectedItem.sourceFileURL;
        NSInteger currentRow = [self.sidebarContainer selectedRow];
        NSImage *currentImage = selectedItem.displayImage;
        
        [self.undoManager registerUndoWithTarget:self handler:^(SOSidebarIconReplacementPageController *c){
            if ([self.sidebarContainer selectedRow] == currentRow){
                [self.imageView setImage:currentImage];
            }
            
            [selectedItem setSourceFileURL:originalSourceFileURL];
            [self.sidebarContainer reloadData];
        }];
        [self.undoManager setActionName:[NSString stringWithFormat:@"Remove %@", selectedItem.itemString]];
        
        [selectedItem setSourceFileURL:nil];
        [self.sidebarContainer reloadData];
        return;
    }
    
    NSURL *oldURL = selectedItem.sourceFileURL;
    NSImage *oldImage = selectedItem.displayImage;
    [selectedItem setSourceFileURL:sender.draggedFileURL];
    NSInteger currentRow = [self.sidebarContainer selectedRow];
    
    [self.undoManager registerUndoWithTarget:self handler:^(SOSidebarIconReplacementPageController *c){
        if ([self.sidebarContainer selectedRow] == currentRow){
            [self.imageView setImage:oldImage];
        }
        
        [selectedItem setSourceFileURL:oldURL];
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
        [self.sidebarContainer reloadData];
    }];
    [self.undoManager setActionName:[NSString stringWithFormat:@"Set %@", [oldURL lastPathComponent]]];
    

    
    [self setPendingIconResourceChangeForKeypath:&tNewPath
                                        resource:[NSData dataWithContentsOfURL:selectedItem.sourceFileURL]
                                        filename:[selectedItem.sourceFileURL lastPathComponent]
                                            note:[NSString stringWithFormat:@"Set %@ to %@",
                                                  selectedItem.itemString,
                                                  [selectedItem.sourceFileURL lastPathComponent]]];
    
    [self.sidebarContainer reloadData];
    
    self.labelView.stringValue = [selectedItem.sourceFileURL lastPathComponent];
    
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (![object isKindOfClass:NSString.class])
        return;
    
    NSString *newString = object;
    NSString *oldString = [(SOSidebarItem *)[self.mutableDict objectForKey:@(row)] itemString];
    
    SOSidebarItem *item = [self.mutableDict objectForKey:@(row)];
    
    [item setItemString:newString];
    
    const SOEncodedKeyPath tNewKey = {
        .rootKey = &kSOIconsSidebarDict,
        .components = @[newString]
    };
    
    if (!item.isUnsavedItem){
        const SOEncodedKeyPath tOldKey = {
            .rootKey = &kSOIconsSidebarDict,
            .components = @[self.baselineKeys[row]]
        };

        [self setPendingKeyStringChangeForKeypath:&tOldKey
                           withReplacementKeypath:&tNewKey
                      andOptionalValueReplacement:nil];
    }

    for (SOChange *change in self.pendingChangeArray){
        change.iconChange = YES;
        if ([change isKindOfClass:SOKeyChange.class])
            continue;
        
        if ([[change.plistKeyPath->components lastObject] isEqualToString:oldString])
            free((void *)change.plistKeyPath);
            change.plistKeyPath = [change allocKeyPath:&tNewKey];
            change.changeNote   = [change.changeNote stringByReplacingOccurrencesOfString:oldString withString:newString];
    }
    
    [self.sidebarContainer reloadData];
}

- (void)objectWithKey:(id)aKey didGetSetTo:(id)anObject {
    
}

- (void)willRemoveObject:(id)anObject forKey:(id)aKey { 
    
}

@end
