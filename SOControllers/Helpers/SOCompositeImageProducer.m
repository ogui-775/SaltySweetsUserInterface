//Created by Salty on 4/17/26.

#import "SOCompositeImageProducer.h"

@implementation SOCompositeImageProducer
+ (CGImageRef)requestIOSurfaceCompositeForCompositeKey:(NSString *)key{
    return [SOSharedIOSurfaceUtils copyImageForComposite:key connection:[AppDelegate appIconServerConnection]];
}
@end
