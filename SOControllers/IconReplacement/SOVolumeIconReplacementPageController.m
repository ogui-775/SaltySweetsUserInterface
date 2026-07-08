//Created by Salty on 7/5/26.

#import "SOVolumeIconReplacementPageController.h"

@interface SOVolumeIconReplacementPageController()
@property (strong) SOObservableDictionary *mutableDict;
@property (strong) NSArray<NSString *> *defaults;
@end

@implementation SOVolumeIconReplacementPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.mutableDict = [[SOObservableDictionary alloc] initWithDelegate:self];
    
    self.defaults = @[
        @"hdsk",
        @"Internal",
        @"savedSearch",
        @"srvr",
        @"asif",
        @"External"
    ];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    NSDictionary *packDict = [self getBaselineForEncodedKey:&kSOIconsFolderDict];
    
    for (NSString *key in [packDict allKeys]){
        NSString *value = [packDict objectForKey:key];
        
        if (![key containsString:@"."])
            [self.mutableDict setObject:value forKey:key];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [[self completeKeys] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [[self completeKeys] allObjects][row];
}

- (NSSet<NSString *> *)completeKeys{
    NSSet<NSString *> *completeKeys = [NSSet setWithArray:self.defaults];
    return [completeKeys setByAddingObjectsFromArray:[self.mutableDict allKeys]];
}

- (NSString *)selectedRowString{
    if ([self.tableView selectedRow] == -1)
        return nil;
    
    return [[self completeKeys] allObjects][[self.tableView selectedRow]];
}

- (IBAction)imageWellWasInteractedWith:(SODragAwareImageView *)sender{
    NSURL *draggedURL = sender.draggedFileURL;
    NSInteger selectedRow = [self.tableView selectedRow];
    
    if (selectedRow == -1) return;
    
    NSString *selectedItem = [[self completeKeys] allObjects][selectedRow];
    
    if (!selectedItem) return;
    
    if (!sender.image && [[draggedURL pathExtension] isEqualToString:@"sicon"]){
        sender.image = [SOSiconBundle NSImageOrNilForURL:draggedURL];
    }
    
    const SOEncodedKeyPath tReplace = {
        .rootKey = &kSOIconsFolderDict,
        .components = @[selectedItem]
    };
    
    if (!sender.image){
        [self setPendingIconResourceChangeForKeypath:&tReplace
                                            resource:nil
                                            filename:nil
                                                note:[NSString stringWithFormat:@"Cleared icon for %@",
                                                      selectedItem]];
    } else {
        [self setPendingIconResourceChangeForKeypath:&tReplace
                                            resource:[NSData dataWithContentsOfURL:draggedURL]
                                            filename:[draggedURL lastPathComponent]
                                                note:[NSString stringWithFormat:@"Set %@ to %@",
                                                      selectedItem, [draggedURL lastPathComponent]]];
    }
}

- (IBAction)tableViewWasClicked:(NSTableView *)sender{
    if ([self.tableView selectedRow] == -1){
        self.imageWell.image = nil;
        return;
    }
    
    const SOEncodedKeyPath tImage = {
        .rootKey = &kSOIconsFolderDict,
        .components = @[[self selectedRowString]]
    };
    
    for (SOChange *change in self.pendingChangeArray){
        NSArray<NSString *> *c = change.plistKeyPath->components;
        
        if ([c containsObject:[self selectedRowString]]){
            if (!change.resourceFilename){
                return;
            } else {
                self.imageWell.image = [[NSImage alloc] initWithData:change.resourceData];
                return;
            }
        }
    }
    
    self.imageWell.image = [self loadImageForEncodedKeypath:&tImage];
}

- (void)objectWithKey:(id)aKey didGetSetTo:(id)anObject {
}

- (void)willRemoveObject:(id)anObject forKey:(id)aKey { 
}
@end
