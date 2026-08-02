//Created by Salty on 7/31/26.

#import <AppKit/AppKit.h>

#import "SONavigatorBarItem.h"
#import "SOViewPane.h"
#import "SONavigatorBarMaster.h"

@interface SONavigatorBar : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>
@property (strong, nonatomic) IBOutlet NSCollectionView *navigationCollectionView;
- (void)finishInitWithOptions:(NSArray<SONavigatorBarItem *> *)itemArray;
- (void)replaceCurrentOptionsWithArray:(NSArray<SONavigatorBarItem *> *)itemArray;
@end

@interface SONavigatorBarStretchyView : NSView
@property (weak) IBOutlet NSViewController *innerView;
@end
