//Created by Salty on 4/18/26.

#import "SONSWindowAuxContext.h"

@interface SONSWindowAuxContextSicon (Private)
- (instancetype)initWithURL:(NSURL *)url;
@end

@implementation SONSWindowAuxContext
+ (SONSWindowAuxContextSicon *)siconViewerContextWithURL:(NSURL *)url{
    return [[SONSWindowAuxContextSicon alloc] initWithURL:url];
}
@end

@implementation SONSWindowAuxContextSicon
- (instancetype)initWithURL:(NSURL *)url{
    if (self = [super init]){
        self.loadedSicon = url;
        
        NSBundle * siconBundle =
            [NSBundle bundleWithURL:url];
        
        if (!siconBundle)
            return nil;
        
        self.loadedSiconInfo =
            [siconBundle infoDictionary];
        
        if (!self.loadedSiconInfo)
            return nil;
        
        NSURL * resourceManifestURL =
            [siconBundle URLForResource:@"manifest" withExtension:@"plist"];
        
        self.loadedSiconManifest =
            [NSDictionary dictionaryWithContentsOfURL:resourceManifestURL];
        
        if (!self.loadedSiconManifest)
            return nil;
        
        self.loadedSiconImageCount =
            [[self.loadedSiconManifest objectForKey:kSOSiconImageCount.key] unsignedIntValue];
    }
    return self;
}
@end
