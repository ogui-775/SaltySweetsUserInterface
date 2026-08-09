//Created by Salty on 8/7/26.

#import <Cocoa/Cocoa.h>

#import "../../SONavigatorBarItem.h"
#import "SOCollectionViewItem.h"
#import "../Layouts/SOMainMenuLayout.h"

@interface SOMainMenuView : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>
@property (weak, nonatomic) IBOutlet NSCollectionView *collectionView;
@property (weak) id delegate;
@property (assign) SEL action;
- (void)finishInitWithItemDictionary:(NSDictionary<NSNumber *, NSArray<SONavigatorBarItem *> *> *)dictionary;
@end
