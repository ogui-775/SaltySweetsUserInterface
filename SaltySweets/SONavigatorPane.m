//Created by Salty on 2/2/26.

#import "SONavigatorPane.h"

@implementation SONavigatorPaneObject
- (instancetype)initWithTitle:(NSString *)title
                       bundle:(SONSBundle *)bundle
             containsChildren:(BOOL)containsChildren{
    self = [super init];
    if (self){
        _title = title;
        _bundle = bundle;
        _containsChildren = containsChildren;
        _children = [NSMutableArray array];
    }
    return self;
}
@end

@interface SONavigatorPane ()
@property (strong) NSMutableArray<SONavigatorPaneObject *> *collectionArray;
@end

@implementation SONavigatorPane
- (void)awakeFromNib{
    [super awakeFromNib];
    self.collectionArray = [NSMutableArray array];
    
    [self reload:nil];
}
- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(SONavigatorPaneObject *)item{
    if (!item)
        return self.collectionArray[index];
    
    return [item.children objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(SONavigatorPaneObject *)item{
    if (!item)
        return YES;
    
    return item.containsChildren;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(SONavigatorPaneObject *)item{
    if (!item && self.collectionArray)
        return [self.collectionArray count];
    else if (!item)
        return 0;

    return [item.children count];
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(SONavigatorPaneObject *)item{
    if (!item)
        return self.collectionArray;
    
    return item.title;
}

- (NSArray<SONavigatorPaneObject *> *)dockThemeInventory{
    NSArray<NSURL *> *dockThemeURLs = [self URLsForDirectoryPath:[SOAtomicAccessPoint sharedInstance].dockThemeBundleDirectory];
    
    NSMutableArray<SONavigatorPaneObject *> *retArray = [NSMutableArray array];
    
    for (NSURL *url in dockThemeURLs){
        SONavigatorPaneObject *retObject = [[SONavigatorPaneObject alloc] initWithTitle:url.lastPathComponent
                                                                                 bundle:[[SODockThemeBundle alloc] initWithURL:url]
                                                                       containsChildren:NO];
        [retArray addObject:retObject];
    }
    
    return retArray;
}

- (NSArray<SONavigatorPaneObject *> *)iconPackInventory{
    NSArray<NSURL *> *iconPackURLs = [self URLsForDirectoryPath:[SOAtomicAccessPoint sharedInstance].iconPackBundleDirectory];
    
    NSMutableArray<SONavigatorPaneObject *> *retArray = [NSMutableArray array];
    
    for (NSURL *url in iconPackURLs){
        SONavigatorPaneObject *retObject = [[SONavigatorPaneObject alloc] initWithTitle:url.lastPathComponent
                                                                                 bundle:[[SOSiconPackBundle alloc] initWithURL:url]
                                                                       containsChildren:NO];
        [retArray addObject:retObject];
    }
    
    return retArray;
}

- (NSArray<NSURL *> *)URLsForDirectoryPath:(NSString *)path{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL *directoryURL = [NSURL fileURLWithPath:path
                                     isDirectory:YES];
    
    NSArray<NSURL *> *ret = [fm contentsOfDirectoryAtURL:directoryURL
                              includingPropertiesForKeys:nil
                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                   error:nil];
    
    return ret;
}

- (IBAction)reload:(id)sender{
    NSArray *dockItems = [self dockThemeInventory];
    
    SONavigatorPaneObject *dockObjects = [[SONavigatorPaneObject alloc] initWithTitle:@"Dock Themes"
                                                                               bundle:nil
                                                                     containsChildren:dockItems.count > 0];
    
    for (SONavigatorPaneObject *obj in dockItems){
        obj.title = [obj.title stringByDeletingPathExtension];
        [dockObjects.children addObject:obj];
    }
    
    NSArray *iconItems = [self iconPackInventory];
    
    SONavigatorPaneObject *iconObjects = [[SONavigatorPaneObject alloc] initWithTitle:@"Icon Packs"
                                                                               bundle:nil
                                                                     containsChildren:iconItems.count > 0];
    
    for (SONavigatorPaneObject *obj in iconItems){
        obj.title = [obj.title stringByDeletingPathExtension];
        [iconObjects.children addObject:obj];
    }
    
    [self.collectionArray removeAllObjects];
    [self.collectionArray addObject:dockObjects];
    [self.collectionArray addObject:iconObjects];

    [self.outlineView reloadData];
    
    [self.outlineView expandItem:dockObjects];
    [self.outlineView expandItem:iconObjects];
}
@end
