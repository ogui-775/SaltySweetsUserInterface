//Created by Salty on 4/17/26.

#import <Cocoa/Cocoa.h>
#import <IOSurface/IOSurfaceObjC.h>

extern CGImageRef CGImageCreateFromIOSurface(IOSurfaceRef, CFDictionaryRef);

@interface SOSharedIOSurfaceUtils : NSObject
+ (NSString *)createCompositeWithArray:(NSArray<NSString *> *)strings baseSize:(CGSize)baseSize;
+ (NSDictionary *)iconsSettingsWithXPCConnection:(NSXPCConnection *)xpc_connection;
+ (CGImageRef)copyImageForComposite:(NSString *)key connection:(NSXPCConnection *)xpc_connection;
@end
