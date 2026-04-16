//Created by Salty on 2/8/26.

#import "SOConfigurableContent.h"

#pragma mark - Change types

SOChangeType const kSOChangeTypePlist    = @"plist";
SOChangeType const kSOChangeTypeResource = @"resource";

#pragma mark - Resource types

SOChangeResourceType const kSOChangeResourceTypeNSImage = @"nsimage";
SOChangeResourceType const kSOChangeResourceTypeAIFF    = @"aiff";
SOChangeResourceType const kSOChangeResourceNSData      = @"nsdata";

#pragma mark - Dictionary keys

NSString * const kSOChangeKeyType           = @"type";
NSString * const kSOChangeKeyContentScale   = @"contentScale";
NSString * const kSOChangeKeyPlistKey       = @"plistKey";
NSString * const kSOChangeKeyPlistValue     = @"plistValue";
NSString * const kSOChangeKeyResourceType   = @"resourceType";
NSString * const kSOChangeKeyResourceData   = @"resourceData";
NSString * const kSOChangeKeyHeyWhatsNew    = @"descriptiom";
NSString * const kSOChangeKeyResourceFilename = @"filename";

#pragma mark - Notifications
NSString * SONotificationBaseClassUpdateBaseline = @"SONotificationBaseClassUpdateBaseline";

@implementation SOChange

#pragma mark - Plist changes

+ (instancetype)plistChangeWithEncodedKey:(const SOEncodedKey *)encodedKey
                                    value:(id)value
                                     note:(NSString *)note
{
    SOChange *change = [SOChange new];
    change.plistKey = encodedKey;
    change.plistValue = value ?: encodedKey->defaultValue;
    change.changeNote = note;
    change.changeType = kSOChangeTypePlist;
    return change;
}

+ (instancetype)plistChangeWithEncodedKeyPath:(const SOEncodedKeyPath *)encodedKey
                                        value:(id)value
                                         note:(NSString *)note
{
    SOChange * change = [SOChange new];
    const SOEncodedKeyPath * allocatedKey = [change allocKeyPath:encodedKey];
    change.plistKey = allocatedKey->rootKey;
    change.plistKeyPath = allocatedKey;
    change.plistValue = value;
    change.changeType = kSOChangeTypePlist;
    change.changeNote = note;
    return change;
}

#pragma mark - Resource changes

+ (instancetype)resourceChangeWithEncodedKey:(const SOEncodedKey *)encodedKey
                                        data:(NSData *)data
                                    filename:(NSString *)filename
                                contentScale:(CGFloat)scale
                                 contentType:(SOChangeResourceType)type
                                        note:(NSString *)note
                                        hash:(NSString *)hash
{
    SOChange *change = [SOChange new];
    change.plistKey = encodedKey;
    change.resourceData = data;
    change.resourceFilename = filename;
    change.resourceContentScale = scale;
    change.changeNote = note;
    change.changeType = kSOChangeTypeResource;
    change.resourceType = type;
    change.sha256 = hash;
    return change;
}

+ (instancetype)resourceChangeWithEncodedKeyPath:(const SOEncodedKeyPath *)encodedKey
                                            data:(NSData *)data
                                        filename:(NSString *)filename
                                    contentScale:(CGFloat)scale
                                     contentType:(SOChangeResourceType)type
                                            note:(NSString *)note
                                            hash:(NSString *)hash
{
    SOChange * change = [SOChange new];
    const SOEncodedKeyPath * allocatedKey = [change allocKeyPath:encodedKey];
    change.plistKey = allocatedKey->rootKey;
    change.plistKeyPath = allocatedKey;
    change.resourceData = data;
    change.resourceFilename  = filename;
    change.resourceContentScale = scale;
    change.changeNote = note;
    change.resourceType = type;
    change.changeType = kSOChangeTypeResource;
    change.sha256 = hash;
    return change;
}

- (const SOEncodedKeyPath *)allocKeyPath:(const SOEncodedKeyPath *)path{
    SOEncodedKeyPath * allocated = malloc(sizeof(SOEncodedKeyPath));
    allocated->rootKey = path->rootKey;
    allocated->components = path->components;
    return allocated;
}

- (void)dealloc{
    if (_plistKeyPath)
        free((void *)_plistKeyPath);
}

+ (instancetype)iconResourceChangeWithEncodedKey:(const SOEncodedKey *)encodedKey
                                            data:(NSData *)data
                                        filename:(NSString *)filename
                                            note:(NSString *)note {
    SOChange * change = [SOChange resourceChangeWithEncodedKey:encodedKey
                                                          data:data
                                                      filename:filename
                                                  contentScale:0
                                                   contentType:kSOChangeResourceNSData
                                                          note:note
                                                          hash:@""];
    change.iconChange = YES;
    return change;
}

+ (instancetype)iconResourceChangeWithEncodedKeypath:(const SOEncodedKeyPath *)encodedKey
                                                data:(NSData *)data
                                            filename:(NSString *)filename
                                                note:(NSString *)note {
    SOChange * change = [SOChange resourceChangeWithEncodedKeyPath:encodedKey
                                                              data:data
                                                          filename:filename
                                                      contentScale:0
                                                       contentType:kSOChangeResourceNSData
                                                              note:note
                                                              hash:@""];
    change.iconChange = YES;
    return change;
}

@end
