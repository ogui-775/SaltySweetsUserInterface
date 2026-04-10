//Created by Salty on 2/21/26.

#import <AppKit/AppKit.h>
#import "../../SaltySweets/SOConfigurableContent.h"
#import "../Base/SOConfigurablePageControllerBase.h"

@interface SOScaleImageManager : NSObject
@property (weak) SOConfigurablePageControllerBase * owner;

@property (strong, atomic) NSMapTable * scale1xMapToImage;
@property (strong, atomic) NSMapTable * scale2xMapToImage;
@property (strong, atomic) NSMapTable * scale1xMapToKey;
@property (strong, atomic) NSMapTable * scale2xMapToKey;

@property (assign) int currentScale;

- (instancetype)initWithOwner:(SOConfigurablePageControllerBase *)owner currentScale:(int)scale;
- (void)baselineDidRefresh;
- (void)scaleDidChangeTo:(int)scale;
- (void)registerObject:(id)object withEncodedKeypath:(const SOEncodedKeyPath *)key scale:(int)scale;
- (void)setImage:(NSImage *)image forRegisteredObject:(id)object;
@end
