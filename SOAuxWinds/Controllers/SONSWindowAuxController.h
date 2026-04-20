//Created by Salty on 4/18/26.

#import <AppKit/AppKit.h>

#import "../Helpers/SONSWindowAuxSpawner.h"
#import "SONSWindowAuxSiconController.h"
#import "../Services/SONSWindowAuxContext.h"

@interface SONSWindowAuxController : NSWindowController
- (instancetype)initControllerForSiconContextWithURL:(NSURL *)url;
@end
