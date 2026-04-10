//Created by Salty on 3/5/26.

#import <AppKit/AppKit.h>
#import "../../SaltySweets/SOConfigurableContent.h"
#import "../Base/SOConfigurablePageControllerBase.h"

@interface SOScaleControlValueManager : NSObject

@property (weak) SOConfigurablePageControllerBase * owner;

@property (strong, atomic) NSMapTable * scale1xMapToValue;
@property (strong, atomic) NSMapTable * scale2xMapToValue;
@property (strong, atomic) NSMapTable * scale1xMapToKey;
@property (strong, atomic) NSMapTable * scale2xMapToKey;
@property (strong, atomic) NSMapTable * scale1xMapToValueType;
@property (strong, atomic) NSMapTable * scale2xMapToValueType;

@property (assign) int currentScale;

- (instancetype)initWithOwner:(SOConfigurablePageControllerBase *)owner currentScale:(int)scale;
- (void)baselineDidRefresh;
- (void)scaleDidChangeTo:(int)scale;
- (void)registerObject:(id)object withEncodedKeypath:(const SOEncodedKeyPath *)key scale:(int)scale valueType:(SOValueEncoding)valueType;
- (void)setValue:(id)value forRegisteredObject:(id)object;
@end
