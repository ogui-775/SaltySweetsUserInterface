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
static NSString * iconServerLaunchAgentPlistPath = nil;

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification{

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
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

+ (void)initializePathsIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
 ^{
        NSString *appSupport =
            NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                NSUserDomainMask,
                                                YES).firstObject;
        
        NSString *library =
            NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                NSUserDomainMask,
                                                YES).firstObject;

        dir = [appSupport stringByAppendingPathComponent:@"SaltySweets"];
        settingsPath = [dir stringByAppendingPathComponent:@"appsettings.plist"];
        bundleDir = [dir stringByAppendingPathComponent:@"Themes"];
        iconsDir = [dir stringByAppendingPathComponent:@"Icons"];
        cryptoDir = [dir stringByAppendingPathComponent:@"Cryptographic Keys"];
        iconsSettingsPath = [iconsDir stringByAppendingPathComponent:@"iconsettings.plist"];
        iconServerLaunchAgentPlistPath = [[library stringByAppendingPathComponent:@"LaunchAgents"]
                                          stringByAppendingPathComponent:@"com.saltysoft.icon-server.plist"];

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

        if (![fm fileExistsAtPath:settingsPath]) {
            NSDictionary *defaultSettings = @{
                   @"kSODockCurrentThemeBundle" : @"",
                             @"kSODockUsername" : @"",
                       kSOIconServerLogging.key : kSOIconServerLogging.defaultValue
            };
            [defaultSettings writeToFile:settingsPath atomically:YES];
        }
        
        if (![fm fileExistsAtPath:iconsSettingsPath]){
            NSDictionary * defaultIconsSettings = @{
                kSOIconsSidebarDict.key : kSOIconsSidebarDict.defaultValue,
                kSOIconsBundleDict.key : kSOIconsBundleDict.defaultValue,
                kSOIconsFolderDict.key : kSOIconsFolderDict.defaultValue,
                kSOIconsSystemDict.key : kSOIconsSystemDict.defaultValue,
                kSOIconTrashFull.key : kSOIconTrashFull.defaultValue,
                kSOIconTrashEmpty.key : kSOIconTrashEmpty.defaultValue,
                kSOIconsDecoratedFolderDict.key : kSOIconsDecoratedFolderDict.defaultValue,
                kSOIconsExtensionDict.key : kSOIconsExtensionDict.defaultValue
            };
            [defaultIconsSettings writeToFile:iconsSettingsPath atomically:YES];
        }
        
        if (![fm fileExistsAtPath:iconServerLaunchAgentPlistPath]){
            if (![fm fileExistsAtPath:[iconServerLaunchAgentPlistPath stringByDeletingLastPathComponent]]){
                [fm createDirectoryAtPath:[iconServerLaunchAgentPlistPath stringByDeletingLastPathComponent]
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&error];
            }
            NSURL *launchAgentPlist = [[NSBundle mainBundle] URLForResource:@"com.saltysoft.icon-server"
                                                              withExtension:@"plist"];
            
            NSData *plistData = [NSPropertyListSerialization
                                 dataWithPropertyList:[NSDictionary dictionaryWithContentsOfURL:launchAgentPlist]
                                               format:NSPropertyListXMLFormat_v1_0
                                              options:NSPropertyListWriteStreamError
                                                error:nil];
            
            [fm createFileAtPath:iconServerLaunchAgentPlistPath
                        contents:plistData
                      attributes:nil];
        }
    });
}

@end
