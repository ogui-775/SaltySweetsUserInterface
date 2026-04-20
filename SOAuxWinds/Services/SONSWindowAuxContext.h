//Created by Salty on 4/18/26.

#import <AppKit/AppKit.h>
#import <SharedKeys/SharedKeys.h>

@class SONSWindowAuxContextSicon;

@interface SONSWindowAuxContext : NSObject
+ (SONSWindowAuxContextSicon *)siconViewerContextWithURL:(NSURL *)url;
@end

@interface SONSWindowAuxContextSicon : SONSWindowAuxContext
@property (strong) NSURL * loadedSicon;
@property (strong) NSDictionary * loadedSiconInfo;
@property (strong) NSDictionary * loadedSiconManifest;
@property (assign) size_t loadedSiconImageCount;
@end
