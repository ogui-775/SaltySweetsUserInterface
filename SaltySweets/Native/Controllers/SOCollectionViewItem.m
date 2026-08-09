//Created by Salty on 8/7/26.

#import "SOCollectionViewItem.h"

@interface SOCollectionViewItemView : NSView
@property (weak) SOCollectionViewItem *delegate;
@end

@implementation SOCollectionViewItemView
- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    for (NSTrackingArea *trackingArea in self.trackingAreas) {
        [self removeTrackingArea:trackingArea];
    }

    NSTrackingArea *trackingArea =
        [[NSTrackingArea alloc] initWithRect:self.bounds
                                     options:NSTrackingMouseEnteredAndExited |
                                             NSTrackingActiveAlways
                                       owner:self
                                    userInfo:nil];

    [self addTrackingArea:trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    [self.delegate setUnderlined:YES];
}

- (void)mouseExited:(NSEvent *)event {
    [self.delegate setUnderlined:NO];
}
@end

@implementation SOCollectionViewItem
@synthesize underlined = _underlined;

- (instancetype)init {
    self = [super init];
    if (self) {
        SOCollectionViewItem *item = self;

        CGRect bounds = CGRectMake(0, 0, 100, 50);

        SOCollectionViewItemView *view = [[SOCollectionViewItemView alloc] initWithFrame:bounds];
        view.delegate = item;
        item.view = view;
        view.autoresizingMask = NSViewWidthSizable;
        view.wantsLayer = YES;

        NSImageView *imageView =
            [[NSImageView alloc] initWithFrame:CGRectMake(36, 10, 32, 32)];

        imageView.editable = NO;
        imageView.imageScaling = NSImageScaleProportionallyUpOrDown;

        item.imageView = imageView;
        [item.view addSubview:imageView];

        NSTextField *textField =
            [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];

        textField.editable = NO;
        textField.bordered = NO;
        textField.usesSingleLineMode = YES;
        textField.drawsBackground = NO;
        textField.font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
        textField.alignment = NSTextAlignmentCenter;
        [textField setClipsToBounds:NO];

        item.textField = textField;
        [item.view setClipsToBounds:NO];
        [item.view addSubview:textField];
    }

    return self;
}

- (void)setUnderlined:(BOOL)underlined{
    _underlined = underlined;

    NSMutableAttributedString *string =
        [self.textField.attributedStringValue mutableCopy];

    if (string.length > 0) {
        if (underlined) {
            [string addAttribute:NSUnderlineStyleAttributeName
                           value:@(NSUnderlineStyleSingle)
                           range:NSMakeRange(0, string.length)];
        } else {
            [string removeAttribute:NSUnderlineStyleAttributeName
                              range:NSMakeRange(0, string.length)];
        }
    }

    self.textField.attributedStringValue = string;
}

- (BOOL)underlined{
    return _underlined;
}
@end
