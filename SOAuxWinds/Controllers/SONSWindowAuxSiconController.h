//Created by Salty on 4/18/26.

@import libjxl;

#import <AppKit/AppKit.h>

#import "../Services/SONSWindowAuxContext.h"

@interface SONSWindowAuxSiconController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource>
@property (strong) NSMutableArray * flatImageArray;
@property (strong) NSBundle * bundle;
@property (strong) IBOutlet NSCollectionView * interiorCollectionView;
@property (strong) IBOutlet NSTextField * labelField;
@property (weak) SONSWindowAuxContextSicon * context;
- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(SONSWindowAuxContextSicon *)ctx;
@end

@interface SOSiconCollectionViewItem : NSCollectionViewItem
@property (strong) NSString * descriptor;
@property (weak) SONSWindowAuxSiconController * parentController;
@end
