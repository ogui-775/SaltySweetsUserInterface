//Created by Salty on 2/11/26.

#import "SOBaseline.h"

@implementation SOBaseline

+ (NSDictionary *)retriveOrCreateBaseline{
    NSMutableDictionary * nonfinal = [NSMutableDictionary new];
    NSString * currentThemeBundle = [AppDelegate currentThemeBundleName];

    if ([currentThemeBundle isEqualToString:kSODockResourceNotProvided]){
        for (int i = 0; i < kSODockAllKeysCount; i++){
            SOEncodedKey key = kSODockAllKeys[i];
            NSString * keyName = key.key;

            if (key.valueEncoding == SOValueEncodingNSDictionary &&
                ![key.key isEqualToString:kSODockResourceHashToFilename.key]) {
                nonfinal[keyName] = [self baselineFromEncodedKey:key];
            } else if (key.key == kSODockResourceHashToFilename.key) {
                nonfinal[keyName] = [NSMutableDictionary new];
            } else {
                nonfinal[keyName] = key.defaultValue;
            }
        }
    } else {
        NSMutableDictionary * themePlist =
            [[AppDelegate currentDockThemeBundle] themePlist];
        NSMutableDictionary * resourceBom =
            [[AppDelegate currentDockThemeBundle] resourceBomPlist];
        
        if (!themePlist || !resourceBom)
            [SOBaseline bailout];

        for (int i = 0; i < kSODockAllKeysCount; i++){
            SOEncodedKey key = kSODockAllKeys[i];
            NSString * keyName = key.key;
            
            if (key.destinationFlags == SODestinationTheme){
                nonfinal[keyName] = themePlist[keyName] ?: key.defaultValue;
            } else {
                nonfinal[keyName] = resourceBom[keyName] ?: key.defaultValue;
            }
        }
    }
    
    NSString * currentIconPack = [AppDelegate currentIconPackBundleName];
    
    if ([currentIconPack isEqualToString:kSODockResourceNotProvided]){
        for (int i = 0; i < kSOIconAllKeysCount; i++){
            SOEncodedKey key = kSOIconAllKeys[i];
            NSString * keyName = key.key;

            if (key.valueEncoding == SOValueEncodingNSDictionary){
                nonfinal[keyName] = [self baselineFromEncodedKey:key];
            } else {
                nonfinal[keyName] = key.defaultValue;
            }
        }
    } else {
        NSMutableDictionary * iconSettingsPlist =
            [[AppDelegate currentIconThemeBundle] iconSettingsPlist];

        if (!iconSettingsPlist)
            [SOBaseline bailout];

        for (int i = 0; i < kSOIconAllKeysCount; i++){
            SOEncodedKey key = kSOIconAllKeys[i];
            NSString * keyName = key.key;
            
            nonfinal[keyName] = iconSettingsPlist[keyName] ?: key.defaultValue;
        }
    }

    return [nonfinal mutableCopy];
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

+ (void)bailout{
    dispatch_async(dispatch_get_main_queue(), ^void{
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = @"Could not load theme.plist and/or resourcebom.plist from theme.\n\nCurrent theme will be cleared and the application will terminate.";
        alert.alertStyle = NSAlertStyleCritical;
        [alert addButtonWithTitle:@"Ok"];
        alert.buttons[0].keyEquivalent = @"\r";
        NSModalResponse response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            [AppDelegate setCurrentThemeBundleName:@""];
            [[NSApplication sharedApplication] terminate:self];
        }
    });
}
@end
