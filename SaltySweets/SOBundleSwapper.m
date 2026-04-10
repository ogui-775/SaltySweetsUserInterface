//Created by Salty on 3/9/26.

#import "SOBundleSwapper.h"

@implementation SOBundleSwapper

- (IBAction)createNewTheme:(id)sender{
    SOChangeCompiler * compiler = [[SOChangeCompiler alloc] init];
    
    NSMutableDictionary * nonfinal = [NSMutableDictionary new];

    for (int i = 0; i < kSODockAllKeysCount; i++){
        SOEncodedKey key = kSODockAllKeys[i];
        NSString * keyName = key.key;

        if (key.valueEncoding == SOValueEncodingNSDictionary &&
            ![key.key isEqualToString:kSODockResourceHashToFilename.key]) {
            nonfinal[keyName] = [self.class baselineFromEncodedKey:key];
        } else if (key.key == kSODockResourceHashToFilename.key) {
            nonfinal[keyName] = [NSMutableDictionary new];
        } else {
            nonfinal[keyName] = key.defaultValue;
        }
    }
    
    [compiler generateThemeBundleWithBaseline:[nonfinal mutableCopy]
                                      changes:@[]
                                     asUpdate:NO
                                   completion:^(BOOL success) {

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

- (IBAction)swapTheme:(id)sender{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowedContentTypes = @[UTTypeBundle];
    panel.allowsMultipleSelection = NO;
    panel.directoryURL = [NSURL fileURLWithPath:[AppDelegate bundleDir]];
    panel.canCreateDirectories = NO;

    [panel beginSheetModalForWindow:[SOViewPane defaultInstance].view.window
                  completionHandler:^(NSModalResponse result) {

        if (result != NSModalResponseOK)
            return;

        NSURL * fileURL = panel.URL;
        NSString * fileName = [fileURL lastPathComponent];
        
        [AppDelegate setCurrentThemeBundleName:fileName];
        
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

@end
