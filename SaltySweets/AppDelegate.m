//Created by Salty on 1/31/26.

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong) IBOutlet NSWindow * window;
@end

static NSString * appSupport = nil;
static NSString * dir = nil;
static NSString * settingsPath = nil;
static NSString * bundleDir = nil;
static NSString * iconsDir = nil;
static NSString * iconsSettingsPath = nil;
static NSString * cryptoDir = nil;
static NSMapTable * undoManagerPotholder = nil;

static __strong NSXPCConnection * iconServerConnection = nil;

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification{

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    iconServerConnection = [[NSXPCConnection alloc] initWithMachServiceName:@"com.saltysoft.icon-server"
                                                                    options:0];
    iconServerConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SOIconServerXPCProtocol)];
    
    NSXPCInterface * localInterface =
        [NSXPCInterface interfaceWithProtocol:@protocol(SOIconClientXPCProtocol)];
    
    iconServerConnection.exportedInterface = localInterface;
    iconServerConnection.exportedObject = self;

    [iconServerConnection resume];
    
    undoManagerPotholder = [NSMapTable weakToWeakObjectsMapTable];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

+ (void)registerUndoManagerForClear:(NSUndoManager *)undoManager
                     withController:(NSViewController *)controller{
    @synchronized(self){
        [undoManagerPotholder setObject:undoManager forKey:controller];
    }
}

+ (void)clearAllUndoManagers{
    @synchronized (self) {
        for (NSViewController * vc in undoManagerPotholder){
            NSUndoManager * weakUndoer = [undoManagerPotholder objectForKey:vc];
            [weakUndoer removeAllActions];
        }
    }
}

//XPC sharing
+ (NSXPCConnection *)appIconServerConnection{
    if (iconServerConnection)
        return iconServerConnection;
    
    return nil;
}

- (void)asyncClearCachedSettings{
    return; //No-op
}

//Loader
+ (NSString *)currentThemeBundleName{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    if (!settingsPath)
        [self.class initializePathsIfNeeded];
    
    NSDictionary * settings =
        [NSDictionary dictionaryWithContentsOfFile:settingsPath];

    if (![settings isKindOfClass:[NSDictionary class]]) {
        return @"";
    }

    NSString * bundleName = settings[@"kSODockCurrentThemeBundle"] ?: @"";
    
    if (![bundleName isEqualToString:kSODockResourceNotProvided] &&
        [fm fileExistsAtPath:[bundleDir stringByAppendingPathComponent:bundleName]]){
        return bundleName;
    } else {
        return @"";
    }
}

+ (void)setCurrentThemeBundleName:(NSString *)bundle{
    if (!settingsPath)
        [self.class initializePathsIfNeeded];
    
    NSMutableDictionary * settings =
        [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    
    settings[@"kSODockCurrentThemeBundle"] = bundle;
    
    [settings writeToFile:settingsPath atomically:YES];
}

+ (NSString *)bundleDir{
    if (!bundleDir)
        [self.class initializePathsIfNeeded];
    
    return bundleDir;
}

+ (NSString *)iconsDir{
    if (!iconsDir)
        [self.class initializePathsIfNeeded];
    
    return iconsDir;
}

+ (NSString *)cryptoKeyDir{
    if (!cryptoDir)
        [self.class initializePathsIfNeeded];
    
    return cryptoDir;
}

+ (void)setIconServerLogging:(BOOL)logging{
    if (!settingsPath)
        [self.class initializePathsIfNeeded];
    
    NSMutableDictionary * settings =
        [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    
    settings[kSOIconServerLogging.key] = @(logging);
    
    [settings writeToFile:settingsPath atomically:YES];
}

+ (BOOL)iconServerLogging{
    if (!settingsPath)
        [self.class initializePathsIfNeeded];
    
    return [[[NSDictionary dictionaryWithContentsOfFile:settingsPath] valueForKey:kSOIconServerLogging.key] boolValue];
}

+ (NSBundle *)currentThemeBundle{
    return [NSBundle bundleWithPath:[bundleDir stringByAppendingPathComponent:[self.class currentThemeBundleName]]];
}

+ (void)setAppSetAuthorName:(NSString *)appSetAuthorName{
    NSMutableDictionary * settings =
        [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    
    settings[@"kSODockUsername"] = appSetAuthorName;
    
    [settings writeToFile:settingsPath atomically:YES];
}

+ (NSString *)appSetAuthorName{
    NSMutableDictionary * settings =
        [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    
    return settings[@"kSODockUsername"] ?: @"";
}

+ (NSArray *)applicationFolderPaths{
    NSMutableArray * applicationsFolders =
        [[NSDictionary dictionaryWithContentsOfFile:settingsPath] objectForKey:@"kSOIconsFolderPaths"];
    
    return applicationsFolders ?: @[];
}

+ (void)setApplicationFolderPaths:(NSArray *)paths{
    NSMutableDictionary * settings =
        [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    
    [settings setObject:paths forKey:@"kSOIconsFolderPaths"];
    [settings writeToFile:settingsPath atomically:YES];
}

+ (void)initializePathsIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
 ^{
        NSString *appSupport =
            NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                NSUserDomainMask,
                                                YES).firstObject;

        dir = [appSupport stringByAppendingPathComponent:@"SaltySweets"];
        settingsPath = [dir stringByAppendingPathComponent:@"appsettings.plist"];
        bundleDir = [dir stringByAppendingPathComponent:@"Themes"];
        iconsDir = [dir stringByAppendingPathComponent:@"Icons"];
        cryptoDir = [dir stringByAppendingPathComponent:@"Cryptographic Keys"];
        iconsSettingsPath = [iconsDir stringByAppendingPathComponent:@"iconsettings.plist"];

        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;

        if (![fm fileExistsAtPath:dir]) {
            [fm createDirectoryAtPath:dir
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];
        }

        if (![fm fileExistsAtPath:bundleDir]) {
            [fm createDirectoryAtPath:bundleDir
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];
        }
        
        if (![fm fileExistsAtPath:iconsDir]) {
            [fm createDirectoryAtPath:iconsDir
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];
        }
        
        if (![fm fileExistsAtPath:cryptoDir]){
            [fm createDirectoryAtPath:cryptoDir
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
            ]
        };

        if (![fm fileExistsAtPath:settingsPath]) {
            [defaultSettings writeToFile:settingsPath atomically:YES];
        } else {
            NSMutableDictionary * loadedSettings =
                [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
        
            if (!loadedSettings) {
                loadedSettings = [defaultSettings mutableCopy];
                [loadedSettings writeToFile:settingsPath atomically:YES];
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
                [loadedSettings writeToFile:settingsPath atomically:YES];
            }
        }
        
        if (![fm fileExistsAtPath:iconsSettingsPath]){
            NSDictionary * defaultIconsSettings = @{
                kSOIconsSidebarDict.key : kSOIconsSidebarDict.defaultValue,
                kSOIconsBundleDict.key : kSOIconsBundleDict.defaultValue,
                kSOIconsFolderDict.key : kSOIconsFolderDict.defaultValue,
                kSOIconsSystemDict.key : kSOIconsSystemDict.defaultValue,
                kSOIconsDecoratedFolderDict.key : kSOIconsDecoratedFolderDict.defaultValue,
                kSOIconsExtensionDict.key : kSOIconsExtensionDict.defaultValue
            };
            [defaultIconsSettings writeToFile:iconsSettingsPath atomically:YES];
        }
    });
}

@end
