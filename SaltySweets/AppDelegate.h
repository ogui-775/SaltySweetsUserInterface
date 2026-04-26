//Created by Salty on 1/31/26.

#import <Cocoa/Cocoa.h>
#import <SharedBundles/SharedBundles.h>

#import "SOViewPane.h"
#import "SOBaseline.h"
#import "../../icon-server/icon-server/SOIconServerXPCProtocol.h"
#import "../../icon-server/icon-server/SOIconClientXPCProtocol.h"
#import "../SOAuxWinds/Controllers/SONSWindowAuxController.h"
#import "../SOAuxWinds/Controllers/SONSWindowAuxSiconCreationController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, SOIconClientXPCProtocol>
@property (strong) IBOutlet NSWindow * window;

+ (NSString *)currentThemeBundleName;
+ (void)setCurrentThemeBundleName:(NSString *)bundle;
+ (NSString *)currentIconPackBundleName;
+ (void)setCurrentIconPackBundleName:(NSString *)bundle;
+ (NSString *)bundleDir;
+ (NSString *)iconsDir;
+ (NSString *)cryptoKeyDir;
+ (SODockThemeBundle *)currentDockThemeBundle;
+ (SOSiconPackBundle *)currentIconThemeBundle;
+ (void)setAppSetAuthorName:(NSString *)name;
+ (NSString *)appSetAuthorName;
+ (BOOL)iconServerLogging;
+ (void)setIconServerLogging:(BOOL)logging;
+ (NSArray *)applicationFolderPaths;
+ (void)setApplicationFolderPaths:(NSArray *)paths;
+ (NSXPCConnection *)appIconServerConnection;
+ (void)registerUndoManagerForClear:(NSUndoManager *)undoManager withController:(NSViewController *)controller;
+ (void)clearAllUndoManagers;
+ (instancetype)sharedInstance;
@end
