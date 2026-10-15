//Created by Salty on 9/18/26.

#import <Cocoa/Cocoa.h>

@class SOPackViewItem;

@interface SOTagPopoverController : NSViewController <NSPopoverDelegate, NSCollectionViewDelegate, NSCollectionViewDataSource>
- (instancetype)initWithSourceItem:(SOPackViewItem *)item;

@property (strong) NSString *name;
@property (weak) IBOutlet NSCollectionView *tagsView;
@end
