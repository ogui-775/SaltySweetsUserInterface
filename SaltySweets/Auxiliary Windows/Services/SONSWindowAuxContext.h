//Created by Salty on 4/18/26.

#import <AppKit/AppKit.h>
#import <SharedKeys/SharedKeys.h>
#import <SharedBundles/SharedBundles.h>
#import <SharedClasses/SharedClasses.h>

@class SONSWindowAuxContextSicon;
@class SONSWindowAuxContextSiconCreation;
@class SONSWindowAuxContextDockCaarCreation;

@interface SONSWindowAuxContext : NSObject
+ (SONSWindowAuxContextSicon *)siconViewerContextWithURL:(NSURL *)url;
+ (SONSWindowAuxContextSiconCreation *)siconCreationContext;
+ (SONSWindowAuxContextDockCaarCreation *)dockCaarCreationContextWithURL:(NSURL *)URL;
@end

@interface SONSWindowAuxContextSicon : SONSWindowAuxContext
@property (strong) SOSicon *loadedSicon;
@property (assign) size_t loadedSiconImageCount;
@property (strong) NSData *loadedSiconBlob;
@end

@interface SONSWindowAuxContextSiconCreation : SONSWindowAuxContext
@property (strong) SOSicon *loadedSicon;
@end

@interface SONSWindowAuxContextDockCaarCreation : SONSWindowAuxContext
@property (strong) NSData *archivedData;
@end
