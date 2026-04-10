#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <SharedKeys/SOSharedKeys.h>

#pragma mark - Forward declaration
@protocol SOConfigurableContentDelegate;
@class    SOConfigurableContentValidation;

#pragma mark - Change types
typedef NSString * SOChangeType NS_TYPED_EXTENSIBLE_ENUM;
FOUNDATION_EXPORT SOChangeType const kSOChangeTypePlist;
FOUNDATION_EXPORT SOChangeType const kSOChangeTypeResource;

#pragma mark - Resource types
typedef NSString * SOChangeResourceType NS_TYPED_EXTENSIBLE_ENUM;
FOUNDATION_EXPORT SOChangeResourceType const kSOChangeResourceTypeNSImage;
FOUNDATION_EXPORT SOChangeResourceType const kSOChangeResourceTypeAIFF;

#pragma mark - Support baseline update directly
FOUNDATION_EXPORT NSString * SONotificationBaseClassUpdateBaseline;

#pragma mark - Change object
@interface SOChange : NSObject

// Entry
@property (nonatomic, copy) SOChangeType changeType;
@property (nonatomic, copy) NSString * changeNote;

// Plist change
@property (nonatomic) const SOEncodedKey * plistKey;
@property (nonatomic) const SOEncodedKeyPath * plistKeyPath;
@property (nonatomic, copy) id plistValue;

// Resource change
@property (nonatomic, copy) SOChangeResourceType resourceType;
@property (nonatomic, copy) id resourceData;
@property (nonatomic, copy) NSString * resourceFilename;
@property (nonatomic) CGFloat resourceContentScale;
@property (nonatomic, copy) NSString * sha256;

+ (instancetype)plistChangeWithEncodedKey:(const SOEncodedKey *)encodedKey
                                    value:(id)value
                                     note:(NSString *)note;

+ (instancetype)plistChangeWithEncodedKeyPath:(const SOEncodedKeyPath *)encodedKey
                                        value:(id)value
                                         note:(NSString *)note;

+ (instancetype)resourceChangeWithEncodedKey:(const SOEncodedKey *)encodedKey
                                       data:(NSData *)data
                                   filename:(NSString *)filename
                                contentScale:(CGFloat)scale
                                 contentType:(SOChangeResourceType)type
                                        note:(NSString *)note
                                        hash:(NSString *)hash;

+ (instancetype)resourceChangeWithEncodedKeyPath:(const SOEncodedKeyPath *)encodedKey
                                            data:(NSData *)data
                                        filename:(NSString *)filename
                                    contentScale:(CGFloat)scale
                                     contentType:(SOChangeResourceType)type
                                            note:(NSString *)note
                                            hash:(NSString *)hash;

@end

#pragma mark - Configurable content
@protocol SOConfigurableContent <NSObject>
@property (nonatomic, strong) id<SOConfigurableContentDelegate> changeDelegate;
@property (nonatomic, strong) NSDictionary * baselineState;
@property (nonatomic, strong) NSMutableArray<SOChange *> * pendingChangeArray;

@optional
- (NSArray<SOChange *> *)pendingChanges;
- (BOOL)validateAndAppendResultTo:(NSMutableArray<SOConfigurableContentValidation *> *)validationResultArray;
- (void)purgePendingChanges;
- (void)refreshOrLoadBaseline;
@end

@protocol SOConfigurableContentDelegate <NSObject>
@property (nonatomic, strong) NSMapTable<id<SOConfigurableContent>, NSArray<SOChange *> *> * pendingChangesCache;

- (void)contentDidChangeState:(id<SOConfigurableContent>)content;
@end

#pragma mark - Configurable content validation
@interface SOConfigurableContentValidation : NSObject
@property (nonatomic, strong) id<SOConfigurableContent> originPage;
@property (nonatomic, assign) BOOL                      overrideable;
@property (nonatomic, assign) unsigned int              severity;
@property (nonatomic, assign) NSString *                message;
@end
