//Created by Salty on 1/31/26.

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong) IBOutlet NSWindow * window;
@property (strong) NSMutableDictionary<NSURL *, SONSWindowAuxController *> * urlToAuxController;
@end

static NSString * appSupport = nil;
static NSString * dir = nil;
static NSString * settingsPath = nil;
static NSString * bundleDir = nil;
static NSString * iconsDir = nil;
static NSString * cryptoDir = nil;
static NSMapTable * undoManagerPotholder = nil;

static __strong NSXPCConnection * iconServerConnection = nil;

@implementation AppDelegate

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
    if (!self.urlToAuxController)
        self.urlToAuxController = [NSMutableDictionary dictionary];
    
    for (NSURL * url in urls){
        if ([[url pathExtension] isEqualToString:@"sicon"]){
            SONSWindowAuxController * controller = nil;
            if (![self.urlToAuxController objectForKey:url])
                controller = [[SONSWindowAuxController alloc] initControllerForSiconContextWithURL:url];
            
            if (controller)
                [self.urlToAuxController setObject:controller forKey:url];
            
            if ([self.urlToAuxController objectForKey:url]){
                controller = [self.urlToAuxController objectForKey:url];
                [controller.window makeKeyAndOrderFront:nil];
            }
        }
    }
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification{

}

static NSDictionary<NSString *, NSValue *> *KeyStrToEncoded(void){
    return @{
        kSOSicon16x.key   : [NSValue valueWithPointer:&kSOSicon16x],
        kSOSicon16x2x.key : [NSValue valueWithPointer:&kSOSicon16x2x],
        kSOSicon32x.key   : [NSValue valueWithPointer:&kSOSicon32x],
        kSOSicon32x2x.key : [NSValue valueWithPointer:&kSOSicon32x2x],
        kSOSicon128x.key  : [NSValue valueWithPointer:&kSOSicon128x],
        kSOSicon128x2x.key: [NSValue valueWithPointer:&kSOSicon128x2x],
        kSOSicon256x.key  : [NSValue valueWithPointer:&kSOSicon256x],
        kSOSicon256x2x.key: [NSValue valueWithPointer:&kSOSicon256x2x],
        kSOSicon512x.key  : [NSValue valueWithPointer:&kSOSicon512x],
        kSOSicon512x2x.key: [NSValue valueWithPointer:&kSOSicon512x2x]
    };
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
    
    NSMutableArray<SOSiconEntry *> *defTestArray = [NSMutableArray array];
    NSArray<NSImage *> *testData = @[
        [NSImage imageNamed:@"NXBreak"],
        [NSImage imageNamed:@"NSTruthClose"],
        [NSImage imageNamed:@"NSTruthCloseH"],
        [NSImage imageNamed:@"AppIcon"],
        [[NSWorkspace sharedWorkspace] iconForContentType:[UTType typeWithIdentifier:@"public.folder"]]
    ];
    
    for (int i = 0; i < 5; i++){
        SOSiconEntry *entry = [[SOSiconEntry alloc] init];
        NSImage *imageData = testData[i];
        SOSiconDef *def = [[SOSiconDef alloc] init];
        def.filename = imageData.name;
        def.size = imageData.size;
        def.isRetina = YES;
        def.encodedKey = i == 0 ? &kSOSicon16x2x : i == 1 ? &kSOSicon32x2x : i == 2 ? &kSOSicon128x2x : i == 3 ? &kSOSicon256x2x : i == 4 ? &kSOSicon512x2x : nil;
        def.variantKey = &kSOSiconLight;
        
        entry.def = def;
        entry.imageData = imageData.TIFFRepresentation;
        [defTestArray addObject:entry];
    }
    SOSiconBundle * templateBundle = [SOSiconBundle bundleWithURL:[[AppDelegate currentIconThemeBundle] URLForResource:@"Template" withExtension:@"sicon"]];
    
    [templateBundle writeBlobArrayToDisk:defTestArray];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

+ (NSString *)currentIconPackBundleName{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    if (!settingsPath)
        [self.class initializePathsIfNeeded];
    
    NSDictionary * settings =
        [NSDictionary dictionaryWithContentsOfFile:settingsPath];

    if (![settings isKindOfClass:[NSDictionary class]]) {
        return @"";
    }

    NSString * bundleName = settings[@"kSOIconsCurrentPack"] ?: @"";
    
    if (![bundleName isEqualToString:kSODockResourceNotProvided] &&
        [fm fileExistsAtPath:[iconsDir stringByAppendingPathComponent:bundleName]]){
        return bundleName;
    } else {
        return @"";
    }
}

+ (void)setCurrentIconPackBundleName:(NSString *)bundle{
    if (!settingsPath)
        [self.class initializePathsIfNeeded];
    
    NSMutableDictionary *settings =
        [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    
    settings[@"kSOIconsCurrentPack"] = bundle;
    
    [settings writeToFile:settingsPath atomically:NO];
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

+ (SODockThemeBundle *)currentDockThemeBundle{
    return [SODockThemeBundle bundleWithPath:[bundleDir stringByAppendingPathComponent:[self.class currentThemeBundleName]]];
}

+ (SOSiconPackBundle *)currentIconThemeBundle{
    return [SOSiconPackBundle bundleWithPath:[iconsDir stringByAppendingPathComponent:[self.class currentIconPackBundleName]]];
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
            ],
            @"kSOIconsCurrentPack" : @""
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
    });
}

@end
