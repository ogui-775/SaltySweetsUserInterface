//Created by Salty on 7/31/26.

#import <AppKit/AppKit.h>

#import "SONavigatorBarItem.h"

@interface SONavigatorBar : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>
@property (strong, nonatomic) IBOutlet NSCollectionView *navigationCollectionView;
@property (strong, nonatomic) IBOutlet NSView *viewer;
- (void)finishInitWithOptions:(NSArray<SONavigatorBarItem *> *)itemArray;
- (void)replaceCurrentOptionsWithArray:(NSArray<SONavigatorBarItem *> *)itemArray;
@end
