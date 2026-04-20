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
    
    self.flatImageArray = [NSMutableArray array];
    NSDictionary * imageDict = self.context.loadedSiconManifest[kSOSiconImages.key];
    
    for (NSString * key in imageDict){
        NSDictionary * subDict = imageDict[key];
        
        if (![[subDict objectForKey:kSOSiconDark.key] isEqualToString:@""])
            [self.flatImageArray addObject:[subDict objectForKey:kSOSiconDark.key]];
        if (![[subDict objectForKey:kSOSiconLight.key] isEqualToString:@""])
            [self.flatImageArray addObject:[subDict objectForKey:kSOSiconLight.key]];
        if (![[subDict objectForKey:kSOSiconSelected.key] isEqualToString:@""])
            [self.flatImageArray addObject:[subDict objectForKey:kSOSiconSelected.key]];
    }
    
    self.bundle = [NSBundle bundleWithURL:self.context.loadedSicon];
    [self.interiorCollectionView reloadData];
    [self.interiorCollectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.context.loadedSiconImageCount;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    SOSiconCollectionViewItem * item =
        [collectionView makeItemWithIdentifier:@"SiconItem" forIndexPath:indexPath];
    
    item.parentController = self;
    NSUInteger idx = indexPath.item;
    NSURL * urlForImage = [self.bundle URLForImageResource:self.flatImageArray[idx]];
    NSData * dataForImage = [NSData dataWithContentsOfURL:urlForImage];
    item.imageView.image = [[NSImage alloc] initWithData:dataForImage];
    item.descriptor = [NSString stringWithFormat:@"%lu - %@ - %ix%i - %lukb",
                       (unsigned long)idx,
                       urlForImage.lastPathComponent,
                       (int)item.imageView.image.size.width,
                       (int)item.imageView.image.size.height,
                       (unsigned long)(dataForImage.length/1024)];
    
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
