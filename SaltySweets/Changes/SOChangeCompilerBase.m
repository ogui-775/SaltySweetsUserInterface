//Created by Salty on 7/14/26.

#import "SOChangeCompilerBase.h"

@implementation SOChangeCompilerBase
- (NSString *)describeChange:(SOChange *)change{
    if (change.plistValue)
        return [NSString stringWithFormat:@"Modifying settings for %@...",
                change.plistKey->key];
    if (change.resourceFilename)
        return [NSString stringWithFormat:@"Writing %@...", change.resourceFilename];
    
    if (!change.resourceFilename && !change.resourceData)
        return [NSString stringWithFormat:@"Removing file for %@...",
                change.plistKeyPath->components.lastObject];
    
    if ([change isKindOfClass:[SOKeyChange class]])
        return [NSString stringWithFormat:@"Rewriting key %@...",
                [(SOKeyChange *)change originalEncodedKeypath]->rootKey];
    
    return @"ERROR_NO_DESCRIPTION_AVAILABLE";
}



- (void)populateIconDictionary:(NSMutableDictionary *)dict withChange:(SOChange *)change purgeCollection:(NSMutableArray<NSString *> *)purgeCollection{
    if ([change isKindOfClass:SOKeyChange.class]){
        SOKeyChange *keyChange = (SOKeyChange *)change;
        
        NSString *oldKey = [keyChange.originalEncodedKeypath->components lastObject];
        NSString *newKey = [keyChange.replacementEncodedKeypath->components lastObject];
        
        NSMutableDictionary *rootDict = [dict objectForKey:keyChange.originalEncodedKeypath->rootKey->key];
        
        NSString *orig = [rootDict objectForKey:oldKey];
        [rootDict removeObjectForKey:oldKey];
        [rootDict setObject:orig forKey:newKey];
        return;;
    }
    
    if (!change.plistKeyPath){
        NSString * baselineValue = [dict objectForKey:change.plistKey->key];
        
        if (change.plistValue){
            [dict setObject:change.plistValue forKey:change.plistKey->key];
            return;
        }
        else
            [dict removeObjectForKey:change.plistKey->key];
        
        __block NSUInteger countOfBaseline = 0;
        
        [dict enumerateKeysAndObjectsUsingBlock:^(NSString * key,
                                                   id obj,
                                                   BOOL * stop) {
            if (![obj isKindOfClass:NSString.class])
                return;
            
            if ([obj isEqualToString:baselineValue])
                countOfBaseline++;
        }];
        
        if (baselineValue && countOfBaseline < 1)
            [purgeCollection addObject:baselineValue];
        
        return;
    }
    
    NSMutableDictionary *rootDict = [dict objectForKey:change.plistKey->key];
    
    if (!rootDict)
        return;
    
    if (change.plistValue){
        for (NSString *component in change.plistKeyPath->components){
            rootDict = rootDict[component];
        }
        
        [rootDict setObject:change.plistValue forKey:change.plistKeyPath->components.lastObject];
        return;
    }
    
    NSString *baselineValue = [rootDict objectForKey:change.plistKeyPath->components.lastObject];
    
    if (change.resourceFilename)
        [rootDict setObject:change.resourceFilename forKey:change.plistKeyPath->components.lastObject];
    else
        [rootDict removeObjectForKey:change.plistKeyPath->components.lastObject];

    __block NSUInteger countOfBaseline = 0;
    
    [rootDict enumerateKeysAndObjectsUsingBlock:^(NSString * key,
                                                   NSString * obj,
                                                   BOOL * stop) {
        if ([obj isEqualToString:baselineValue])
            countOfBaseline++;
    }];
    
    if (baselineValue && countOfBaseline < 1)
        [purgeCollection addObject:baselineValue];
}



- (BOOL)writeFileFromChange:(SOChange *)change toBundle:(SONSBundle *)bundle{
    if (!change.resourceData)
        return NO;
    
    NSError * error;

    if (!change.plistKeyPath || change.iconChange){
        [bundle createFile:change.resourceData
                     named:change.resourceFilename
                 withError:&error];
    } else {
        [bundle createFile:change.resourceData
                     named:change.resourceFilename
                 withError:&error
        withEncodedKeyPath:change.plistKeyPath];
    }
    
    if (error)
        return NO;
        
    return YES;
}

- (void)purgeFilesIfNeededWithRelativePaths:(NSMutableArray<NSString *> *)purgeFileRelativePathCollection fromBundle:(SONSBundle *)bundle{
    if (purgeFileRelativePathCollection.count < 1)
        return;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *baseResourceURL = [bundle resourceURL];
    
    for (NSString *relativePath in purgeFileRelativePathCollection){
        NSURL *relativeURL = [baseResourceURL URLByAppendingPathComponent:relativePath];
        [fm removeItemAtURL:relativeURL error:nil];
    }
    
    [purgeFileRelativePathCollection removeAllObjects];
}

- (void)listChangesToIconBundle:(SOSiconPackBundle *)bundle
                        changes:(NSArray<SOChange *> *)changes
                     completion:(void (^)(NSModalResponse response, NSArray<SOChange *> *approvedChanges))completion{
    NSWindow * parentWindow = NSApp.mainWindow;
    self.iconThemeConfirmSheet = [[SOChangeConfirmSheetController alloc] init];
    [self.iconThemeConfirmSheet window];
    
    NSMutableArray<SOChange *> *iconChanges = [NSMutableArray array];
    
    for (SOChange *c in changes){
        if (c.iconChange)
            [iconChanges addObject:c];
    }
    
    if (iconChanges.count < 1){
        completion(NSModalResponseOK, nil);
        return;
    }
    
    [self.iconThemeConfirmSheet supplyChanges:iconChanges];
    
    [parentWindow beginSheet:self.iconThemeConfirmSheet.window
           completionHandler:^(NSModalResponse returnCode) {
        completion(returnCode, self.iconThemeConfirmSheet.internalChangeArray);
    }];
}

- (void)listChangesToDockBundle:(SODockThemeBundle *)bundle
                        changes:(NSArray<SOChange *> *)changes
                     completion:(void (^)(NSModalResponse response, NSArray<SOChange *> *approvedChanges))completion{
    self.dockThemeConfirmSheet = [[SOChangeConfirmSheetController alloc] init];
    [self.dockThemeConfirmSheet window];
    
    NSMutableArray<SOChange *> *dockChanges = [NSMutableArray array];
    
    for (SOChange *c in changes){
        if (!c.iconChange)
            [dockChanges addObject:c];
    }
    
    if (dockChanges.count < 1){
        completion(NSModalResponseOK, nil);
        return;
    }
    
    [self.dockThemeConfirmSheet supplyChanges:dockChanges];

    [NSApp.mainWindow beginSheet:self.dockThemeConfirmSheet.window
               completionHandler:^(NSModalResponse returnCode) {

        if (returnCode != NSModalResponseOK) {
            completion(returnCode, nil);
            return;
        }
        
        completion(returnCode, self.dockThemeConfirmSheet.internalChangeArray);
    }];
}

- (void)applyDockChanges:(NSArray<SOChange *> *)changes
                toBundle:(SODockThemeBundle *)bundle
            withBaseline:(NSMutableDictionary *)baseline
              completion:(void (^)(BOOL))completion{
    NSMutableDictionary * settingsPlist = [NSMutableDictionary new];
    NSMutableDictionary * resourcePlist = [NSMutableDictionary new];

    // Populate baseline values
    for (NSString * key in baseline) {

        const SOEncodedKey * encodedKey = NULL;

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
        else if (encodedKey->destinationFlags == SODestinationResource)
            targetDict = resourcePlist;

        targetDict[key] = baseline[key];
    }

    NSMutableArray<NSString *> * purgeCollection = [NSMutableArray new];

    [self.class populateDictionary:settingsPlist
                    forDestination:SODestinationTheme
                       withChanges:changes
                    purgeCollector:purgeCollection];

    [self.class populateDictionary:resourcePlist
                    forDestination:SODestinationResource
                       withChanges:changes
                    purgeCollector:purgeCollection];

    NSError * error = nil;
    
    SODockThemeBundle *themeBundle = [[SOAtomicAccessPoint sharedInstance] currentDockThemeBundle];

    [themeBundle writeToThemePlist:settingsPlist
                         withError:&error];
    
    if (error) {
        NSLog(@"Theme plist write error: %@", error);
        [SOErrorAlert runModalTerminatingError:error.localizedDescription];
        completion(NO);
        return;
    }

    [themeBundle writeToResourceBomPlist:resourcePlist
                               withError:&error];
    
    if (error) {
        NSLog(@"Resource plist write error: %@", error);
        [SOErrorAlert runModalTerminatingError:error.localizedDescription];
        completion(NO);
        return;
    }

    [self purgeFilesIfNeededWithRelativePaths:purgeCollection
                                   fromBundle:themeBundle];

    for (SOChange * change in changes) {
        if (change.resourceData && !change.iconChange) {
            [self writeFileFromChange:change
                             toBundle:themeBundle];
        }
    }

    BOOL success = YES;

    if ([SOSignatures authoringKeypairExists]) {
        success = [SOSignatures signThemeBundle:themeBundle];
    }

    completion(success);
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

- (NSMutableDictionary *)recursivelyBuildDictionary:(const SOEncodedKey)encodedKeyWithDict{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < encodedKeyWithDict.dictionaryKeyCount; i++){
        const SOEncodedKey key = encodedKeyWithDict.dictionaryKeys[i];
        if (key.dictionaryKeyCount > 0)
            [dict setObject:[self recursivelyBuildDictionary:key] forKey:key.key];
        else
            [dict setObject:key.defaultValue forKey:key.key];
    }
    
    return dict;
}
@end
