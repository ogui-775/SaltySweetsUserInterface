//Created by Salty on 3/5/26.

#import "SOScaleControlValueManager.h"

@implementation SOScaleControlValueManager

- (instancetype)initWithOwner:(SOConfigurablePageControllerBase *)owner currentScale:(int)scale{
    self = [super init];
    if (self) {
        self.scale1xMapToValue = [NSMapTable weakToStrongObjectsMapTable];
        self.scale2xMapToValue = [NSMapTable weakToStrongObjectsMapTable];
        self.scale1xMapToKey   = [NSMapTable weakToStrongObjectsMapTable];
        self.scale2xMapToKey   = [NSMapTable weakToStrongObjectsMapTable];
        self.scale1xMapToValueType = [NSMapTable weakToStrongObjectsMapTable];
        self.scale2xMapToValueType = [NSMapTable weakToStrongObjectsMapTable];
        self.currentScale = scale;
        self.owner = owner;
    }
    return self;
}

- (void)registerObject:(id)object withEncodedKeypath:(const SOEncodedKeyPath *)key scale:(int)scale valueType:(SOValueEncoding)valueType{
    SOEncodedKeyPath * replKey = malloc(sizeof(SOEncodedKeyPath));
    replKey->components = key->components;
    replKey->rootKey    = key->rootKey;
    
    if (scale == 1){
        [self.scale1xMapToKey setObject:[NSValue valueWithPointer:replKey] forKey:object];
        [self.scale1xMapToValue setObject:[self.owner getBaselineForEncodedKeypath:key] forKey:object];
        [self.scale1xMapToValueType setObject:@(valueType) forKey:object];
        if (scale == self.currentScale) {
            [self setValue:[self.scale1xMapToValue objectForKey:object] forRegisteredObject:object];
        }
    } else if (scale == 2){
        [self.scale2xMapToKey setObject:[NSValue valueWithPointer:replKey] forKey:object];
        [self.scale2xMapToValue setObject:[self.owner getBaselineForEncodedKeypath:key] forKey:object];
        [self.scale2xMapToValueType setObject:@(valueType) forKey:object];
        if (scale == self.currentScale) {
            [self setValue:[self.scale2xMapToValue objectForKey:object] forRegisteredObject:object];
        }
    }
}

- (void)baselineDidRefresh{
    int scale = self.currentScale;
    
    for (id obj in self.scale1xMapToKey){
        NSValue * val = [self.owner getBaselineForEncodedKeypath:[[self.scale1xMapToKey objectForKey:obj] pointerValue]];
        if (val){
            [self.scale1xMapToValue setObject:val forKey:obj];
        } else {
            [self.scale1xMapToValue removeObjectForKey:obj];
        }
    }
    
    for (id obj in self.scale2xMapToKey){
        NSValue * val = [self.owner getBaselineForEncodedKeypath:[[self.scale2xMapToKey objectForKey:obj] pointerValue]];
        if (val){
            [self.scale2xMapToValue setObject:val forKey:obj];
        } else {
            [self.scale2xMapToValue removeObjectForKey:obj];
        }
    }
    
    [self scaleDidChangeTo:scale];
}

- (void)scaleDidChangeTo:(int)scale{
    self.currentScale = scale;
    if (scale == 1){
        for (id obj in self.scale1xMapToKey){
            NSValue * val = [self.scale1xMapToValue objectForKey:obj];
            [self setValue:val forRegisteredObject:obj];
        }
    } else if (scale == 2){
        for (id obj in self.scale2xMapToKey){
            NSValue * val = [self.scale2xMapToValue objectForKey:obj];
            [self setValue:val forRegisteredObject:obj];
        }
    }
}
- (void)setValue:(id)value forRegisteredObject:(id)object {
    NSMapTable * valueTable = self.currentScale == 1 ? self.scale1xMapToValue : self.scale2xMapToValue;
    NSMapTable * valueTypeTable = self.currentScale == 1 ? self.scale1xMapToValueType : self.scale2xMapToValueType;
    
    if (value){
        [valueTable setObject:value forKey:object];
    } else {
        [valueTable removeObjectForKey:object];
    }
    

    if ([[valueTypeTable objectForKey:object] intValue] == SOValueEncodingCGFloat) {
        CGFloat outDouble;
        [value getValue:&outDouble];
        [(NSControl *)object setDoubleValue:outDouble];
    } else if ([[valueTypeTable objectForKey:object] intValue] == SOValueEncodingNSString){
        [(NSControl *)object setStringValue:(NSString *)value];
    }
    else {
        NSLog(@"[SOScaleControlValueManager] Unknown registered value type for object: %@", object);
    }
}

- (void)dealloc {
    for (id obj in self.scale1xMapToKey) {
        NSValue * val = [self.scale1xMapToKey objectForKey:obj];
        free([val pointerValue]);
    }

    for (id obj in self.scale2xMapToKey) {
        NSValue * val = [self.scale2xMapToKey objectForKey:obj];
        free([val pointerValue]);
    }
}


@end
