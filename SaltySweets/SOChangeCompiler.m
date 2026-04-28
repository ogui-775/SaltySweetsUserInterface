//Created by Salty on 2/8/26.

#import "SOChangeCompiler.h"

@implementation SOChangeCompiler

- (void)generateBundleWithBaseline:(NSDictionary *)baseline
                           changes:(NSArray<SOChange *> *)changes
                      shortCircuit:(SOShortCircuit)shortCir
                        completion:(void (^)(SOHandlerCompletionCodes))completion
{
    self.suppliedBaseline = baseline;
    [self ensureBundlesWithShortCircuit:shortCir
                         withCompletion:^(SODockThemeBundle *dockBundle,
                                        SOSiconPackBundle *iconBundle,
                                        BOOL aborted){
        if (aborted) {
            completion(kSOAbort);
            return;
        }
        
        [self processChangesWithDockBundle:dockBundle
                                iconBundle:iconBundle
                                   changes:changes
                                completion:completion];
    }];
}

- (void)ensureBundlesWithShortCircuit:(SOShortCircuit)shortCir withCompletion:(void (^)(SODockThemeBundle *, SOSiconPackBundle *, BOOL aborted))completion
{
    NSWindow *parentWindow = NSApp.mainWindow;
    
    SODockThemeBundle *dock = [AppDelegate currentDockThemeBundle];
    SOSiconPackBundle *icon = [AppDelegate currentIconThemeBundle];
    
    if (!dock || shortCir == kSODockShort) {
        self.dockThemeCreateSheet = [[SOThemeCreationSheetController alloc] initWithCreationType:@"Dock Theme"];

        [parentWindow beginSheet:self.dockThemeCreateSheet.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode != NSModalResponseOK) {
                completion(nil, nil, YES);
                return;
            }

            NSFileManager *fm = [NSFileManager defaultManager];
            NSString * newName = [self.dockThemeCreateSheet.nameBox.stringValue stringByAppendingString:@".bundle"];
            [AppDelegate setCurrentThemeBundleName:newName];

            NSError * error = nil;
            
            NSURL * newThemeURL =
                [NSURL fileURLWithPath:[[AppDelegate bundleDir] stringByAppendingPathComponent:newName]];

            [fm copyItemAtURL:
             [[NSBundle mainBundle] URLForResource:@"Template.bundle" withExtension:@""]
                        toURL:newThemeURL
                        error:&error];

            if (error) {
                NSLog(@"Bundle copy error: %@", error);
            }

            [[NSWorkspace sharedWorkspace]
                setIcon:[NSImage imageNamed:@"CompiledThemeIcon"]
                forFile:newThemeURL.path
                options:0];
            
            if (shortCir == kSODockShort){
                SOChange * authorWrite = [[SOChange alloc] init];
                authorWrite.plistKey = &kSODockThemePlainAuthorName;
                authorWrite.plistValue = [AppDelegate appSetAuthorName];
                authorWrite.changeType = kSOChangeTypePlist;
                
                [self applyDockChanges:@[authorWrite]
                              toBundle:[AppDelegate currentDockThemeBundle]
                            completion:^(BOOL done) {
                    completion(nil, nil, done);
                }];
                return;
            }

            [self ensureBundlesWithShortCircuit:shortCir withCompletion:completion];
        }];

        return;
    }

    if (!icon || shortCir == kSOIconShort) {
        self.iconThemeCreateSheet = [[SOThemeCreationSheetController alloc] initWithCreationType:@"Icon Pack"];

        [parentWindow beginSheet:self.iconThemeCreateSheet.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode != NSModalResponseOK) {
                completion(nil, nil, YES);
                return;
            }

            NSFileManager *fm = [NSFileManager defaultManager];
            NSString * newName = [self.iconThemeCreateSheet.nameBox.stringValue stringByAppendingString:@".siconpack"];
            [AppDelegate setCurrentIconPackBundleName:newName];

            NSError * error = nil;
            
            NSURL * newThemeURL =
                [NSURL fileURLWithPath:[[AppDelegate iconsDir] stringByAppendingPathComponent:newName]];

            [fm copyItemAtURL:
             [[NSBundle mainBundle] URLForResource:@"Template.siconpack" withExtension:@""]
                        toURL:newThemeURL
                        error:&error];

            if (error) {
                NSLog(@"Bundle copy error: %@", error);
            }

            [[NSWorkspace sharedWorkspace]
                setIcon:[NSImage imageNamed:@"siconpack_icon"]
                forFile:newThemeURL.path
                options:0];
            
            if (shortCir == kSOIconShort){
                [self applyIconChanges:@[]
                              toBundle:[AppDelegate currentIconThemeBundle]
                            completion:^(BOOL done) {
                    completion(nil, nil, done);
                }];
                return;
            }
            
            [self ensureBundlesWithShortCircuit:shortCir withCompletion:completion];
        }];

        return;
    }

    completion(dock, icon, NO);
}

- (void)processChangesWithDockBundle:(SODockThemeBundle *)dockBundle
                          iconBundle:(SOSiconPackBundle *)iconBundle
                             changes:(NSArray<SOChange *> *)changes
                          completion:(void (^)(SOHandlerCompletionCodes))completion
{
    BOOL hasDock = NO;
    BOOL hasIcon = NO;

    for (SOChange *c in changes) {
        if (c.iconChange) hasIcon = YES;
        else hasDock = YES;
    }

    dispatch_group_t group = dispatch_group_create();
    __block BOOL aborted = NO;

    if (hasIcon) {
        dispatch_group_enter(group);
        [self listChangesToIconBundle:iconBundle changes:changes completion:^(NSModalResponse res) {
            if (res != NSModalResponseOK) aborted = YES;
            dispatch_group_leave(group);
        }];
    }

    if (hasDock) {
        dispatch_group_enter(group);
        [self listChangesToDockBundle:dockBundle changes:changes completion:^(NSModalResponse res) {
            if (res != NSModalResponseOK) aborted = YES;
            dispatch_group_leave(group);
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completion(aborted ? kSOAbort : kSOChanges);
    });
}

- (void)listChangesToIconBundle:(SOSiconPackBundle *)bundle
                        changes:(NSArray<SOChange *> *)changes
                     completion:(void (^)(NSModalResponse))completion{
    NSWindow * parentWindow = NSApp.mainWindow;
    self.iconThemeConfirmSheet = [[SOChangeConfirmSheetController alloc] init];
    [self.iconThemeConfirmSheet window];
    
    NSMutableArray<SOChange *> *iconChanges = [NSMutableArray array];
    
    for (SOChange *c in changes){
        if (c.iconChange)
            [iconChanges addObject:c];
    }
    
    if (iconChanges.count < 1){
        completion(NSModalResponseOK);
        return;
    }
    
    [self.iconThemeConfirmSheet supplyChanges:iconChanges];
    
    [parentWindow beginSheet:self.iconThemeConfirmSheet.window
           completionHandler:^(NSModalResponse returnCode) {

        if (returnCode != NSModalResponseOK) {
            completion(returnCode);
            return;
        }

        NSArray *approved = self.iconThemeConfirmSheet.internalChangeArray;

        [self applyIconChanges:approved
                      toBundle:bundle
                    completion:^(BOOL success) {
            completion(success ? NSModalResponseOK : NSModalResponseAbort);
        }];
    }];
}

- (void)listChangesToDockBundle:(SODockThemeBundle *)bundle
                        changes:(NSArray<SOChange *> *)changes
                     completion:(void (^)(NSModalResponse))completion{
    NSWindow * parentWindow = NSApp.mainWindow;
    self.dockThemeConfirmSheet = [[SOChangeConfirmSheetController alloc] init];
    [self.dockThemeConfirmSheet window];
    
    NSMutableArray<SOChange *> *dockChanges = [NSMutableArray array];
    
    for (SOChange *c in changes){
        if (!c.iconChange)
            [dockChanges addObject:c];
    }
    
    if (dockChanges.count < 1){
        completion(NSModalResponseOK);
        return;
    }
    
    [self.dockThemeConfirmSheet supplyChanges:dockChanges];
    
    [parentWindow beginSheet:self.dockThemeConfirmSheet.window
           completionHandler:^(NSModalResponse returnCode) {

        if (returnCode != NSModalResponseOK) {
            completion(returnCode);
            return;
        }

        NSArray *approved = self.dockThemeConfirmSheet.internalChangeArray;

        [self applyDockChanges:approved
                     toBundle:bundle
                   completion:^(BOOL success) {
            completion(success ? NSModalResponseOK : NSModalResponseAbort);
        }];
    }];
}

- (void)applyIconChanges:(NSArray<SOChange *> *)changes
                toBundle:(SOSiconPackBundle *)bundle
              completion:(void (^)(BOOL))completion{
    NSMutableDictionary * iconSettingsPlist = [NSMutableDictionary new];
    
    for (NSString * key in self.suppliedBaseline) {

        const SOEncodedKey * encodedKey = NULL;

        for (NSUInteger i = 0; i < kSOIconAllKeysCount; i++) {
            if ([kSOIconAllKeys[i].key isEqualToString:key]) {
                encodedKey = &kSOIconAllKeys[i];
                break;
            }
        }

        if (!encodedKey) continue;

        iconSettingsPlist[key] = self.suppliedBaseline[key];
    }
    
    NSMutableArray<NSString *> * purgeCollection = [NSMutableArray new];
    
    [self.class populateIconDictionary:iconSettingsPlist
                           withChanges:changes
                       purgeCollection:purgeCollection];
    
    NSError * error = nil;
    
    SOSiconPackBundle * currentIconPackBundle = [AppDelegate currentIconThemeBundle];

    [currentIconPackBundle writeToIconSettingsPlist:iconSettingsPlist
                                          withError:&error];

    if (error){
        NSLog(@"%@", error);
        completion(NO);
        return;
    }
    
    [self.class purgeFilesIfNeededWithRelativePaths:purgeCollection fromBundle:[AppDelegate currentIconThemeBundle]];
    
    for (SOChange * change in changes){
        if (change.resourceData && change.iconChange){
            [self.class writeFileFromChange:change toBundle:currentIconPackBundle];
        }
    }
    
    completion(YES);
}

- (void)applyDockChanges:(NSArray<SOChange *> *)changes
                toBundle:(SODockThemeBundle *)bundle
              completion:(void (^)(BOOL))completion{
    NSMutableDictionary * settingsPlist = [NSMutableDictionary new];
    NSMutableDictionary * resourcePlist = [NSMutableDictionary new];

    // Populate baseline values
    for (NSString * key in self.suppliedBaseline) {

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

        targetDict[key] = self.suppliedBaseline[key];
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
    
    SODockThemeBundle * themeBundle = [AppDelegate currentDockThemeBundle];

    [themeBundle writeToThemePlist:settingsPlist
                         withError:&error];
    
    if (error) {
        NSLog(@"Theme plist write error: %@", error);
        [SOErrorAlert runModalTerminatingError:error.localizedDescription];
        completion(kSOErrorResult);
        return;
    }

    [themeBundle writeToResourceBomPlist:resourcePlist
                               withError:&error];
    
    if (error) {
        NSLog(@"Resource plist write error: %@", error);
        [SOErrorAlert runModalTerminatingError:error.localizedDescription];
        completion(kSOErrorResult);
        return;
    }
    
    [self.class purgeFilesIfNeededWithRelativePaths:purgeCollection fromBundle:themeBundle];

    for (SOChange * change in changes) {
        if (change.resourceData && !change.iconChange) {
            [self.class writeFileFromChange:change toBundle:themeBundle];
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
            
            __block NSUInteger countOfBaseline = 0;
            
            [dict enumerateKeysAndObjectsUsingBlock:^(NSString * key,
                                                       id obj,
                                                       BOOL * stop) {
                if (![obj isKindOfClass:NSString.class])
                    return;
                
                if ([obj isEqualToString:baselineValue])
                    countOfBaseline++;
            }];
            
            if (baselineValue && countOfBaseline < 2)
                [purgeCollection addObject:baselineValue];
            
            continue;
        }
        
        NSMutableDictionary * rootDict = [dict objectForKey:change.plistKey->key];
        
        if (!rootDict)
            continue;
        
        NSString * baselineValue = [rootDict objectForKey:change.plistKeyPath->components.lastObject];
        
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
        
        if (baselineValue && countOfBaseline < 2)
            [purgeCollection addObject:baselineValue];

        continue;
    }
}

+ (BOOL)writeFileFromChange:(SOChange *)change toBundle:(SONSBundle *)bundle{
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

+ (void)purgeFilesIfNeededWithRelativePaths:(NSMutableArray<NSString *> *)purgeFileRelativePathCollection fromBundle:(SONSBundle *)bundle{
    if (purgeFileRelativePathCollection.count < 1)
        return;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL * baseResourceURL = [bundle resourceURL];
    
    for (NSString * relativePath in purgeFileRelativePathCollection){
        NSURL * relativeURL = [baseResourceURL URLByAppendingPathComponent:relativePath];
        [fm removeItemAtURL:relativeURL error:nil];
    }
    
    [purgeFileRelativePathCollection removeAllObjects];
}
@end
