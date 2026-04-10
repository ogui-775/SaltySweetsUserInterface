//Created by Salty on 2/21/26.

#import "SOScaleImageManager.h"

@implementation SOScaleImageManager

- (instancetype)initWithOwner:(SOConfigurablePageControllerBase *)owner currentScale:(int)scale{
    self = [super init];
    if (self) {
        self.scale1xMapToImage = [NSMapTable weakToStrongObjectsMapTable];
        self.scale2xMapToImage = [NSMapTable weakToStrongObjectsMapTable];
        self.scale1xMapToKey   = [NSMapTable weakToStrongObjectsMapTable];
        self.scale2xMapToKey   = [NSMapTable weakToStrongObjectsMapTable];
        self.currentScale = scale;
        self.owner = owner;
    }
    return self;
}

- (void)registerObject:(id)object withEncodedKeypath:(const SOEncodedKeyPath *)key scale:(int)scale{
    SOEncodedKeyPath * replKey = malloc(sizeof(SOEncodedKeyPath));
    replKey->components = key->components;
    replKey->rootKey    = key->rootKey;
    
    if (scale == 1){
        [self.scale1xMapToKey setObject:[NSValue valueWithPointer:replKey] forKey:object];
        [self.scale1xMapToImage setObject:[self.owner loadImageForEncodedKeypath:replKey] forKey:object];
        if (scale == self.currentScale) {
            [self setImage:[self.scale1xMapToImage objectForKey:object] forRegisteredObject:object];
        }
    } else if (scale == 2){
        [self.scale2xMapToKey setObject:[NSValue valueWithPointer:replKey] forKey:object];
        [self.scale2xMapToImage setObject:[self.owner loadImageForEncodedKeypath:replKey] forKey:object];
        if (scale == self.currentScale) {
            [self setImage:[self.scale2xMapToImage objectForKey:object] forRegisteredObject:object];
        }
    }
}

- (void)baselineDidRefresh{
    int scale = self.currentScale;
    
    for (id obj in self.scale1xMapToKey){
        NSImage * img = [self.owner loadImageForEncodedKeypath:[[self.scale1xMapToKey objectForKey:obj] pointerValue]];
        if (img){
            [self.scale1xMapToImage setObject:img forKey:obj];
        } else {
            [self.scale1xMapToImage removeObjectForKey:obj];
        }
    }
    
    for (id obj in self.scale2xMapToKey){
        NSImage * img = [self.owner loadImageForEncodedKeypath:[[self.scale2xMapToKey objectForKey:obj] pointerValue]];
        if (img){
            [self.scale2xMapToImage setObject:img forKey:obj];
        } else {
            [self.scale2xMapToImage removeObjectForKey:obj];
        }
    }
    
    [self scaleDidChangeTo:scale];
}

- (void)scaleDidChangeTo:(int)scale{
    self.currentScale = scale;
    if (scale == 1){
        for (id obj in self.scale1xMapToKey){
            NSImage * img = [self.scale1xMapToImage objectForKey:obj];
            [self setImage:img forRegisteredObject:obj];
        }
    } else if (scale == 2){
        for (id obj in self.scale2xMapToKey){
            NSImage * img = [self.scale2xMapToImage objectForKey:obj];
            [self setImage:img forRegisteredObject:obj];
        }
    }
}

- (void)setImage:(NSImage *)image forRegisteredObject:(id)object {
    NSMapTable * imgTable = self.currentScale == 1 ? self.scale1xMapToImage : self.scale2xMapToImage;
    if (image){
        [imgTable setObject:image forKey:object];
    } else {
        [imgTable removeObjectForKey:object];
    }

    if ([object isKindOfClass:[NSImageView class]]) {
        [(NSImageView *)object setImage:image];
    } else if ([object isKindOfClass:[CALayer class]]) {
        [(CALayer *)object setContents:image];
    } else {
        NSLog(@"[SOScaleImageManager] Unknown registered object type: %@", object);
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
