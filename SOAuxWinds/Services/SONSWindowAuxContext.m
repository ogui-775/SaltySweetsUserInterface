//Created by Salty on 4/18/26.

#import "SONSWindowAuxContext.h"

@interface SONSWindowAuxContextSicon (Private)
- (instancetype)initWithURL:(NSURL *)url;
@end

@implementation SONSWindowAuxContext
+ (SONSWindowAuxContextSicon *)siconViewerContextWithURL:(NSURL *)url{
    return [[SONSWindowAuxContextSicon alloc] initWithURL:url];
}

+ (SONSWindowAuxContextSiconCreation *)siconCreationContext{
    return [[SONSWindowAuxContextSiconCreation alloc] init];
}
@end

@implementation SONSWindowAuxContextSicon
- (instancetype)initWithURL:(NSURL *)url{
    if (self = [super init]){
        SOSiconBundle *siconBundle =
            [SOSiconBundle bundleWithURL:url];
        
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

    }
    return self;
}
@end
