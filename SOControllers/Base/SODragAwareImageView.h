//Created by Salty on 4/17/26.

#import <AppKit/AppKit.h>

@interface SODragAwareImageView : NSImageView <NSDraggingSource>
@property (strong) NSURL * draggedFileURL;
@end
