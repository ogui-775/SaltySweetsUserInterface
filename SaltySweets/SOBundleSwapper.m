//Created by Salty on 3/9/26.

#import "SOBundleSwapper.h"

@implementation SOBundleSwapper

- (IBAction)createNewTheme:(id)sender{
    SOSimpleDockChangeCompiler *compiler = [[SOSimpleDockChangeCompiler alloc] init];
    
    [compiler createNewThemeWithCompletionHandler:^(BOOL success) {
    }];
}

- (IBAction)swapTheme:(id)sender{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[@"bundle"];
    panel.allowsMultipleSelection = NO;
    panel.directoryURL = [NSURL fileURLWithPath:[[SOAtomicAccessPoint sharedInstance] dockThemeBundleDirectory]];
    panel.canCreateDirectories = NO;

    [panel beginSheetModalForWindow:[SOViewPane defaultInstance].view.window
                  completionHandler:^(NSModalResponse result) {

        if (result != NSModalResponseOK)
            return;

        NSURL * fileURL = panel.URL;
        NSString * fileName = [fileURL lastPathComponent];
        
        [[SOAtomicAccessPoint sharedInstance] setCurrentDockThemeBundleName:fileName];
        
        [[NSNotificationCenter defaultCenter]
            postNotificationName:SONotificationBaseClassUpdateBaseline
                          object:self];
        
        for (id<SOConfigurableContent> page in [SOViewPane defaultInstance].childViewControllers) {

            if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
                [page refreshOrLoadBaseline];

            if ([page respondsToSelector:@selector(purgePendingChanges)])
                [page purgePendingChanges];
        }
    }];
}

//welp where else would I put it...
- (IBAction)killDock:(id)sender{
    system("killall Dock");
    return;
}

- (IBAction)killFinder:(id)sender{
    system("killall Finder");
    return;
}

- (IBAction)killIconServer:(id)sender{
    system("killall icon-server");
    return;
}

- (IBAction)clearCaches:(id)sender{
    NSString *script = @"do shell script \"find /private/var/folders/ -name com.apple.dock.iconcache -delete; find /private/var/folders/ -name com.apple.iconservices -delete; rm -r /Library/Caches/com.apple.iconservices.store\" with administrator privileges";
    
    NSDictionary *error = nil;
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource:script];
    
    [as executeAndReturnError:&error];

    if (error) {
        NSLog(@"Error: %@", error);
    }
}

- (IBAction)unloadIconPack:(id)sender{
    [[SOAtomicAccessPoint sharedInstance] setCurrentIconPackBundleName:@""];
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:SONotificationBaseClassUpdateBaseline
                      object:self];
    
    for (id<SOConfigurableContent> page in [SOViewPane defaultInstance].childViewControllers) {

        if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
            [page refreshOrLoadBaseline];

        if ([page respondsToSelector:@selector(purgePendingChanges)])
            [page purgePendingChanges];
    }
    
    system("killall Finder");
    system("killall Dock");
}

- (IBAction)unloadDockTheme:(id)sender{
    [[SOAtomicAccessPoint sharedInstance] setCurrentDockThemeBundleName:@""];
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:SONotificationBaseClassUpdateBaseline
                      object:self];
    
    for (id<SOConfigurableContent> page in [SOViewPane defaultInstance].childViewControllers) {

        if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
            [page refreshOrLoadBaseline];

        if ([page respondsToSelector:@selector(purgePendingChanges)])
            [page purgePendingChanges];
    }
    
    system("killall Dock");
}

+ (NSDictionary *)baselineFromEncodedKey:(SOEncodedKey)key {
    NSMutableDictionary * dict = [NSMutableDictionary new];

    if (key.valueEncoding == SOValueEncodingNSDictionary && key.dictionaryKeyCount > 0) {
        for (NSUInteger i = 0; i < key.dictionaryKeyCount; i++) {
            SOEncodedKey subKey = key.dictionaryKeys[i];
            dict[subKey.key] = [self baselineFromEncodedKey:subKey];
        }
        return [dict mutableCopy];
    } else {
        return key.defaultValue ?: [NSNull null];
    }
}

- (IBAction)createNewIconPack:(id)sender{
    SOSimpleIconChangeCompiler *iconCompiler = [[SOSimpleIconChangeCompiler alloc] init];
    [iconCompiler createNewPackWithCompletionHandler:^(BOOL success) {
    }];
}

- (IBAction)swapIconPack:(id)sender{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    panel.allowedContentTypes = @[[UTType typeWithIdentifier:@"com.saltysoft.siconpack"]];
    panel.allowsMultipleSelection = NO;
    panel.directoryURL = [NSURL fileURLWithPath:[[SOAtomicAccessPoint sharedInstance] iconPackBundleDirectory]];
    panel.canCreateDirectories = NO;

    [panel beginSheetModalForWindow:[SOViewPane defaultInstance].view.window
                  completionHandler:^(NSModalResponse result) {

        if (result != NSModalResponseOK)
            return;

        NSURL * fileURL = panel.URL;
        NSString * fileName = [fileURL lastPathComponent];
        
        [[SOAtomicAccessPoint sharedInstance] setCurrentIconPackBundleName:fileName];
        
        [[NSNotificationCenter defaultCenter]
            postNotificationName:SONotificationBaseClassUpdateBaseline
                          object:self];
        
        for (id<SOConfigurableContent> page in [SOViewPane defaultInstance].childViewControllers) {

            if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
                [page refreshOrLoadBaseline];

            if ([page respondsToSelector:@selector(purgePendingChanges)])
                [page purgePendingChanges];
            
            [(id<SOConfigurableContentDelegate>)[SOViewPane defaultInstance] contentDidChangeState:page];
        }
    }];
}
@end
