//Created by Salty on 5/1/26.

#import "ThumbnailProvider.h"

@implementation ThumbnailProvider

- (void)provideThumbnailForFileRequest:(QLFileThumbnailRequest *)request completionHandler:(void (^)(QLThumbnailReply * _Nullable, NSError * _Nullable))handler {
    CGSize targetSize = request.maximumSize;
    
    handler([QLThumbnailReply replyWithContextSize:targetSize drawingBlock:^BOOL(CGContextRef context) {        
        SOSicon *sicon = [[SOSicon alloc] initWithURL:request.fileURL];
        CGImageRef img = [sicon CGImageForSize:targetSize
                                      isRetina:request.scale > 1
                                        isDark:[NSApp.effectiveAppearance.name containsString:@"Dark"]
                                    isSelected:NO];
        
        if (img) {
            CGContextDrawImage(context,
                               CGRectMake(0,
                                          0,
                                          targetSize.width * request.scale,
                                          targetSize.height * request.scale),
                               img);
            CGImageRelease(img);
            return YES;
        } else {
            NSImage *nsImg = [SOSicon NSImageOrNilForURL:request.fileURL];
            
            if (nsImg){
                img = [nsImg CGImageForProposedRect:nil context:NULL hints:NULL];
                CGContextDrawImage(context,
                                   CGRectMake(0,
                                              0,
                                              targetSize.width * request.scale,
                                              targetSize.height * request.scale),
                                   img);
                
                if (img){
                    CGImageRelease(img);
                    return YES;
                }
            }
        }
        
        return NO;
    }],
 nil);
}

@end
