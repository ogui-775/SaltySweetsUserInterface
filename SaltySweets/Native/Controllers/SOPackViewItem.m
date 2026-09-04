//Created by Salty on 8/12/26.

#import "SOPackViewItem.h"

#import <SharedClasses/SharedClasses.h>

@implementation SOPackViewItem
- (instancetype)initWithName:(NSString *)name URL:(NSURL *)URL{
    self = [super init];
    if (self && URL){
        NSView *view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
        self.view = view;

        [view setWantsLayer:YES];
        [view.layer setBorderColor:NSColor.selectedControlColor.CGColor];
        
        NSTextField *text = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        text.editable = NO;
        text.bordered = NO;
        text.lineBreakMode = NSLineBreakByWordWrapping;
        text.stringValue = name;
        text.drawsBackground = NO;
        text.alignment = NSTextAlignmentCenter;
        
        [view addSubview:text];
        self.textField = text;
        
        self.URL = URL;
        
        NSImageView *image = [[NSImageView alloc] initWithFrame:CGRectMake(30, 40, 40, 40)];
        image.image = [[URL pathExtension] isEqualToString:@"sicon"] ? [SOSicon NSImageOrNilForURL:URL] :
        [[NSImage alloc] initWithContentsOfURL:URL] ?: [[NSWorkspace sharedWorkspace] iconForFile:URL.path];
        image.editable = NO;
        image.imageScaling = NSImageScaleProportionallyUpOrDown;
        self.imageView = image;
        [view addSubview:image];
    }
    return self;
}
@end
