//Created by Salty on 9/18/26.

#import <Cocoa/Cocoa.h>

@interface SOBundleViewerViewController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource>
@property (weak, nonatomic) IBOutlet NSCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSBox *colorSpaceBox;
@property (weak, nonatomic) IBOutlet NSBox *itemPropertyBox;
@property (weak) NSToolbarItem *backButton;
- (void)updateContents;
- (void)goBack:(id)sender;
@end
