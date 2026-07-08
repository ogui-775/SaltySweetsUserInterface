//Created by Salty on 6/26/26.

#import "SOSystemSettingsIconReplacementPageController.h"

@interface SOSystemSettingsIconReplacementPageController ()
@property (strong, nonatomic) const NSSet<NSString *> *allSettingsIcons;
@property (strong, nonatomic) SOObservableDictionary *mutableDict;
@end

@implementation SOSystemSettingsIconReplacementPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    self.allSettingsIcons = [NSSet setWithArray:(NSArray *)allSettingsIcons()];
    self.mutableDict = [[SOObservableDictionary alloc] initWithDelegate:self];
    
    NSMutableSet<NSString *> *newGoldenGateGraphicIcons = [NSMutableSet set];
    [UTType _enumerateAllDeclaredTypesUsingBlock:^(UTType *type) {
        if ([type.identifier containsString:@"com.apple.graphic-icon"])
            [newGoldenGateGraphicIcons addObject:type.identifier];
    }];
    
    self.allSettingsIcons = [self.allSettingsIcons setByAddingObjectsFromSet:newGoldenGateGraphicIcons];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    NSDictionary *packExtensions = [self getBaselineForEncodedKey:&kSOIconsExtensionDict];
    
    for (NSString *key in [packExtensions allKeys]){
        NSString *value = [packExtensions objectForKey:key];
        
        [self.mutableDict setObject:value forKey:key];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.allSettingsIcons count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [[self.allSettingsIcons.allObjects[row]
             stringByReplacingOccurrencesOfString:@"com.apple."
                                       withString:@""]
                stringByReplacingOccurrencesOfString:@"graphic-icon."
                                          withString:@""];
}

- (IBAction)tableViewWasClicked:(NSTableView *)sender{
    NSInteger selectedRow = [sender selectedRow];
    
    if (selectedRow == -1)
        return;
    
    NSString *selectedValueOrNil = self.allSettingsIcons.allObjects[selectedRow];
    
    if (!selectedValueOrNil)
        return;
    
    const SOEncodedKeyPath tExtKey = {
        .rootKey = &kSOIconsExtensionDict,
        .components = @[selectedValueOrNil]
    };
    
    self.imageWell.image = [self loadImageForEncodedKeypath:&tExtKey];
}

- (IBAction)imageWellWasInteractedWith:(SODragAwareImageView *)sender{
    NSURL *itemURL = sender.draggedFileURL;
    NSString *filename = [itemURL lastPathComponent];
    NSInteger selectedRow = [self.table selectedRow];
    
    if (selectedRow == -1)
        return;
    
    NSString *selectedValueOrNil = self.allSettingsIcons.allObjects[selectedRow];

    if (!selectedValueOrNil)
        return;
    
    if (!sender.image && [[itemURL pathExtension] isEqualToString:@"sicon"]){
        sender.image = [SOSiconBundle NSImageOrNilForURL:itemURL];
    }
    
    const SOEncodedKeyPath tPrefKey = {
        .rootKey = &kSOIconsExtensionDict,
        .components = @[selectedValueOrNil]
    };
    
    if (sender.image){
        [self.mutableDict setObject:filename forKey:selectedValueOrNil];
        
        [self setPendingIconResourceChangeForKeypath:&tPrefKey
                                            resource:[NSData dataWithContentsOfURL:sender.draggedFileURL]
                                            filename:filename
                                                note:[NSString stringWithFormat:@"Set %@ to %@",
                                                      selectedValueOrNil, filename]];
        
        return;
    }
    
    [self.mutableDict removeObjectForKey:selectedValueOrNil];
    
    [self setPendingIconResourceChangeForKeypath:&tPrefKey
                                        resource:nil
                                        filename:nil
                                            note:[NSString stringWithFormat:@"Cleared %@",
                                                  selectedValueOrNil]];
}

- (void)objectWithKey:(id)aKey didGetSetTo:(id)anObject { 
}

- (void)willRemoveObject:(id)anObject forKey:(id)aKey {
}

- (void)didRemoveObjectWithKey:(id)aKey{
}

@end
