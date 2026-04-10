//Created by Salty on 2/16/26.

#import <AppKit/AppKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>

#import "../AppDelegate.h"

@interface SOSignatures : NSObject
+ (BOOL)verifyThemeAuthorship:(NSBundle *)bundle;
+ (BOOL)signThemeBundle:(NSBundle *)bundle;
+ (NSString *)themeAuthorFingerprint:(NSBundle *)bundle;

+ (void)generateAndStoreAuthoringKeypair;
+ (BOOL)authoringKeypairExists;
@end
