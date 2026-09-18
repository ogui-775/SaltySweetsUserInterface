//Created by Salty on 9/18/26.

#import <Cocoa/Cocoa.h>

@class SOPackViewItem;

@interface SOTagPopoverController : NSViewController <NSPopoverDelegate>
- (instancetype)initWithSourceItem:(SOPackViewItem *)item;
@end
