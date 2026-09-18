//Created by Salty on 8/12/26.

#import "SOPackViewItem.h"
#import "SOTagPopoverController.h"

#import <SharedClasses/SharedClasses.h>

@interface SOPackViewItem ()
@property (strong) NSImageView *tagImageView;
@property (strong) NSPopover *tagPopover;
@end

@implementation SOPackViewItem
@synthesize hasTags = _hasTags;

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

- (BOOL)hasTags{
    return _hasTags;
}

- (void)setHasTags:(BOOL)hasTags{
    _hasTags = hasTags;
    
    if (!self.tagImageView){
        NSImageView *tiv = [[NSImageView alloc] initWithFrame:CGRectMake(75, 55, 20, 20)];
        self.tagImageView = tiv;
        tiv.editable = NO;
        tiv.toolTip = @"View tags";
        tiv.imageScaling = NSImageScaleProportionallyUpOrDown;
        [self.view addSubview:tiv];
        NSClickGestureRecognizer *clicker = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(openTagPopup:)];
        clicker.numberOfClicksRequired = 1;
        clicker.numberOfTouchesRequired = 1;
        [self.tagImageView addGestureRecognizer:clicker];
    }
    
    if (hasTags){
        self.tagImageView.image = [NSImage imageWithSystemSymbolName:@"tag"
                                            accessibilityDescription:nil];
    } else {
        self.tagImageView.image = nil;
    }
}

- (void)openTagPopup:(NSClickGestureRecognizer *)sender{
    if (!self.hasTags)
        return;
    
    if (!self.tagPopover){
        self.tagPopover = [[NSPopover alloc] init];
        self.tagPopover.contentViewController = [[SOTagPopoverController alloc] initWithSourceItem:self];
    }
    
    [self.tagPopover showRelativeToRect:self.tagImageView.bounds
                                 ofView:self.tagImageView
                          preferredEdge:NSMaxXEdge];
}

- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    return @[
        NSPasteboardTypeURL,
        NSPasteboardTypeFileURL,
    ];
}

- (id)pasteboardPropertyListForType:(NSPasteboardType)type{
    if ((type == NSPasteboardTypeURL || type == NSPasteboardTypeFileURL) && self.URL)
        return [self.URL absoluteString];
    
    return nil;
}
@end
