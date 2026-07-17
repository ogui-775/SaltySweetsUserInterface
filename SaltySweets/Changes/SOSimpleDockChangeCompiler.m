//Created by Salty on 7/16/26.

#import "SOSimpleDockChangeCompiler.h"

@implementation SOSimpleDockChangeCompiler

- (void)createNewThemeWithCompletionHandler:(void (^)(BOOL success))completion {
    self.creationController = [[SOThemeCreationSheetController alloc] initWithCreationType:@"Dock Theme"];
    [self.creationController window];
    self.progressController = [[SOProgressSheetController alloc] initWithWindowNibName:@"SOProgressSheet"];
    [self.progressController window];
    
    [NSApp.mainWindow beginSheet:self.creationController.window
               completionHandler:^(NSModalResponse returnCode) {
        if (returnCode != NSModalResponseOK)
            return;
        
        NSString *newName = self.creationController.nameBox.stringValue;
        NSString *newThemePath = [[[SOAtomicAccessPoint sharedInstance] dockThemeBundleDirectory]
                                 stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"bundle"]];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if ([fm fileExistsAtPath:newThemePath]){
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"Cannot create new theme named %@. A theme exists already with this name.",
                                 newName];
            [alert runModal];
            completion(NO);
            return;
        }
        
        [self createNewThemeWithName:newName
                   completionHandler:^(BOOL success){
            if (!success){
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Failed to create Dock Theme.";
                [alert runModal];
                completion(NO);
                return;
            }
            completion(YES);
        }];
    }];
}

- (void)overrideCurrentThemeWithTemporaryChanges:(NSArray<SOChange *> *)changeArrayForTemporaryUsage
                                        baseline:(NSDictionary<NSString *,id> *)baseline
                               completionHandler:(void (^)(BOOL success))completion {
    if (!completion)
        return;
}

- (void)overwriteCurrentThemeWithChanges:(NSArray<SOChange *> *)changeArrayForInsertion
                                baseline:(NSDictionary<NSString *,id> *)baseline
                       completionHandler:(void  (^)(BOOL success))completion {
    if (!completion)
        return;
    
    SODockThemeBundle *currentBundle = [[SOAtomicAccessPoint sharedInstance] currentDockThemeBundle];

    [self listChangesToDockBundle:currentBundle
                          changes:changeArrayForInsertion
                       completion:^(NSModalResponse response, NSArray<SOChange *> *approvedChanges) {
        if (response != NSModalResponseOK || approvedChanges.count == 0){
            completion(NO);
            return;
        }
        
        NSMutableDictionary *newBaseline = [NSMutableDictionary dictionary];
        
        NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
        opQueue.maxConcurrentOperationCount = 1;
        
        [opQueue addOperationWithBlock:^{
            SODockThemeBundle *currentTheme = [[SOAtomicAccessPoint sharedInstance] currentDockThemeBundle];
            NSMutableArray<NSString *> * purgeCollection = [NSMutableArray new];
            
            for (NSUInteger i = 0; i < kSODockAllKeysCount; i++){
                NSString *key = kSODockAllKeys[i].key;
                id obj = [baseline objectForKey:key];
                if (obj)
                    [newBaseline setObject:obj forKey:key];
            };
            
            [self applyDockChanges:approvedChanges
                          toBundle:currentTheme
                      withBaseline:newBaseline
                        completion:^(BOOL success) {
                if (!success){
                    completion(NO);
                    return;
                }
            }];
            
            [self purgeFilesIfNeededWithRelativePaths:purgeCollection
                                           fromBundle:currentTheme];
        }];
        
        [opQueue addBarrierBlock:^{
            completion(YES);
        }];
    }];
}

- (void)createNewThemeWithName:(NSString *)name
             completionHandler:(void (^)(BOOL))completion{
    if (!completion)
        return;
    
    NSString *sanitizedNewName = [name stringByReplacingOccurrencesOfString:@"." withString:@""];
    sanitizedNewName = [name stringByReplacingOccurrencesOfString:@"bundle" withString:@""];
    
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    opQueue.maxConcurrentOperationCount = 1;
    opQueue.name = @"New_Dock_Theme_Creation_Queue";
    
    [opQueue addOperationWithBlock:^{
        NSString *path = [[SOAtomicAccessPoint sharedInstance] dockThemeBundleDirectory];
        NSURL *newThemeURL = [NSURL fileURLWithPath:[[path stringByAppendingPathComponent:sanitizedNewName] stringByAppendingPathExtension:@"bundle"]];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSError *error = nil;
        [fm copyItemAtURL:[[NSBundle mainBundle] URLForResource:@"Template" withExtension:@"bundle"]
                    toURL:newThemeURL
                    error:&error];
        
        if (error){
            completion(NO);
            [opQueue cancelAllOperations];
            return;
        }
        
        [[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"CompiledThemeIcon"]
                                       forFile:newThemeURL.path
                                       options:0];
        
        SODockThemeBundle *newTheme = [[SODockThemeBundle alloc] initWithURL:newThemeURL];
    
        if (!newTheme){
            completion(NO);
            [opQueue cancelAllOperations];
            return;
        }
        
        NSString *authorName = [[SOAtomicAccessPoint sharedInstance] appSetAuthorName];
        if (authorName && ![authorName isEqualToString:@""]){
            SOChange *authorNameWrite = [[SOChange alloc] init];
            authorNameWrite.plistKey = &kSODockThemePlainAuthorName;
            authorNameWrite.plistValue = authorName;
            authorNameWrite.changeType = kSOChangeTypePlist;
            
            if (![self writeBaselineToNewDockTheme:newTheme nameChange:authorNameWrite]){
                completion(NO);
                [opQueue cancelAllOperations];
                return;
            }
        } else {
            if (![self writeBaselineToNewDockTheme:newTheme nameChange:nil]){
                completion(NO);
                [opQueue cancelAllOperations];
                return;
            }
        }
        
        [[SOAtomicAccessPoint sharedInstance] setCurrentDockThemeBundleName:newThemeURL.lastPathComponent];
        
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

- (BOOL)writeBaselineToNewDockTheme:(SODockThemeBundle *)theme nameChange:(SOChange *)name{
    NSMutableDictionary *themeBaseline = [NSMutableDictionary dictionary];
    NSMutableDictionary *resourceBaseline = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < kSODockAllKeysCount; i++){
        const SOEncodedKey key = kSODockAllKeys[i];

        if (!key.key)
            continue;
        
        if (key.destinationFlags == SODestinationTheme && key.dictionaryKeyCount > 0)
            [themeBaseline setObject:[self recursivelyBuildDictionary:key] forKey:key.key];
        else if (key.destinationFlags == SODestinationTheme)
            [themeBaseline setObject:key.defaultValue forKey:key.key];
        else if (key.destinationFlags == SODestinationResource && key.dictionaryKeyCount > 0)
            [resourceBaseline setObject:[self recursivelyBuildDictionary:key] forKey:key.key];
        else if (key.destinationFlags == SODestinationResource)
            [resourceBaseline setObject:key.defaultValue forKey:key.key];
    }
    
    NSError *err = nil;
    
    if (name){
        [themeBaseline setObject:name.plistValue forKey:name.plistKey->key];
    }
    
    [theme writeToThemePlist:themeBaseline
                   withError:&err];
    
    [theme writeToResourceBomPlist:resourceBaseline
                         withError:&err];
    
    if (!err)
        return YES;
    
    return NO;
}
@end
