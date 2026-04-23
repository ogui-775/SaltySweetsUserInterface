//Created by Salty on 4/18/26.

@import libjxl;

#import <AppKit/AppKit.h>
#import <SharedBundles/SharedBundles.h>

#import "../Services/SONSWindowAuxContext.h"

@interface SONSWindowAuxSiconController : NSViewController <NSCollectionViewDelegate, NSCollectionViewDataSource>
@property (strong) NSMutableDictionary<NSNumber *, SOSiconObj *> *imageDict;
@property (strong) SOSiconBundle * bundle;
@property (strong) IBOutlet NSCollectionView * interiorCollectionView;
@property (strong) IBOutlet NSTextField * labelField;
@property (weak) SONSWindowAuxContextSicon * context;
- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(SONSWindowAuxContextSicon *)ctx;
@end

@interface SOSiconCollectionViewItem : NSCollectionViewItem
@property (strong) NSString * descriptor;
@property (weak) SONSWindowAuxSiconController * parentController;
@end
