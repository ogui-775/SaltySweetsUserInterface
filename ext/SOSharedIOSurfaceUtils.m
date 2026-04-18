//Created by Salty on 4/17/26.

#import "SOSharedIOSurfaceUtils.h"
#import "../../icon-server/icon-server/SOIconServerXPCProtocol.h"

@implementation SOSharedIOSurfaceUtils
+ (NSString *)settingsPath{
    NSString * appSupport =
        NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                            NSUserDomainMask,
                                            YES).firstObject;
    
    NSString * dir = [appSupport stringByAppendingPathComponent:@"SaltySweets"];
    NSString * iconsDir = [dir stringByAppendingPathComponent:@"Icons"];
    return [iconsDir stringByAppendingPathComponent:@"iconsettings.plist"];
}

+ (NSString *)createCompositeWithArray:(NSArray<NSString *> *)strings baseSize:(CGSize)baseSize{
    NSString * sizeAppend = [NSString stringWithFormat:@"%fx%f", baseSize.width, baseSize.height];
    strings = [strings arrayByAddingObject:sizeAppend];
    
    return [strings componentsJoinedByString:@"|"];
}

+ (CGImageRef)copyImageForComposite:(NSString *)key connection:(NSXPCConnection *)xpc_connection{
    if (!key || [key isEqualToString:@""])
        return nil;

    __block IOSurface * surface = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    id proxy = [xpc_connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        NSLog(@"XPC Error: %@", error);
        dispatch_semaphore_signal(sema);
    }];

    [proxy getSurfaceRefForComposite:key withReply:^(IOSurface *s) {
        surface = s;
        dispatch_semaphore_signal(sema);
    }];

    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    if (dispatch_semaphore_wait(sema, timeout) != 0) {
        NSLog(@"XPC timeout elapsed (1.00 sec) for key: %@. Using default return value.", key);
    }

    IOSurface * strongSurface = surface;
    if (!strongSurface) return NULL;

    return
        [self createCGImageFromIOSurface:strongSurface];
}

+ (CGImageRef)createCGImageFromIOSurface:(IOSurface *)surface {
    IOSurfaceRef surfaceRef = (__bridge IOSurfaceRef)surface;
    
    CGImageRef image = CGImageCreateFromIOSurface(surfaceRef, 0);

    return image;
}

+ (NSDictionary *)iconsSettingsWithXPCConnection:(NSXPCConnection *)xpc_connection {
    NSDictionary * local = [NSDictionary dictionaryWithContentsOfFile:[SOSharedIOSurfaceUtils settingsPath]];
    
    if (!local){
        __block NSDictionary * settings = nil;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);

        id proxy = [xpc_connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
            NSLog(@"XPC Error: %@", error);
            dispatch_semaphore_signal(sema);
        }];

        [proxy getServiceSettingsWithReply:^(NSDictionary *d) {
            settings = d;
            dispatch_semaphore_signal(sema);
        }];

        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        if (dispatch_semaphore_wait(sema, timeout) != 0) {
            NSLog(@"XPC timeout elapsed (1 sec) for settings.");
        }

        local = settings;
    }
    
    return local;
}

@end
