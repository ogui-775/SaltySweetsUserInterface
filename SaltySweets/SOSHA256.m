//Created by Salty on 2/10/26.

#import "SOSHA256.h"

@implementation SOSHA256

+ (NSString *)sha256FromData:(NSData *)data
{
    if (!data) return nil;

    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, hash);

    NSMutableString * hexString =
        [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hexString appendFormat:@"%02x", hash[i]];
    }

    return [hexString copy];
}

+ (NSString *)sha256FromData:(NSData *)data
                         key:(const SOEncodedKey *)key
{
    if (!data || !key || !key->key) return nil;

    NSMutableData *input = [NSMutableData data];

    NSData * keyData = [key->key dataUsingEncoding:NSUTF8StringEncoding];
    uint32_t keyLength = (uint32_t)keyData.length;
    [input appendBytes:&keyLength length:sizeof(uint32_t)];
    [input appendData:keyData];

    [input appendData:data];

    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(input.bytes, (CC_LONG)input.length, hash);

    NSMutableString *hexString =
        [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hexString appendFormat:@"%02x", hash[i]];
    }

    return [hexString copy];
}


+ (NSString *)sha256FromData:(NSData *)data
                     keypath:(const SOEncodedKeyPath *)keyPath
{
    if (!data || !keyPath || !keyPath->rootKey || !keyPath->rootKey->key)
        return nil;

    NSMutableData *input = [NSMutableData data];

    NSData * rootKeyData =
        [keyPath->rootKey->key dataUsingEncoding:NSUTF8StringEncoding];
    uint32_t rootLength = (uint32_t)rootKeyData.length;
    [input appendBytes:&rootLength length:sizeof(uint32_t)];
    [input appendData:rootKeyData];

    for (NSString * component in keyPath->components) {
        NSData * componentData = [component dataUsingEncoding:NSUTF8StringEncoding];
        uint32_t componentLength = (uint32_t)componentData.length;
        [input appendBytes:&componentLength length:sizeof(uint32_t)];
        [input appendData:componentData];
    }

    [input appendData:data];

    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(input.bytes, (CC_LONG)input.length, hash);

    NSMutableString *hexString =
        [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hexString appendFormat:@"%02x", hash[i]];
    }

    return [hexString copy];
}


@end
