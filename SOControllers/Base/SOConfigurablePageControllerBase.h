//Created by Salty on 2/9/26.

#import <AppKit/AppKit.h>

#import "SOPageControllerBase.h"
#import "../../SaltySweets/SOConfigurableContent.h"
#import "../../SaltySweets/SOSHA256.h"
#import "../../SaltySweets/SOBaseline.h"
#import "../../SaltySweets/SOChangeCompiler.h"

@interface SOConfigurablePageControllerBase : SOPageControllerBase <SOConfigurableContent>
- (void)setPendingChangeForKey:(const SOEncodedKey *)key
                         value:(id)value
                          note:(NSString *)note;

- (void)setPendingBoolChangeForKey:(const SOEncodedKey *)key
                           enabled:(BOOL)enabled
                              note:(NSString *)note;

- (void)setPendingChangeForKeypath:(const SOEncodedKeyPath *)key
                             value:(id)value
                              note:(NSString *)note;

- (void)setPendingResourceChangeForKey:(const SOEncodedKey *)key
                              resource:(id)resource
                                  type:(SOChangeResourceType)type
                              filename:(NSString *)name
                                  note:(NSString *)note;

- (void)setPendingResourceChangeForKey:(const SOEncodedKey *)key
                              resource:(id)resource
                                  type:(SOChangeResourceType)type
                              filename:(NSString *)name
                                  note:(NSString *)note
                          contentScale:(CGFloat)scale;

- (void)setPendingResourceChangeForKeypath:(const SOEncodedKeyPath *)key
                              resource:(id)resource
                                  type:(SOChangeResourceType)type
                              filename:(NSString *)name
                                  note:(NSString *)note;

- (void)setPendingResourceChangeForKeypath:(const SOEncodedKeyPath *)key
                              resource:(id)resource
                                  type:(SOChangeResourceType)type
                              filename:(NSString *)name
                                  note:(NSString *)note
                          contentScale:(CGFloat)scale;

- (void)setPendingIconResourceChangeForKey:(const SOEncodedKey *)key
                                  resource:(NSData *)resource
                                  filename:(NSString *)name
                                      note:(NSString *)note;

- (void)setPendingIconResourceChangeForKeypath:(const SOEncodedKeyPath *)key
                                      resource:(id)resource
                                      filename:(NSString *)name
                                          note:(NSString *)note;

- (id)getBaselineForEncodedKey:(const SOEncodedKey *)key;

//- (void)setChangeObject:(SOChange *)change forEncodedKey:(const SOEncodedKey *)key;

- (id)getBaselineForEncodedKeypath:(const SOEncodedKeyPath *)path;

//- (void)setChangeObject:(SOChange *)change forEncodedKeypath:(const SOEncodedKeyPath *)path;

- (NSImage *)loadImageForEncodedKey:(const SOEncodedKey *)key;

- (NSImage *)loadImageForEncodedKeypath:(const SOEncodedKeyPath *)path;

- (NSString *)getRelativePathForHash:(NSString *)hash;

@end
