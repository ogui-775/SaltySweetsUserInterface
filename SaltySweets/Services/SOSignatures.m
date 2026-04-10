//Created by Salty on 2/16/26.

#import "SOSignatures.h"

@implementation SOSignatures

+ (BOOL)signThemeBundle:(NSBundle *)bundle{
    if (![SOSignatures authoringKeypairExists])
        return NO;
    
    NSFileManager * fm   = [NSFileManager defaultManager];
    CFErrorRef error     = NULL;
    
    
    NSData * privateKeyData =[NSData dataWithContentsOfFile:[[AppDelegate cryptoKeyDir] stringByAppendingPathComponent:@"privatekey.rsa"]];
    
    if (!privateKeyData)
        return NO;
    
    SecKeyRef privateKey = SecKeyCreateWithData((__bridge CFDataRef)privateKeyData,
                                                (__bridge CFDictionaryRef)@{
                                                    (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                                                    (id)kSecAttrKeyClass:(id)kSecAttrKeyClassPrivate
                                                },
                                                &error);
    
    if (!privateKey)
        return NO;
    
    NSDictionary * themePlist = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"theme.plist" ofType:@""]];
    
    if (!themePlist){
        CFRelease(privateKey);
        return NO;
    }
    
    NSData * signedDataPay = [NSPropertyListSerialization dataWithPropertyList:themePlist
                                                                       format:NSPropertyListBinaryFormat_v1_0
                                                                      options:0
                                                                        error:NULL];
    
    CFDataRef signatureData   = SecKeyCreateSignature(privateKey,
                                                      kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256,
                                                      (__bridge CFDataRef)signedDataPay,
                                                      &error);
    
    CFRelease(privateKey);
    if (!signatureData)
        return NO;
    
    NSData * signatureData_ns = (NSData *)CFBridgingRelease(signatureData);
    
    BOOL wrote = NO;
    NSError * err_ns = nil;
    
    wrote = [fm createFileAtPath:[[bundle resourcePath] stringByAppendingPathComponent:@"signature.sec"]
                contents:signatureData_ns
              attributes:nil];
    
    if (![fm fileExistsAtPath:[[bundle resourcePath] stringByAppendingPathComponent:@"publickey.txt"]])
        wrote = [fm copyItemAtPath:[[AppDelegate cryptoKeyDir] stringByAppendingPathComponent:@"publickey.txt"]
                    toPath:[[bundle resourcePath] stringByAppendingPathComponent:@"publickey.txt"]
                     error:&err_ns];
    
    if (err_ns){
        NSLog(@"%@", err_ns);
        return NO;
    }
    
    return wrote;
}

+ (BOOL)verifyThemeAuthorship:(NSBundle *)bundle {
    NSDictionary * themePlist = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"theme.plist" ofType:@""]];
    if (!themePlist)
        return NO;

    NSData * signedDataPay = [NSPropertyListSerialization dataWithPropertyList:themePlist
                                                                       format:NSPropertyListBinaryFormat_v1_0
                                                                      options:0
                                                                        error:NULL];
    
    NSString * resourceDir = bundle.resourcePath;

    NSString * pkeyPath = [resourceDir stringByAppendingPathComponent:@"publickey.txt"];
    NSString * sigPath  = [resourceDir stringByAppendingPathComponent:@"signature.sec"];
    
    NSData * publicKeyData = [NSData dataWithContentsOfFile:pkeyPath];
    NSData * signatureData = [NSData dataWithContentsOfFile:sigPath];
    
    if (!publicKeyData || !signatureData)
        return NO;

    CFErrorRef error = NULL;
    SecKeyRef publicKey = SecKeyCreateWithData((__bridge CFDataRef)publicKeyData,
                                               (__bridge CFDictionaryRef)@{
                                                   (id)kSecAttrKeyType : (id)kSecAttrKeyTypeRSA,
                                                   (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPublic
                                               },
                                               &error);

    if (!publicKey) {
        if (error) CFRelease(error);
        return NO;
    }

    BOOL verified = SecKeyVerifySignature(publicKey,
                                          kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256,
                                          (__bridge CFDataRef)signedDataPay,
                                          (__bridge CFDataRef)signatureData,
                                          &error);

    CFRelease(publicKey);
    if (error)
        CFRelease(error);

    return verified;
}


+ (BOOL)authoringKeypairExists{
    NSFileManager * fm = [NSFileManager defaultManager];

    NSArray<NSString *> * dirContent = [fm contentsOfDirectoryAtPath:[AppDelegate cryptoKeyDir] error:nil];
    
    NSIndexSet * idxs = [dirContent indexesOfObjectsPassingTest:^BOOL(NSString * obj, NSUInteger idx, BOOL * stop) {
        return [obj containsString:@"key"];
    }];
    
    if (idxs.count > 1)
        return YES;
    
    return NO;
}

+ (void)generateAndStoreAuthoringKeypair{
    if ([SOSignatures authoringKeypairExists]){
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText =
            @"You cannot create signing keys as a pair already exists. You must delete or relocate the keys to create a new pair.";
        alert.alertStyle  =
            NSAlertStyleInformational;
        [alert beginSheetModalForWindow:[[NSApplication sharedApplication] windows][0] completionHandler:nil];
        return;
    }
    
    NSString * authorName = [AppDelegate appSetAuthorName];
    
    if (!authorName || [authorName isEqualToString:@""]){
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = @"You cannot create signing keys without first setting your name.";
        alert.alertStyle  = NSAlertStyleInformational;
        [alert beginSheetModalForWindow:[[NSApplication sharedApplication] windows][0] completionHandler:nil];
        return;
    }
    
    NSData * tag = [[NSString stringWithFormat:@"com.saltysoft.keys.%@-%@", authorName, NSDate.now] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary * attrs = @{
        (id)kSecAttrKeyType : (id)kSecAttrKeyTypeRSA,
        (id)kSecAttrKeySizeInBits : @2048,
        (id)kSecPrivateKeyAttrs : @{
            (id)kSecAttrIsPermanent :   @NO,
            (id)kSecAttrApplicationTag: tag
        }
    };
    
    CFErrorRef error = NULL;
    
    SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attrs, &error);
    
    if (!privateKey){
        NSError * err_ns = CFBridgingRelease(error);
        NSAlert * alert  = [[NSAlert alloc] init];
        alert.messageText= [NSString stringWithFormat:@"Key generation failed: %@", err_ns];
        [alert beginSheetModalForWindow:[[NSApplication sharedApplication] windows][0] completionHandler:nil];
        return;
    }
    
    SecKeyRef publicKey = SecKeyCopyPublicKey(privateKey);
    
    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSData * privateData = (NSData *)CFBridgingRelease(SecKeyCopyExternalRepresentation(privateKey, NULL));
    NSData * publicData  = (NSData *)CFBridgingRelease(SecKeyCopyExternalRepresentation(publicKey,  NULL));
    
    [fm createFileAtPath:[[AppDelegate cryptoKeyDir] stringByAppendingPathComponent:@"privatekey.rsa"]
                contents:privateData
              attributes:nil];
    
    [fm createFileAtPath:[[AppDelegate cryptoKeyDir] stringByAppendingPathComponent:@"publickey.txt"]
                contents:publicData
              attributes:nil];
    
    return;
}

+ (NSString *)themeAuthorFingerprint:(NSBundle *)bundle{
    NSString * pubPath = [bundle.resourcePath stringByAppendingPathComponent:@"publickey.txt"];
    NSData * publicKeyData = [NSData dataWithContentsOfFile:pubPath];
    
    if (!publicKeyData)
        return nil;
    
    uint8_t hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(publicKeyData.bytes, (CC_LONG)publicKeyData.length, hash);
    
    NSMutableString * fingerprint = [NSMutableString string];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [fingerprint appendFormat:@"%02X", hash[i]];
        
        if ((i % 2 == 1) && i != CC_SHA256_DIGEST_LENGTH - 1) {
            [fingerprint appendString:@":"];
        }
    }
    
    return fingerprint;
}

@end
