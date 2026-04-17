//Created by Salty on 1/31/26.

#import <Cocoa/Cocoa.h>

#import "SOViewPane.h"
#import "SOBaseline.h"
#import "../../icon-server/icon-server/SOIconServerXPCProtocol.h"
#import "../../icon-server/icon-server/SOIconClientXPCProtocol.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, SOIconClientXPCProtocol>
+ (NSString *)currentThemeBundleName;
+ (void)setCurrentThemeBundleName:(NSString *)bundle;
+ (NSString *)bundleDir;
+ (NSString *)iconsDir;
+ (NSString *)cryptoKeyDir;
+ (NSBundle *)currentThemeBundle;
+ (void)setAppSetAuthorName:(NSString *)name;
+ (NSString *)appSetAuthorName;
+ (BOOL)iconServerLogging;
+ (void)setIconServerLogging:(BOOL)logging;
+ (NSArray *)applicationFolderPaths;
+ (void)setApplicationFolderPaths:(NSArray *)paths;
+ (NSXPCConnection *)appIconServerConnection;
+ (void)registerUndoManagerForClear:(NSUndoManager *)undoManager withController:(NSViewController *)controller;
+ (void)clearAllUndoManagers;
@end
