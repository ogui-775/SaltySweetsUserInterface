//Created by Salty on 4/18/26.

#import "SONSWindowAuxSiconController.h"

@implementation SONSWindowAuxSiconController
- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(SONSWindowAuxContextSicon *)ctx{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.context = ctx;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.interiorCollectionView registerClass:[SOSiconCollectionViewItem class]
                         forItemWithIdentifier:@"SiconItem"];
    
    self.imageDict = [NSMutableDictionary dictionary];
    self.bundle = self.context.loadedSicon;
    
    [self.bundle enumerateDescriptorsWithBlock:^(const SOSiconDescriptor *desc, NSUInteger index) {
        SOSiconObj *obj = [[SOSiconObj alloc] init];
        obj.desc = desc;
        obj.image = [self.bundle CGImageForIndex:index];
        
        [self.imageDict setObject:obj forKey:@(index)];
    }];
    
    [self.interiorCollectionView reloadData];
    [self.interiorCollectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.context.loadedSiconImageCount;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    SOSiconCollectionViewItem *item =
        [collectionView makeItemWithIdentifier:@"SiconItem" forIndexPath:indexPath];
    
    item.parentController = self;
    NSUInteger idx = indexPath.item;
    
    CGImageRef interiorImg = [self.imageDict objectForKey:@(idx)].image;
    const SOSiconDescriptor *desc = [self.imageDict objectForKey:@(idx)].desc;
    
    item.imageView.image = [[NSImage alloc] initWithCGImage:interiorImg size:CGSizeZero];
    CGImageRelease(interiorImg);
    
    item.descriptor = [NSString stringWithFormat:@"%lu - %ix%i - %lukb",
                       (unsigned long)idx,
                       (int)item.imageView.image.size.width,
                       (int)item.imageView.image.size.height,
                       (unsigned long)(desc->dataLength/1024)];
    
    return item;
}
@end

@implementation SOSiconCollectionViewItem
- (void)loadView{
    self.view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    NSImageView * imageView = [[NSImageView alloc] initWithFrame:CGRectMake(10, 10, 180, 180)];
    imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    imageView.editable = NO;
    self.imageView = imageView;
    [self.view addSubview:imageView];
}

- (void)setSelected:(BOOL)selected{
    if (selected){
        self.parentController.labelField.stringValue = self.descriptor;
        [self.view.layer setBackgroundColor:NSColor.selectedControlColor.CGColor];
    }
    else
        [self.view.layer setBackgroundColor:NSColor.clearColor.CGColor];
}
@end
