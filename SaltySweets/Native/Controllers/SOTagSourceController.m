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

- (id)pasteboardPropertyListForType:(NSPasteboardType)type {
    if ([type isEqualToString:@"com.saltysoft.SaltySweets.boundproperties"])
        return self.boundProperties;
    
    return nil;
}

- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[@"com.saltysoft.SaltySweets.boundproperties"];
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
    self.tagsCollectionView.selectable = YES;
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
    NSString *tag = [self.tagsArray objectAtIndex:[indexPath item]];
    SOItemTag *item = [[SOItemTag alloc] initWithString:tag
                                        boundProperties:[self boundPropertiesForTag:tag]];

    return item;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.tagsArray)
        return 0;
    
    return [self.tagsArray count];
}

- (NSDictionary<NSString *, id> *)boundPropertiesForTag:(NSString *)tag{
    if ([tag isEqualToString:@"Display P3"]){
        return @{
            (id)kCGImagePropertyNamedColorSpace : (id)kCGColorSpaceDisplayP3
        };
    } else if ([tag isEqualToString:@"sRGB"]){
        return @{
            (id)kCGImagePropertyNamedColorSpace : (id)kCGColorSpaceSRGB
        };
    } else if ([tag isEqualToString:@"Greyscale"]){
        return @{
            (id)kCGImagePropertyNamedColorSpace : (id)kCGColorSpaceExtendedGray
        };
    } else if ([tag isEqualToString:@"B&W"]){
        return @{
            kSOIconServerCommand : kSOIconServerCommandBlackAndWhiteImage
        };
    } else if ([tag isEqualToString:@"Template"]){
        return @{
            kSOIconServerCommand : kSOIconServerCommandTemplateImage
        };
    }
    
    return nil;
}

#pragma mark - Pasteboard

- (BOOL)collectionView:(NSCollectionView *)collectionView
canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
             withEvent:(NSEvent *)event{
    return YES;
}

- (id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView
       pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath{
    return (id<NSPasteboardWriting>)[collectionView itemAtIndexPath:indexPath];
}

- (NSDragOperation)draggingSession:(nonnull NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationCopy;
}
@end
