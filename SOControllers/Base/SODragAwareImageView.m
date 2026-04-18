//Created by Salty on 4/17/26.

#import "SODragAwareImageView.h"

@implementation SODragAwareImageView
- (void)awakeFromNib{
    [super awakeFromNib];
    [self registerForDraggedTypes:@[NSPasteboardTypeURL]];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard * pBoard = [sender draggingPasteboard];
    
    if ([[pBoard types] containsObject:NSPasteboardTypeFileURL]) {
        id files = [pBoard propertyListForType:NSPasteboardTypeFileURL];
        NSURL * fileURL = [NSURL URLWithString:[files isKindOfClass:NSArray.class] ? [files firstObject] : (NSString *)files];
        [self setDraggedFileURL:fileURL];
    }
    
    return [super performDragOperation:sender];
}
@end
