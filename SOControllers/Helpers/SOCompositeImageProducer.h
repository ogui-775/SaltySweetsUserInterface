//Created by Salty on 4/17/26.

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "../../ext/SOSharedIOSurfaceUtils.h"

#import "../../SaltySweets/AppDelegate.h"

@interface SOCompositeImageProducer : NSObject
+ (CGImageRef)requestIOSurfaceCompositeForCompositeKey:(NSString *)key;
@end
