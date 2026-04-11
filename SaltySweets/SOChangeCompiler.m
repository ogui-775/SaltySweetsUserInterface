//Created by Salty on 2/8/26.

#import "SOChangeCompiler.h"

@implementation SOChangeCompiler

- (void)generateThemeBundleWithBaseline:(NSDictionary *)baseline
                                changes:(NSArray<SOChange *> *)changeArray
                               asUpdate:(BOOL)update
                             completion:(void (^)(BOOL success))completion
{
    NSFileManager * fm = [NSFileManager defaultManager];
    NSWindow * parentWindow = NSApp.mainWindow;

    void (^presentConfirmSheet)(NSBundle * themeBundle) = ^(NSBundle * themeBundle) {

        self.confirmSheet =
            [[SOChangeConfirmSheetController alloc] init];
        [self.confirmSheet window];
        
        NSMutableArray<SOChange *> * nonIconChanges = [NSMutableArray new];
        for (SOChange * c in changeArray){
            if (!c.iconChange)
                [nonIconChanges addObject:c];
        }
        
        if (nonIconChanges.count == 0){
            completion(YES);
            return;
        }
        
        [self.confirmSheet supplyChanges:nonIconChanges];

        [parentWindow beginSheet:self.confirmSheet.window
               completionHandler:^(NSModalResponse returnCode) {
            
            NSArray * newChangeArray = self.confirmSheet.internalChangeArray;

            if (returnCode != NSModalResponseOK) {
                completion(NO);
                return;
            }

            NSMutableDictionary * settingsPlist = [NSMutableDictionary new];
            NSMutableDictionary * resourcePlist = [NSMutableDictionary new];

            // Populate baseline values
            for (NSString *key in baseline) {

                const SOEncodedKey *encodedKey = NULL;

                for (NSUInteger i = 0; i < kSODockAllKeysCount; i++) {
                    if ([kSODockAllKeys[i].key isEqualToString:key]) {
                        encodedKey = &kSODockAllKeys[i];
                        break;
                    }
                }

                if (!encodedKey) continue;

                NSMutableDictionary * targetDict = nil;
                
                if (encodedKey->destinationFlags == SODestinationTheme)
                    targetDict = settingsPlist;
                else if (encodedKey->destinationFlags != SODestinationIcons)
                    targetDict = resourcePlist;

                targetDict[key] = baseline[key];
            }

            // Ensure author name only when creating new bundle
            if (!update &&
                [settingsPlist[kSODockThemePlainAuthorName.key] isEqualToString:@""]) {

                settingsPlist[kSODockThemePlainAuthorName.key] =
                    [AppDelegate appSetAuthorName];
            }

            NSMutableArray<NSString *> * purgeCollection = [NSMutableArray new];

            [self.class populateDictionary:settingsPlist
                            forDestination:SODestinationTheme
                               withChanges:newChangeArray
                            purgeCollector:purgeCollection];

            [self.class populateDictionary:resourcePlist
                            forDestination:SODestinationResource
                               withChanges:newChangeArray
                            purgeCollector:purgeCollection];

            NSError * error = nil;

            NSURL * themePlistURL =
                [NSURL fileURLWithPath:
                 [themeBundle.resourcePath stringByAppendingPathComponent:@"theme.plist"]];

            [settingsPlist writeToURL:themePlistURL error:&error];
            if (error) {
                NSLog(@"Theme plist write error: %@", error);
                completion(NO);
                return;
            }

            NSURL * resourcePlistURL =
                [NSURL fileURLWithPath:
                 [themeBundle.resourcePath stringByAppendingPathComponent:
                  @"resourcebom.plist"]];

            [resourcePlist writeToURL:resourcePlistURL error:&error];
            if (error) {
                NSLog(@"Resource plist write error: %@", error);
                completion(NO);
                return;
            }
            
            [self.class purgeFilesIfNeeded:purgeCollection];

            for (SOChange * change in newChangeArray) {
                if (change.resourceData && !change.iconChange) {
                    [self.class writeFileFromChange:change toBundle:themeBundle];
                }
            }

            BOOL success = YES;

            if ([SOSignatures authoringKeypairExists]) {
                success = [SOSignatures signThemeBundle:themeBundle];
            }

            completion(success);
        }];
    };

    if (!update) {
        self.createSheet =
            [[SOThemeCreationSheetController alloc] init];

        [parentWindow beginSheet:self.createSheet.window
               completionHandler:^(NSModalResponse returnCode) {

            if (returnCode != NSModalResponseOK) {
                completion(NO);
                return;
            }

            NSString * newThemeName =
                [[self.createSheet.nameBox stringValue]
                 stringByAppendingString:@".bundle"];

            NSURL * newThemeURL =
                [NSURL fileURLWithPath:
                 [[AppDelegate bundleDir]
                  stringByAppendingPathComponent:newThemeName]];

            NSError * error = nil;

            [fm copyItemAtURL:
             [[NSBundle mainBundle] URLForResource:@"Template.bundle" withExtension:@""]
                        toURL:newThemeURL
                        error:&error];

            if (error) {
                NSLog(@"Bundle copy error: %@", error);
                completion(NO);
                return;
            }

            [[NSWorkspace sharedWorkspace]
                setIcon:[NSImage imageNamed:@"CompiledThemeIcon"]
                forFile:newThemeURL.path
                options:0];

            [AppDelegate setCurrentThemeBundleName:newThemeName];

            NSBundle * themeBundle =
                [NSBundle bundleWithURL:newThemeURL];

            presentConfirmSheet(themeBundle);
        }];

    } else {
        NSString * existingName = [AppDelegate currentThemeBundleName];
        NSURL * existingURL =
            [NSURL fileURLWithPath:
             [[AppDelegate bundleDir]
              stringByAppendingPathComponent:existingName]];

        NSBundle * themeBundle =
            [NSBundle bundleWithURL:existingURL];

        presentConfirmSheet(themeBundle);
    }
}

+ (void)populateDictionary:(NSMutableDictionary *)dict
            forDestination:(SODestinationFlags)destination
               withChanges:(NSArray<SOChange *> *)changes
            purgeCollector:(NSMutableArray<NSString *> *)purgeFileRelativePathCollection{
    
    NSString * rootKey;
    
    for (SOChange * change in changes){
        rootKey = change.plistKey->key;
        NSMutableDictionary * sub = dict[rootKey];
        
        if (!sub)
            continue;
        
        if (change.plistKeyPath && change.changeType == kSOChangeTypePlist){
            NSString * nextKey      = @"";
            for (int i = 0; i < change.plistKeyPath->components.count; i++){
                nextKey = change.plistKeyPath->components[i];
                if (i != change.plistKeyPath->components.count - 1)
                    sub = sub[nextKey];
            }
            
            sub[nextKey] = change.plistValue;
        }
        else if (change.plistKeyPath){
            NSString * relativePath = rootKey;
            NSString * nextKey      = @"";
            for (int i = 0; i < change.plistKeyPath->components.count; i++){
                nextKey = change.plistKeyPath->components[i];
                relativePath = [relativePath stringByAppendingPathComponent:nextKey];
                if (i != change.plistKeyPath->components.count - 1)
                    sub = sub[nextKey];
            }
            relativePath = [relativePath stringByAppendingPathExtension:[change.resourceFilename pathExtension]];
            if (change.changeType == kSOChangeTypeResource){
                NSString * hashToClear = sub[nextKey];
                sub[nextKey] = change.sha256;
                if ([dict[kSODockResourceHashToFilename.key] valueForKey:hashToClear]){
                    if (![hashToClear isEqualToString:kSODockResourceNotProvided])
                        [purgeFileRelativePathCollection addObject:relativePath];
                    
                    [dict[kSODockResourceHashToFilename.key] removeObjectForKey:hashToClear];
                    
                }
                
                if (change.sha256.length > 0)
                    [dict[kSODockResourceHashToFilename.key] setObject:relativePath forKey:change.sha256];
                
            } else {
                sub[nextKey] = change.plistValue;
            }
        } else if (change.changeType == kSOChangeTypeResource && !change.plistKeyPath){
            NSString * relativePath = [rootKey stringByAppendingPathComponent:change.resourceFilename];
            NSString * hashToClear  = dict[rootKey];
            
            dict[rootKey] = change.sha256;
            if ([dict[kSODockResourceHashToFilename.key] valueForKey:hashToClear]){
                if (![hashToClear isEqualToString:kSODockResourceNotProvided])
                    [purgeFileRelativePathCollection addObject:relativePath];
                
                [dict[kSODockResourceHashToFilename.key] removeObjectForKey:hashToClear];
            }
            
            if (change.sha256.length > 0)
                [dict[kSODockResourceHashToFilename.key] setObject:relativePath forKey:change.sha256];
            
        } else {
            [dict setObject:change.plistValue forKey:change.plistKey->key];
        }
    }
}

- (void)updateIconFolderWithBaseline:(NSDictionary *)baseline
                             changes:(NSArray<SOChange *> *)changeArray
                          completion:(void (^)(BOOL))completion{
    NSWindow * parentWindow = NSApp.mainWindow;
    
    self.confirmSheet =
    [[SOChangeConfirmSheetController alloc] init];
    [self.confirmSheet window];
    
    NSMutableArray<SOChange *> * iconChanges = [NSMutableArray new];
    for (SOChange * c in changeArray){
        if (c.iconChange)
            [iconChanges addObject:c];
    }
    
    [self.confirmSheet supplyChanges:iconChanges];
    
    if (iconChanges.count == 0){
        completion(YES);
        return;
    }

    [parentWindow beginSheet:self.confirmSheet.window
           completionHandler:^(NSModalResponse returnCode){
        
        NSArray * newChangeArray = self.confirmSheet.internalChangeArray;
        
        NSMutableDictionary * resourcePlist = [NSMutableDictionary new];
        
        if (returnCode != NSModalResponseOK) {
            completion(NO);
            return;
        }
        
        for (NSString * key in baseline) {

            const SOEncodedKey * encodedKey = NULL;

            for (NSUInteger i = 0; i < kSOIconAllKeysCount; i++) {
                if ([kSOIconAllKeys[i].key isEqualToString:key]) {
                    encodedKey = &kSOIconAllKeys[i];
                    break;
                }
            }

            if (!encodedKey) continue;

            resourcePlist[key] = baseline[key];
        }
        
        NSMutableArray<NSString *> * purgeCollection = [NSMutableArray new];
        
        [self.class populateIconDictionary:resourcePlist
                               withChanges:iconChanges
                           purgeCollection:purgeCollection];
        
        NSError * error = nil;
        
        NSURL * themePlistURL =
            [NSURL fileURLWithPath:[[AppDelegate iconsDir] stringByAppendingPathComponent:@"iconsettings.plist"]];
        
        [resourcePlist writeToURL:themePlistURL error:&error];
        if (error){
            NSLog(@"%@", error);
            completion(NO);
            return;
        }
        
        [self.class purgeIconsIfNeeded:purgeCollection];
        
        BOOL success = YES;
        
        for (SOChange * change in newChangeArray){
            if (change.resourceData && change.iconChange){
                [self.class writeIconFromChange:change];
            }
        }
        
        completion(success);
    }];
}

+ (void)populateIconDictionary:(NSMutableDictionary *)dict
                   withChanges:(NSArray<SOChange *> *)changes
               purgeCollection:(NSMutableArray<NSString *> *)purgeCollection{
    for (SOChange * change in changes){
        if (!change.plistKeyPath){
            NSString * baselineValue = [dict objectForKey:change.plistKey->key];
            
            if (change.plistValue)
                [dict setObject:change.plistValue forKey:change.plistKey->key];
            else
                [dict removeObjectForKey:change.plistKey->key];
            
            if (baselineValue)
                [purgeCollection addObject:baselineValue];
            
            continue;
        }
        
        NSMutableDictionary * rootDict = [dict objectForKey:change.plistKey->key];
        NSMutableDictionary * sub = rootDict[change.plistKeyPath->components[0]];
        
        if (!rootDict)
            continue;
        
        for (int i = 0; i < change.plistKeyPath->components.count - 1; i++){
            sub = [sub objectForKey:change.plistKeyPath->components[i]];
        }
        
        if (!sub)
            continue;
        
        NSString * baselineValue = [sub objectForKey:change.plistKeyPath->components.lastObject];
        
        if (change.resourceFilename)
            [dict setObject:change.resourceFilename forKey:change.plistKeyPath->components.lastObject];
        else
            [dict removeObjectForKey:change.plistKeyPath->components.lastObject];
        
        if (baselineValue)
            [purgeCollection addObject:baselineValue];
        
        continue;
    }
}

+ (BOOL)writeIconFromChange:(SOChange *)change{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    if (!change.resourceData)
        return NO;
    
    NSString * baseDir = [AppDelegate iconsDir];
    
    return [fm createFileAtPath:[baseDir stringByAppendingPathComponent:change.resourceFilename]
                       contents:change.resourceData
                     attributes:nil];
}

+ (BOOL)writeFileFromChange:(SOChange *)change toBundle:(NSBundle *)bundle{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    if (!change.resourceData)
        return NO;
    
    NSError  * error;
    NSString * baseResourceDir = [bundle resourcePath];
    NSString * relativePath = change.plistKey->key;
    
    if (change.plistKeyPath)
        for (int i = 0; i < change.plistKeyPath->components.count - 1; i++){
            relativePath = [relativePath stringByAppendingPathComponent:change.plistKeyPath->components[i]];
        }
    
    if (![fm fileExistsAtPath:[baseResourceDir stringByAppendingPathComponent:relativePath] isDirectory:nil]){
        [fm createDirectoryAtPath:[baseResourceDir stringByAppendingPathComponent:relativePath]
      withIntermediateDirectories:YES
                       attributes:nil
                            error:&error];
        if (error)
            return NO;
    }

    relativePath = [relativePath stringByAppendingPathComponent:change.resourceFilename];
    
    return [fm createFileAtPath:[baseResourceDir stringByAppendingPathComponent:relativePath]
                       contents:change.resourceData
                     attributes:nil];
}

+ (void)purgeFilesIfNeeded:(NSMutableArray<NSString *> *)purgeFileRelativePathCollection{
    if (purgeFileRelativePathCollection.count == 0 || ![AppDelegate currentThemeBundle])
        return;
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSBundle * bundle = [AppDelegate currentThemeBundle];
    
    for (NSString * purgePath in purgeFileRelativePathCollection){
        [fm removeItemAtPath:[[bundle resourcePath] stringByAppendingPathComponent:purgePath] error:nil];
    }
    
    [purgeFileRelativePathCollection removeAllObjects];
}

+ (void)purgeIconsIfNeeded:(NSMutableArray<NSString *> *)purgeIconPathCollection{
    if (purgeIconPathCollection.count == 0)
        return;
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * iconPath = [AppDelegate iconsDir];
    
    for (NSString * filename in purgeIconPathCollection){
        [fm removeItemAtPath:[iconPath stringByAppendingPathComponent:filename] error:nil];
    }
    
    [purgeIconPathCollection removeAllObjects];
}
@end
