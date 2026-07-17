//Created by Salty on 6/11/26.

#import "SOSystemIconReplacementPageController.h"

@interface SOSystemIconReplacementPageController ()
@property (strong, nonatomic) SOObservableDictionary *currentExtensions;
@property (strong, nonatomic) NSMutableDictionary *loadedImages;
@property (strong, nonatomic) SOListEditorSheetController *listEditor;
@end

@implementation SOSystemIconReplacementPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    self.currentExtensions = [[SOObservableDictionary alloc] initWithDelegate:self];
    self.loadedImages = [NSMutableDictionary dictionary];
    
    [[SOAtomicAccessPoint sharedInstance] registerUndoManagerForClear:self.undoManager withController:self];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    NSDictionary *extensionsFromPack = [self getBaselineForEncodedKey:&kSOIconsSystemDict];
    
    NSArray<NSString *> *keys = [[extensionsFromPack allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSString *key in keys){
        SOEncodedKeyPath tEncoded = {
            .rootKey = &kSOIconsSystemDict,
            .components = @[key]
        };
        
        [self.currentExtensions setObject:[extensionsFromPack objectForKey:key]
                                   forKey:key];
        
        [self.loadedImages setObject:[self loadImageForEncodedKeypath:&tEncoded]
                              forKey:key];
    }

    [self.extensionTable reloadData];
    
    NSString *selected = [self selectedRowString];
    
    if (!selected)
        return;
    
    self.imageView.image = [self.loadedImages objectForKey:selected];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.currentExtensions count];
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row{
    NSArray *keys = [[self.currentExtensions allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    return [keys objectAtIndex:row];
}

- (IBAction)editExtensionTableWasClicked:(NSButton *)sender{
    NSMutableArray<NSString *> *currentExtensionsArray = [NSMutableArray arrayWithArray:[[self.currentExtensions allKeys]
                                                                                         sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    
    self.listEditor = [[SOListEditorSheetController alloc] initWithListContents:currentExtensionsArray
                                                                           name:@"Extensions"];
    
    [self.listEditor setSheetParent:self.view.window];
    
    [self.view.window beginSheet:self.listEditor.window
               completionHandler:^(NSModalResponse returnCode) {
        if (returnCode != NSModalResponseOK)
            return;
        
        for (NSUInteger idx = 0; idx < [self.listEditor.listContents count]; idx++){
            NSString *str = self.listEditor.listContents[idx];
            
            self.listEditor
                .listContents[idx] = [str stringByReplacingOccurrencesOfString:@"." withString:@""];
        }
        
        NSSet *newList = [NSSet setWithArray:self.listEditor.listContents];
        NSSet *oldList = [NSSet setWithArray:[self.currentExtensions allKeys]];
        
        NSMutableSet *added = [newList mutableCopy];
        [added minusSet:oldList];
        
        NSMutableSet *removed = [oldList mutableCopy];
        [removed minusSet:newList];
        
        for (NSString *add in added){
            [self.currentExtensions setObject:@""
                                       forKey:add];
        }
        
        for (NSString *rmv in removed){
            [self.currentExtensions removeObjectForKey:rmv];
        }
        
        [self.extensionTable reloadData];
    }];
}

- (IBAction)extensionTableWasClicked:(NSTableView *)sender{
    if ([sender selectedRow] == -1)
        return;
    
    NSString *cellValue = [self selectedRowString];

    self.imageView.image = [self.loadedImages objectForKey:cellValue];
}

- (IBAction)imageWellWasInteractedWith:(SODragAwareImageView *)sender{
    NSString *str = [self selectedRowString];
    
    if (!sender.image){
        NSString *currentSetStr = [self.currentExtensions objectForKey:str];
        NSImage  *currentSetImg = [self.loadedImages objectForKey:str];
        NSString *currentSetRow = [self selectedRowString];
        [self.undoManager registerUndoWithTarget:self
                                         handler:^(SOSystemIconReplacementPageController *c){
            [self.currentExtensions setObject:currentSetStr forKey:str];
            [self.loadedImages setObject:currentSetImg forKey:str];
            
            if ([currentSetRow isEqualToString:[self selectedRowString]])
                [self.imageView setImage:currentSetImg];
            
            [self.pendingChangeArray removeLastObject];
            [self.changeDelegate contentDidChangeState:self];
        }];
        [self.undoManager setActionName:[NSString stringWithFormat:@"Cleared %@", str]];
        
        [self.currentExtensions setObject:@"" forKey:str];
        [self.loadedImages removeObjectForKey:str];
        
        SOEncodedKeyPath tRemovePath = {
            .rootKey = &kSOIconsSystemDict,
            .components = @[str]
        };
        
        [self setPendingIconResourceChangeForKeypath:&tRemovePath
                                            resource:nil
                                            filename:nil
                                                note:[NSString stringWithFormat:@"Cleared extension image for %@",
                                                      str]];
        
        return;
    }
    
    NSString *currentSetStr = [self.currentExtensions objectForKey:str];
    NSImage  *currentSetImg = [self.loadedImages objectForKey:str];
    NSString *newFilename   = [sender draggedFileURL].lastPathComponent;
    NSString *currentSetRow = [self selectedRowString];
    
    [self.undoManager registerUndoWithTarget:self
                                     handler:^(SOSystemIconReplacementPageController *c){
        [self.currentExtensions setObject:currentSetStr forKey:str];
        [self.loadedImages setObject:currentSetImg forKey:str];
        
        if ([currentSetRow isEqualToString:[self selectedRowString]])
            [self.imageView setImage:currentSetImg];
        
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
    }];
    [self.undoManager setActionName:[NSString stringWithFormat:@"Set %@", str]];
    
    [self.currentExtensions setObject:newFilename forKey:str];
    
    if ([[newFilename pathExtension] isEqualToString:@"sicon"]){
        sender.image = [SOSiconBundle NSImageOrNilForURL:sender.draggedFileURL];
    }
    
    [self.loadedImages setObject:sender.image forKey:str];
    
    SOEncodedKeyPath tSetPath = {
        .rootKey = &kSOIconsSystemDict,
        .components = @[str]
    };
    
    [self setPendingIconResourceChangeForKeypath:&tSetPath
                                        resource:[NSData dataWithContentsOfURL:[sender draggedFileURL]]
                                        filename:newFilename
                                            note:[NSString stringWithFormat:@"Set extension image for %@ to %@",
                                                  str, newFilename]];
    
    return;
}

- (void)objectWithKey:(id)aKey didGetSetTo:(id)anObject {

}

- (void)willRemoveObject:(id)anObject forKey:(id)aKey { 
    [self.undoManager registerUndoWithTarget:self
                                     handler:^(SOSystemIconReplacementPageController *c){
        
        [self.currentExtensions setObject:anObject forKey:aKey];
        [self.pendingChangeArray removeLastObject];
        [self.changeDelegate contentDidChangeState:self];
        [self.extensionTable reloadData];
    }];
    [self.undoManager setActionName:[NSString stringWithFormat:@"Cleared entry %@", aKey]];
}

- (void)didRemoveObjectWithKey:(id)aKey{
    SOEncodedKeyPath tRemovePath = {
        .rootKey = &kSOIconsSystemDict,
        .components = @[aKey]
    };
    
    [self setPendingIconResourceChangeForKeypath:&tRemovePath
                                        resource:nil
                                        filename:nil
                                            note:[NSString stringWithFormat:@"Cleared extension option for %@",
                                                  aKey]];
}

- (NSString *)selectedRowString{
    if ([[self.currentExtensions allKeys] count] < 1)
        return nil;
    
    NSArray<NSString *> *extensions = [[self.currentExtensions allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    return extensions[[self.extensionTable selectedRow]];
}
@end


