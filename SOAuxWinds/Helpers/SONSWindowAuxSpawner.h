//Created by Salty on 4/18/26.

#import <AppKit/AppKit.h>

#import "../Services/SONSWindowAux.h"
#import "../Services/SONSWindowAuxContext.h"

@interface SONSWindowAuxSpawner : NSObject
+ (SONSWindowAux *)spawnAuxWindowForSiconWithURL:(NSURL *)url;
+ (SONSWindowAux *)spawnAuxWindowForSiconCreation;
@end
