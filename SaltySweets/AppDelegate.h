//Created by Salty on 1/31/26.

#import <Cocoa/Cocoa.h>
#import "SOViewPane.h"
#import "SOBaseline.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
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
@end
