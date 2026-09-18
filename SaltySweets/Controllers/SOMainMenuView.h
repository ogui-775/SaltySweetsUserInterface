//Created by Salty on 8/7/26.

#import <Cocoa/Cocoa.h>
#import "Base/SOConfigurablePageControllerBase.h"

@class SONavigatorBarItem;

@interface SOMainMenuView : SOConfigurablePageControllerBase <NSCollectionViewDataSource, NSCollectionViewDelegate>
@property (weak, nonatomic) IBOutlet NSCollectionView *collectionView;
@property (weak) id delegate;
@property (assign) SEL action;
- (void)finishInitWithItemDictionary:(NSDictionary<NSNumber *, NSArray<SONavigatorBarItem *> *> *)dictionary;
@end
