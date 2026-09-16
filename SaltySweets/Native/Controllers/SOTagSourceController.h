//Created by Salty on 9/14/26.

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    SOTagSourceTypeGeneric,
    SOTagSourceTypeColorSpace,
    SOTagSourceTypeNSImageProperties,
} SOTagSourceType;

@interface SOTagSourceController : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype) initWithTagSourceType:(SOTagSourceType)type
                              tagArray:(NSArray<NSString *> *)tags;

@property (weak) IBOutlet NSBox *viewBox;
@property (weak) IBOutlet NSCollectionView *tagsCollectionView;
@end

@interface SOItemTag : NSCollectionViewItem
- (instancetype)initWithString:(NSString *)string
               boundProperties:(NSDictionary<NSString *, id> *)properties;
@end
