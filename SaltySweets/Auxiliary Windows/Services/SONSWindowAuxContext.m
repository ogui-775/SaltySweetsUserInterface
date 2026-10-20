//Created by Salty on 4/18/26.

#import "SONSWindowAuxContext.h"

@interface SONSWindowAuxContextSicon (Private)
- (instancetype)initWithURL:(NSURL *)url;
@end

@interface SONSWindowAuxContextDockCaarCreation (Private)
- (instancetype)initWithURL:(NSURL *)URL;
@end

@implementation SONSWindowAuxContext
+ (SONSWindowAuxContextSicon *)siconViewerContextWithURL:(NSURL *)url{
    return [[SONSWindowAuxContextSicon alloc] initWithURL:url];
}

+ (SONSWindowAuxContextSiconCreation *)siconCreationContext{
    return [[SONSWindowAuxContextSiconCreation alloc] init];
}

+ (SONSWindowAuxContextDockCaarCreation *)dockCaarCreationContextWithURL:(NSURL *)URL{
    return [[SONSWindowAuxContextDockCaarCreation alloc] initWithURL:URL];
}
@end

@implementation SONSWindowAuxContextSicon
- (instancetype)initWithURL:(NSURL *)url{
    if (self = [super init]){
        SOSicon *siconBundle =
            [[SOSicon alloc] initWithURL:url];
        
        if (!siconBundle)
            return nil;
        
        self.loadedSicon = siconBundle;
        
        NSData *siconData = [self.loadedSicon blobData];
        
        if (!siconData)
            return nil;
        
        self.loadedSiconBlob = siconData;
        
        self.loadedSiconImageCount = [self.loadedSicon imageCount];
    }
    return self;
}
@end

@implementation SONSWindowAuxContextSiconCreation
- (instancetype)init{
    if (self = [super init]){
        self.loadedSicon = nil;
    }
    return self;
}
@end

@implementation SONSWindowAuxContextDockCaarCreation
- (instancetype)initWithURL:(NSURL *)URL{
    self = [super init];
    if (self){
        
    }
    return self;
}
@end
