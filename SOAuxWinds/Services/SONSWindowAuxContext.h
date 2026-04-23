//Created by Salty on 4/18/26.

#import <AppKit/AppKit.h>
#import <SharedKeys/SharedKeys.h>
#import <SharedBundles/SharedBundles.h>

@class SONSWindowAuxContextSicon;
@class SONSWindowAuxContextSiconCreation;

@interface SONSWindowAuxContext : NSObject
+ (SONSWindowAuxContextSicon *)siconViewerContextWithURL:(NSURL *)url;
+ (SONSWindowAuxContextSiconCreation *)siconCreationContext;
@end

@interface SONSWindowAuxContextSicon : SONSWindowAuxContext
@property (strong) SOSiconBundle *loadedSicon;
@property (assign) size_t loadedSiconImageCount;
@property (strong) NSData *loadedSiconBlob;
@end

@interface SONSWindowAuxContextSiconCreation : SONSWindowAuxContext

@end
