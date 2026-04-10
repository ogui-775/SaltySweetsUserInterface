//Created by Salty on 2/9/26.

#import "SOConfigurablePageControllerBase.h"

@implementation SOConfigurablePageControllerBase

@synthesize changeDelegate = _changeDelegate;
@synthesize baselineState = _baselineState;
@synthesize pendingChangeArray = _pendingChangeArray;

- (void)awakeFromNib{
    [super awakeFromNib];
    if (!self.baselineState)
        self.baselineState = [SOBaseline retriveOrCreateBaseline];
    
    if (!self.pendingChangeArray)
        self.pendingChangeArray = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(directiveUpdateToBaselineFromExternalNotification:)
                                                 name:SONotificationBaseClassUpdateBaseline
                                               object:nil];
}

- (void)directiveUpdateToBaselineFromExternalNotification:(NSNotification *)aNotification{
    self.baselineState = [SOBaseline retriveOrCreateBaseline];
}

- (void)setPendingChangeForKey:(const SOEncodedKey *)key
                         value:(id)value
                          note:(NSString *)note {
    if (!self.baselineState) return;

    id baselineValue = [self getBaselineForEncodedKey:key];

    if ((baselineValue == nil && value != nil) || (baselineValue != nil && ![baselineValue isEqual:value])) {
        // value differs, add/update change
        SOChange * change = [SOChange plistChangeWithEncodedKey:key value:value note:note];
        [self setChangeObject:change forEncodedKey:key];
    } else {
        // value same as baseline, remove change
        [self setChangeObject:nil forEncodedKey:key];
    }

    [self.changeDelegate contentDidChangeState:self];
}

- (void)setPendingChangeForKeypath:(const SOEncodedKeyPath *)key
                             value:(id)value
                              note:(NSString *)note{
    if (!self.baselineState) return;
    
    id baselineValue = [self getBaselineForEncodedKeypath:key];
    
    if ((baselineValue == nil && value != nil) || (baselineValue != nil && ![baselineValue isEqual:value])){
        SOChange * change = [SOChange plistChangeWithEncodedKeyPath:key value:value note:note];
        [self setChangeObject:change forEncodedKeypath:key];
    } else {
        [self setChangeObject:nil forEncodedKeypath:key];
    }
    
    [self.changeDelegate contentDidChangeState:self];
}

- (void)setPendingBoolChangeForKey:(const SOEncodedKey *)key
                           enabled:(BOOL)enabled
                              note:(NSString *)note {
    [self setPendingChangeForKey:key value:@(enabled) note:note];
}

//Resource changes
- (void)setPendingResourceChangeForKey:(const SOEncodedKey *)key
                              resource:(id)resource
                                  type:(SOChangeResourceType)type
                              filename:(NSString *)name
                                  note:(NSString *)note
                          contentScale:(CGFloat)scale{
    if (!self.baselineState) return;
    
    NSData * raw = [self getDataOfResource:resource typed:type];
    //Hash compare the resource bytes to the original (or to nil, if the original was no resource as determined by baseline)
    NSString * hash;
    if (!raw){
        hash = kSODockResourceNotProvided;
    } else {
        hash = [SOSHA256 sha256FromData:raw key:key];
    }
    
    id baselineValue = [self getBaselineForEncodedKey:key];
    //If hash differs from baseline (NSString * returned from getBaselineForEncodedKey:) then add as a SOChange * for the compiler to handle
    //delta of within SOChangeCompiler.m and finalize into the NSBundle
    if ((baselineValue == nil && ![hash isEqualToString:kSODockResourceNotProvided]) ||
        (baselineValue != nil && ![baselineValue isEqualToString:hash])) {
        SOChange * change = [SOChange resourceChangeWithEncodedKey:key
                                                              data:raw
                                                          filename:name
                                                      contentScale:scale
                                                       contentType:type
                                                              note:note
                                                              hash:hash];
        
        [self setChangeObject:change forEncodedKey:key];
    } else {
        [self setChangeObject:nil forEncodedKey:key];
    }
    
    [self.changeDelegate contentDidChangeState:self];
}

- (void)setPendingResourceChangeForKeypath:(const SOEncodedKeyPath *)key
                                  resource:(id)resource
                                      type:(SOChangeResourceType)type
                                  filename:(NSString *)name
                                      note:(NSString *)note
                              contentScale:(CGFloat)scale{
    if (!self.baselineState) return;
    
    NSData * raw = [self getDataOfResource:resource typed:type];
    
    NSString * hash;
    if (!raw){
        hash = kSODockResourceNotProvided;
    } else {
        hash = [SOSHA256 sha256FromData:raw keypath:key];
    }
    
    id baselineValue = [self getBaselineForEncodedKeypath:key];
    
    if ((baselineValue == nil && ![hash isEqualToString:kSODockResourceNotProvided]) ||
        (baselineValue != nil && ![baselineValue isEqualToString:hash])) {
        SOChange * change = [SOChange resourceChangeWithEncodedKeyPath:key
                                                                  data:raw
                                                              filename:name
                                                          contentScale:scale
                                                           contentType:type
                                                                  note:note
                                                                  hash:hash];
        
        [self setChangeObject:change forEncodedKeypath:key];
    } else {
        [self setChangeObject:nil forEncodedKeypath:key];
    }
    
    [self.changeDelegate contentDidChangeState:self];
}

- (void)setPendingResourceChangeForKey:(const SOEncodedKey *)key
                              resource:(id)resource
                                  type:(SOChangeResourceType)type
                              filename:(NSString *)name
                                  note:(NSString *)note{
    [self setPendingResourceChangeForKey:key resource:resource type:type filename:name note:note contentScale:1.0];
}

- (void)setPendingResourceChangeForKeypath:(const SOEncodedKeyPath *)key
                                  resource:(id)resource
                                      type:(SOChangeResourceType)type
                                  filename:(NSString *)name
                                      note:(NSString *)note{
    [self setPendingResourceChangeForKeypath:key resource:resource type:type filename:name note:note contentScale:1.0];
}

- (NSData *)getDataOfResource:(id)resource
                        typed:(SOChangeResourceType)type{
    if (!resource)
        return nil;

    if ([resource isKindOfClass:[NSData class]]) {
        return resource;
    }
    
    if ([resource isKindOfClass:[NSURL class]]) {
        return [NSData dataWithContentsOfURL:resource];
    }

    if (type == kSOChangeResourceTypeNSImage) {

        NSImage * image = nil;

        if ([resource isKindOfClass:[NSImage class]]) {
            image = resource;
        } else {
            return nil;
        }

        CGImageRef cgImage = [image CGImageForProposedRect:NULL
                                                   context:nil
                                                     hints:nil];
        if (!cgImage)
            return nil;

        NSMutableData * pngData = [NSMutableData data];

        CGImageDestinationRef dest =
            CGImageDestinationCreateWithData((__bridge CFMutableDataRef)pngData,
                                             (__bridge CFStringRef)UTTypePNG.identifier,
                                             1,
                                             NULL);

        if (!dest)
            return nil;

        CGImageDestinationAddImage(dest, cgImage, NULL);
        CGImageDestinationFinalize(dest);
        CFRelease(dest);

        return pngData;
    }

    return nil;
}


//Annoyance helpers
- (id)getBaselineForEncodedKey:(const SOEncodedKey *)key{
    return self.baselineState[key->key];
}

- (void)setChangeObject:(SOChange *)change
          forEncodedKey:(const SOEncodedKey *)key
{
    NSIndexSet * indexes = [self.pendingChangeArray indexesOfObjectsPassingTest:^BOOL(SOChange * obj, NSUInteger idx, BOOL * stop) {
        return obj.plistKey && [obj.plistKey->key isEqualToString:key->key];
    }];

    if (indexes.count > 0) {
        [self.pendingChangeArray removeObjectsAtIndexes:indexes];
    }

    if (change) {
        [self.pendingChangeArray addObject:change];
    }
}

- (id)getBaselineForEncodedKeypath:(const SOEncodedKeyPath *)path {
    NSDictionary * dict = self.baselineState[path->rootKey->key];
    for (NSString * component in path->components) {
        dict = dict[component];
    }
    return dict;
}

- (void)setChangeObject:(SOChange *)change
      forEncodedKeypath:(const SOEncodedKeyPath *)path {
    NSIndexSet * indexes =
        [self.pendingChangeArray indexesOfObjectsPassingTest:^BOOL(SOChange * obj, NSUInteger idx, BOOL *stop) {
            return SOEncodedKeyPathEqual(obj.plistKeyPath, path);
        }];

    if (indexes.count > 0) {
        [self.pendingChangeArray removeObjectsAtIndexes:indexes];
    }

    if (change) {
        [self.pendingChangeArray addObject:change];
    }
}

- (NSImage *)loadImageForEncodedKey:(const SOEncodedKey *)key{
    NSString * hash = [self getBaselineForEncodedKey:key];
    NSString * relativePath = [self getRelativePathForHash:hash];
    if (![hash isEqualToString:kSODockResourceNotProvided] &&
        ![relativePath isEqualToString:kSODockResourceNotProvided]){
        NSBundle * themeBundle = [AppDelegate currentThemeBundle];

        NSURL * path = [[themeBundle resourceURL] URLByAppendingPathComponent:relativePath];
        if (!path)
            return nil;

        return [[NSImage alloc] initWithContentsOfURL:path];
    } else {
        return nil;
    }
}

- (NSImage *)loadImageForEncodedKeypath:(const SOEncodedKeyPath *)path{
    NSString * hash = [self getBaselineForEncodedKeypath:path];
    NSString * relativePath = [self getRelativePathForHash:hash];
    if (![hash isEqualToString:kSODockResourceNotProvided] &&
        ![relativePath isEqualToString:kSODockResourceNotProvided]){
        NSBundle * themeBundle = [AppDelegate currentThemeBundle];

        NSURL * path = [[themeBundle resourceURL] URLByAppendingPathComponent:relativePath];
        if (!path)
            return nil;

        return [[NSImage alloc] initWithContentsOfURL:path];
    } else {
        return nil;
    }
}

- (NSString *)getRelativePathForHash:(NSString *)hash{
    NSDictionary * hashToRelative = self.baselineState[kSODockResourceHashToFilename.key];
    NSString * relativePath       = hashToRelative[hash];
    if (relativePath)
        return relativePath;
    
    return @"";
}

BOOL SOEncodedKeyPathEqual(const SOEncodedKeyPath *a,
                           const SOEncodedKeyPath *b) {
    if (!a || !b)
        return NO;
    
    if (a->components.count != b->components.count)
        return NO;

    if (![a->rootKey->key isEqualToString:b->rootKey->key])
        return NO;

    for (NSUInteger i = 0; i < a->components.count; i++) {
        if (![a->components[i] isEqualToString:b->components[i]])
            return NO;
    }

    return YES;
}

//Delegate callback
- (NSArray<SOChange *> *)pendingChanges {
    return [self.pendingChangeArray copy];
}

- (void)purgePendingChanges{
    [self.pendingChangeArray removeAllObjects];
}
@end
