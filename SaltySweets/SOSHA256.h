//Created by Salty on 2/10/26.

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <SharedKeys/SOSharedKeys.h>

@interface SOSHA256 : NSObject

+ (NSString *)sha256FromData:(NSData *)data key:(const SOEncodedKey *)key;
+ (NSString *)sha256FromData:(NSData *)data keypath:(const SOEncodedKeyPath *)key;
+ (NSString *)sha256FromData:(NSData *)data;

@end
