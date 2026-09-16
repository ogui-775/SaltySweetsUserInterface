//Created by Salty on 9/14/26.

#import "SOTagSourceController.h"

@interface SOTagSourceController ()
@property (assign) SOTagSourceType assignedType;
@property (strong) NSArray<NSString *> *tagsArray;
@end

@interface SOItemTag ()
@property (strong) NSDictionary<NSString *, id> *boundProperties;
@end

@implementation SOItemTag
- (instancetype)initWithString:(NSString *)string
               boundProperties:(NSDictionary<NSString *,id> *)properties{
    self = [super init];
    if (self){
        NSView *v = [[NSView alloc] init];
        self.view = v;
        [v setFrame:CGRectMake(0, 0, 160, 20)];
        NSTextField *tf = [[NSTextField alloc] init];
        self.textField = tf;
        tf.stringValue = string;
        [self.view addSubview:tf];
        [tf setFrame:CGRectMake(0, 0, 160, 20)];
        [tf setAlignment:NSTextAlignmentCenter];
        [tf setEditable:NO];
        
        self.boundProperties = properties;
    }
    return self;
}
@end

@implementation SOTagSourceController
- (instancetype)initWithTagSourceType:(SOTagSourceType)type
                             tagArray:(NSArray<NSString *> *)tags{
    self = [super initWithNibName:@"SOTagSourceView"
                           bundle:nil];
    if (self){
        self.assignedType = type;
        self.tagsArray = tags;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.viewBox.title = GetTitleFromTagSourceType(self.assignedType);
    [self.tagsCollectionView reloadData];
}

NSString* GetTitleFromTagSourceType(SOTagSourceType type){
    switch (type) {
        case SOTagSourceTypeColorSpace:
            return @"Color Space";
            break;
            
        case SOTagSourceTypeNSImageProperties:
            return @"Item Properties";
            break;
            
        case SOTagSourceTypeGeneric:
        default:
            return @"Item Tags";
            break;
    }
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    SOItemTag *item = [[SOItemTag alloc] initWithString:self.tagsArray[indexPath.item]
                                        boundProperties:@{}];

    return item;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.tagsArray)
        return 0;
    
    return [self.tagsArray count];
}

@end
