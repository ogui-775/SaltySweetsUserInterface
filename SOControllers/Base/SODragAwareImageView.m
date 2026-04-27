//Created by Salty on 4/17/26.

#import "SODragAwareImageView.h"

@implementation SODragAwareImageView
- (void)awakeFromNib {
    [super awakeFromNib];
    [self registerForDraggedTypes:@[NSPasteboardTypeFileURL, @"com.saltysoft.sicon"]];
}


- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:@"com.saltysoft.sicon"] ||
        [[pboard types] containsObject:NSPasteboardTypeFileURL]) {
        return NSDragOperationCopy;
    }
    
    return [super draggingEntered:sender];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
    
    if (fileURL) {
        [self setDraggedFileURL:fileURL];
        if ([[fileURL pathExtension] isEqualToString:@"sicon"])
            [NSApp sendAction:self.action to:self.target from:self];
    }
    
    return [super performDragOperation:sender];
}

@end
