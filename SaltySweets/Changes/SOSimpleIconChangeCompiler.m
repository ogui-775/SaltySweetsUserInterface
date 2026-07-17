//Created by Salty on 7/14/26.

#import "SOSimpleIconChangeCompiler.h"

@implementation SOSimpleIconChangeCompiler

- (void)createNewPackWithName:(NSString *)name
            completionHandler:(void (^)(BOOL))completion{
    if (!completion)
        return;
    
    NSString *sanitizedNewName = [name stringByReplacingOccurrencesOfString:@"." withString:@""];
    sanitizedNewName = [name stringByReplacingOccurrencesOfString:@"siconpack" withString:@""];
    
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    opQueue.maxConcurrentOperationCount = 1;
    opQueue.name = @"New_Icon_Pack_Creation_Queue";
    
    [opQueue addOperationWithBlock:^{
        NSString *path = [[SOAtomicAccessPoint sharedInstance] iconPackBundleDirectory];
        NSURL *newPackURL = [NSURL fileURLWithPath:[[path stringByAppendingPathComponent:sanitizedNewName] stringByAppendingPathExtension:@"siconpack"]];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSError *error = nil;
        [fm copyItemAtURL:[[NSBundle mainBundle] URLForResource:@"Template" withExtension:@"siconpack"]
                    toURL:newPackURL
                    error:&error];
        
        if (error){
            completion(NO);
            [opQueue cancelAllOperations];
            return;
        }
        
        [[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"siconpack_icon"]
                                       forFile:newPackURL.path
                                       options:0];
        
        SOSiconPackBundle *newPack = [[SOSiconPackBundle alloc] initWithURL:newPackURL];
        
        if (!newPack){
            completion(NO);
            [opQueue cancelAllOperations];
            return;
        }
        
        if (![self writeBaselineToNewIconPack:newPack]){
            completion(NO);
            [opQueue cancelAllOperations];
            return;
        }
        
        [[SOAtomicAccessPoint sharedInstance] setCurrentIconPackBundleName:newPackURL.lastPathComponent];
        
        [[NSNotificationCenter defaultCenter]
            postNotificationName:SONotificationBaseClassUpdateBaseline
                          object:self];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            for (id<SOConfigurableContent> page in [SOViewPane defaultInstance].childViewControllers) {
                if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
                    [page refreshOrLoadBaseline];

                if ([page respondsToSelector:@selector(purgePendingChanges)])
                    [page purgePendingChanges];
            }
        });
    }];
    
    [opQueue addBarrierBlock:^{
        completion(YES);
    }];
}

- (void)overwriteCurrentPackWithChanges:(NSArray<SOChange *> *)changeArrayForInsertion
                               baseline:(NSDictionary<NSString *,id> *)baseline
                      completionHandler:(void (^)(BOOL))completion{
    if (!completion)
        return;
    
    SOSiconPackBundle *currentBundle = [[SOAtomicAccessPoint sharedInstance] currentIconPackBundle];
    
    if (!currentBundle)
        return;
    
    [self listChangesToIconBundle:currentBundle
                          changes:changeArrayForInsertion
                       completion:^(NSModalResponse response, NSArray<SOChange *> *approvedChanges) {
        if (response != NSModalResponseOK){
            return;
        }
        
        NSMutableDictionary *newBaseline = [NSMutableDictionary dictionary];
        
        NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
        opQueue.maxConcurrentOperationCount = 1;
        
        self.progressController = [[SOProgressSheetController alloc] initWithWindowNibName:@"SOProgressSheet"];
        [self.progressController window];
        
        [opQueue addOperationWithBlock:^{
            size_t unit_count = [approvedChanges count];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressController.progressBar.maxValue = unit_count;
                opQueue.progress.totalUnitCount = unit_count;
                [NSApp.mainWindow beginSheet:self.progressController.window
                           completionHandler:^(NSModalResponse returnCode) {
                }];
            });
            
            SOSiconPackBundle *currentPack = [[SOAtomicAccessPoint sharedInstance] currentIconPackBundle];
            NSMutableArray<NSString *> * purgeCollection = [NSMutableArray new];
            
            for (NSUInteger i = 0; i < kSOIconAllKeysCount; i++){
                NSString *key = kSOIconAllKeys[i].key;
                id obj = [baseline objectForKey:key];
                if (obj)
                    [newBaseline setObject:obj forKey:key];
            };
            
            for (SOChange *change in approvedChanges){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *pendingAction = [self describeChange:change];
                    [self.progressController.progressLabel animateFieldToShow:pendingAction];
                });
                
                [self populateIconDictionary:newBaseline
                                  withChange:change
                             purgeCollection:purgeCollection];
                
                if ([change isKindOfClass:SOKeyChange.class]){
                    
                }
                else if (change.resourceData && change.iconChange){
                    [self writeFileFromChange:change
                                     toBundle:currentPack];
                }
                
                opQueue.progress.completedUnitCount++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progressController.progressBar.doubleValue = opQueue.progress.completedUnitCount;
                });
            }
            
            NSError *error = nil;
            [currentPack writeToIconSettingsPlist:newBaseline
                                        withError:&error];

            if (error){
                NSLog(@"%@", error);
                completion(NO);
                return;
            }
            
            [self purgeFilesIfNeededWithRelativePaths:purgeCollection
                                           fromBundle:currentPack];
        }];
        
        [opQueue addBarrierBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSApp.mainWindow endSheet:self.progressController.window];
            });
            completion(YES);
        }];
    }];
}

- (void)overrideCurrentPackWithTemporaryChanges:(NSArray<SOChange *> *)changeArrayForTemporaryUsage
                                       baseline:(NSDictionary<NSString *,id> *)baseline
                              completionHandler:(void (^)(BOOL))completion{
    if (!completion)
        return;
    
    if (![[SOAtomicAccessPoint sharedInstance] currentIconPackBundle])
        return;
    
    //To do - add temp override dir
}

- (BOOL)writeBaselineToNewIconPack:(SOSiconPackBundle *)pack{
    NSMutableDictionary *freshBaseline = [NSMutableDictionary dictionary];

    for (NSUInteger idx = 0; idx < kSOIconAllKeysCount; idx++){
        const SOEncodedKey key = kSOIconAllKeys[idx];
        
        if (!key.key)
            continue;
        
        if (key.valueEncoding == SOValueEncodingNSDictionary && key.dictionaryKeyCount > 0){
            [freshBaseline addEntriesFromDictionary:@{ key.key : [self recursivelyBuildDictionary:key]}];
        }
        else
            [freshBaseline addEntriesFromDictionary:@{ key.key : key.defaultValue }];
    }
    
    if (freshBaseline.count < kSOIconAllKeysCount)
        return NO;
    
    NSError *error = nil;
    [pack writeToIconSettingsPlist:freshBaseline
                         withError:&error];
    
    if (error)
        return NO;
    
    return YES;
}

- (void)createNewPackWithCompletionHandler:(void (^)(BOOL))completion{
    SOThemeCreationSheetController *creationController = [[SOThemeCreationSheetController alloc] initWithCreationType:@"Icon Pack"];
    
    self.creationController = creationController;
    
    [creationController window];
    
    [NSApp.mainWindow beginSheet:creationController.window
               completionHandler:^(NSModalResponse returnCode){
        if (returnCode != NSModalResponseOK)
            return;
        
        NSString *newName = creationController.nameBox.stringValue;
        NSString *newPackPath = [[[SOAtomicAccessPoint sharedInstance] iconPackBundleDirectory] stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"siconpack"]];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if ([fm fileExistsAtPath:newPackPath]){
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"Cannot create new pack named %@. A pack exists already with this name.",
                                 newName];
            [alert runModal];
            completion(NO);
            return;
        }
        
        [self createNewPackWithName:newName
                          completionHandler:^(BOOL success){
            if (!success){
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Failed to create Icon Pack.";
                [alert runModal];
                completion(NO);
                return;
            }
            completion(YES);
        }];
    }];
}
@end
