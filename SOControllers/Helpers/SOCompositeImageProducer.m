//Created by Salty on 4/17/26.

#import "SOCompositeImageProducer.h"

@implementation SOCompositeImageProducer
+ (CGImageRef)requestIOSurfaceCompositeForToken:(SOIconIOSurfaceRequestToken *)token{
    return [SOSharedIOSurfaceUtils copyImageForToken:token connection:[[SOAtomicAccessPoint sharedInstance] appIconServerConnection]];
}
@end
