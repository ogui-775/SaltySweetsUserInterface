//Created by Salty on 7/16/26.

#import "SOAtomicAccessPoint.h"

static SOAtomicAccessPoint *_instance = nil;

@interface SOAtomicAccessPoint ()
@property (strong) NSMutableSet<NSUndoManager *> *undoManagers;
@property (strong) NSString *settingsPath;
@end

@implementation SOAtomicAccessPoint
+ (instancetype)sharedInstance{
    if (!_instance){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[SOAtomicAccessPoint alloc] init];
            [_instance setUndoManagers:[NSMutableSet set]];
        });
    }
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self){
        _appIconServerConnection = [[NSXPCConnection alloc] initWithMachServiceName:@"com.saltysoft.icon-server"
                                                                                options:0];
        self.appIconServerConnection.remoteObjectInterface =
            [NSXPCInterface interfaceWithProtocol:@protocol(SOIconServerXPCProtocol)];
        NSXPCInterface * localInterface =
            [NSXPCInterface interfaceWithProtocol:@protocol(SOIconClientXPCProtocol)];
        self.appIconServerConnection.exportedInterface = localInterface;
        self.appIconServerConnection.exportedObject = self;
        [self.appIconServerConnection resume];
        
        [self initializePathsIfNeeded];
    }
    return self;
}

- (void)clearAllUndoManagers{
    for (NSUndoManager *m in self.undoManagers){
        [m removeAllActions];
    }
}

- (void)registerUndoManagerForClear:(NSUndoManager *)undoManager withController:(NSViewController *)controller{
    if (undoManager)
        [self.undoManagers addObject:undoManager];
}

- (NSString *)currentIconPackBundleName{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    if (!self.settingsPath)
        [self initializePathsIfNeeded];
    
    NSDictionary * settings =
        [NSDictionary dictionaryWithContentsOfFile:self.settingsPath];

    if (![settings isKindOfClass:[NSDictionary class]]) {
        return @"";
    }

    NSString * bundleName = settings[@"kSOIconsCurrentPack"] ?: @"";
    
    if (![bundleName isEqualToString:kSODockResourceNotProvided] &&
        [fm fileExistsAtPath:[self.iconPackBundleDirectory stringByAppendingPathComponent:bundleName]]){
        return bundleName;
    } else {
        return @"";
    }
}

- (void)setCurrentIconPackBundleName:(NSString *)bundle{
    if (!self.settingsPath)
        [self initializePathsIfNeeded];
    
    NSMutableDictionary *settings =
        [NSMutableDictionary dictionaryWithContentsOfFile:self.settingsPath];
    
    settings[@"kSOIconsCurrentPack"] = bundle;
    
    [settings writeToFile:self.settingsPath atomically:NO];
}

//Loader
- (NSString *)currentDockThemeBundleName{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    if (!self.settingsPath)
        [self initializePathsIfNeeded];
    
    NSDictionary * settings =
        [NSDictionary dictionaryWithContentsOfFile:self.settingsPath];

    if (![settings isKindOfClass:[NSDictionary class]]) {
        return @"";
    }

    NSString * bundleName = settings[@"kSODockCurrentThemeBundle"] ?: @"";
    
    if (![bundleName isEqualToString:kSODockResourceNotProvided] &&
        [fm fileExistsAtPath:[self.dockThemeBundleDirectory stringByAppendingPathComponent:bundleName]]){
        return bundleName;
    } else {
        return @"";
    }
}

- (void)setCurrentDockThemeBundleName:(NSString *)bundle{
    if (!self.settingsPath)
        [self initializePathsIfNeeded];
    
    NSMutableDictionary * settings =
    [NSMutableDictionary dictionaryWithContentsOfFile:self.settingsPath];
    
    settings[@"kSODockCurrentThemeBundle"] = bundle;
    
    [settings writeToFile:self.settingsPath atomically:YES];
}

- (SODockThemeBundle *)currentDockThemeBundle{
    return [SODockThemeBundle bundleWithPath:[self.dockThemeBundleDirectory stringByAppendingPathComponent:[self currentDockThemeBundleName]]];
}

- (SOSiconPackBundle *)currentIconPackBundle{
    return [SOSiconPackBundle bundleWithPath:[self.iconPackBundleDirectory stringByAppendingPathComponent:[self currentIconPackBundleName]]];
}

- (void)setAppSetAuthorName:(NSString *)appSetAuthorName{
    NSMutableDictionary * settings =
        [NSMutableDictionary dictionaryWithContentsOfFile:self.settingsPath];
    
    settings[@"kSODockUsername"] = appSetAuthorName;
    
    [settings writeToFile:self.settingsPath atomically:YES];
}

- (NSString *)appSetAuthorName{
    NSMutableDictionary * settings =
        [NSMutableDictionary dictionaryWithContentsOfFile:self.settingsPath];
    
    return settings[@"kSODockUsername"] ?: @"";
}

- (NSArray *)applicationFolderPaths{
    NSMutableArray * applicationsFolders =
        [[NSDictionary dictionaryWithContentsOfFile:self.settingsPath] objectForKey:@"kSOIconsFolderPaths"];
    
    return applicationsFolders ?: @[];
}

- (void)setApplicationFolderPaths:(NSArray *)paths{
    NSMutableDictionary * settings =
    [NSMutableDictionary dictionaryWithContentsOfFile:self.settingsPath];
    
    [settings setObject:paths forKey:@"kSOIconsFolderPaths"];
    [settings writeToFile:self.settingsPath atomically:YES];
}

- (void)initializePathsIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
 ^{
        NSString *appSupport =
            NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                NSUserDomainMask,
                                                YES).firstObject;

        NSString *dir = [appSupport stringByAppendingPathComponent:@"SaltySweets"];
        _settingsPath = [dir stringByAppendingPathComponent:@"appsettings.plist"];
        _dockThemeBundleDirectory = [dir stringByAppendingPathComponent:@"Themes"];
        _iconPackBundleDirectory = [dir stringByAppendingPathComponent:@"Icons"];
        _cryptographicKeyDirectory = [dir stringByAppendingPathComponent:@"Cryptographic Keys"];

        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;

        if (![fm fileExistsAtPath:dir]) {
            [fm createDirectoryAtPath:dir
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];
        }

        if (![fm fileExistsAtPath:self.dockThemeBundleDirectory]) {
            [fm createDirectoryAtPath:_dockThemeBundleDirectory
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];
        }
        
        if (![fm fileExistsAtPath:self.iconPackBundleDirectory]) {
            [fm createDirectoryAtPath:_iconPackBundleDirectory
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];
        }
        
        if (![fm fileExistsAtPath:self.cryptographicKeyDirectory]){
            [fm createDirectoryAtPath:_cryptographicKeyDirectory
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];
        }

        NSDictionary * defaultSettings = @{
            @"kSODockCurrentThemeBundle" : @"",
            @"kSODockUsername" : @"",
            kSOIconServerLogging.key : kSOIconServerLogging.defaultValue,
            @"kSOIconsFolderPaths" : @[
                @"~/Applications/",
                @"/System/Applications/",
                @"/Applications/",
                @"/System/Library/CoreServices/"
            ],
            @"kSOIconsCurrentPack" : @""
        };

        if (![fm fileExistsAtPath:self.settingsPath]) {
            [defaultSettings writeToFile:self.settingsPath atomically:YES];
        } else {
            NSMutableDictionary *loadedSettings =
                [NSMutableDictionary dictionaryWithContentsOfFile:self.settingsPath];
        
            if (!loadedSettings) {
                loadedSettings = [defaultSettings mutableCopy];
                [loadedSettings writeToFile:self.settingsPath atomically:YES];
                return;
            }
            
            BOOL didModify = NO;
            
            for (id key in defaultSettings) {
                id defaultValue = defaultSettings[key];
                id loadedValue  = loadedSettings[key];
                
                if (!loadedValue) {
                    loadedSettings[key] = defaultValue;
                    didModify = YES;
                }
            }
            
            if (didModify) {
                [loadedSettings writeToFile:self.settingsPath atomically:YES];
            }
        }
    });
}
@end
