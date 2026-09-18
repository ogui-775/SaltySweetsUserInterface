//Created by Salty on 9/18/26.

#import <Cocoa/Cocoa.h>

@interface SOBundleViewerViewController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource>
@property (weak, nonatomic) IBOutlet NSStackView *tagsStack;
@property (weak, nonatomic) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSButton *backButton;
@property (weak) IBOutlet NSTextField *packDisplayLabel;
- (void)updateContents;
- (void)goBack:(id)sender;
@end
