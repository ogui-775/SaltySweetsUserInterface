//Created by Salty on 7/16/26.

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

#import <SharedBundles/SharedBundles.h>

#import "../../../icon-server/icon-server/SOIconClientXPCProtocol.h"
#import "../../../icon-server/icon-server/SOIconServerXPCProtocol.h"

@interface SOAtomicAccessPoint : NSObject
+ (instancetype)sharedInstance;

- (void)registerUndoManagerForClear:(NSUndoManager *)undoManager withController:(NSViewController *)controller;
- (void)clearAllUndoManagers;

- (NSString *)currentDockThemeBundleName;
- (void)setCurrentDockThemeBundleName:(NSString *)name;
- (NSString *)currentIconPackBundleName;
- (void)setCurrentIconPackBundleName:(NSString *)name;

@property (strong, readonly) NSString *dockThemeBundleDirectory;
@property (strong, readonly) NSString *iconPackBundleDirectory;
@property (strong, readonly) NSString *cryptographicKeyDirectory;
- (SODockThemeBundle *)currentDockThemeBundle;
- (SOSiconPackBundle *)currentIconPackBundle;
- (NSString *)appSetAuthorName;
- (void)setAppSetAuthorName:(NSString *)name;
- (NSArray *)applicationFolderPaths;
- (void)setApplicationFolderPaths:(NSArray *)paths;
@property (strong, nonatomic, readonly) NSXPCConnection *appIconServerConnection;
@end
