#import "SODocumentationPageController.h"

@interface SOOutlineDoc : NSObject
@property (strong) SOOutlineDoc *parent;
@property (strong) NSMutableArray<SOOutlineDoc *> *children;
@property (strong) NSString *label;
@property (strong) NSString *documentFilename;
@property (assign) BOOL isRootObject;

- (instancetype)initWithParent:(SOOutlineDoc *)parent
                      children:(NSArray<SOOutlineDoc *> *)children
                         label:(NSString *)label
              documentFilename:(NSString *)filename;
//- (void)addChild:(SOOutlineDoc *)doc;
@end

@implementation SOOutlineDoc
- (instancetype)initWithParent:(SOOutlineDoc *)parent
                      children:(NSMutableArray<SOOutlineDoc *> *)children
                         label:(NSString *)label
              documentFilename:(NSString *)filename{
    self = [super init];
    if (self){
        self.children = children;
        self.label = label;
        self.documentFilename = filename;
        if (parent){
            self.parent = parent;
            [self.parent addChild:self];
        }
        else
            self.isRootObject = YES;
    }
    return self;
}

+ (void)appendChildToParent:(SOOutlineDoc *)parent
                  withLabel:(NSString *)label
                   filename:(NSString *)filename{
    SOOutlineDoc *doc = [[SOOutlineDoc alloc] initWithParent:nil
                                                    children:nil
                                                       label:label
                                            documentFilename:filename];
    [parent addChild:doc];
}

- (void)addChild:(SOOutlineDoc *)doc{
    if (!self.children)
        self.children = [NSMutableArray array];
    
    [self.children addObject:doc];
}
@end

@interface SODocumentationPageController ()
@property (strong) NSArray<SOOutlineDoc *> *documents;
@end


@implementation SODocumentationPageController

- (void)awakeFromNib{
        [super awakeFromNib];

        [self displayReadme];
        [self loadDocuments];
}

- (IBAction)openPage:(NSOutlineView *)sender{
    SOOutlineDoc *doc = [sender itemAtRow:[sender selectedRow]];
    
    if (!doc)
        return;
    
    if (!doc.documentFilename)
        return;
    
    NSURL *url =
        [[[NSBundle mainBundle] resourceURL]
            URLByAppendingPathComponent:doc.documentFilename];
    
    [self.webView loadFileURL:url
      allowingReadAccessToURL:url.URLByDeletingLastPathComponent];
}

- (void)displayReadme{
    NSURL *url =
        [[[NSBundle mainBundle] resourceURL]
            URLByAppendingPathComponent:@"Readme.html"];

    [self.webView loadFileURL:url
      allowingReadAccessToURL:url.URLByDeletingLastPathComponent];
}

- (void)loadDocuments{
    SOOutlineDoc *iconsDocs = [[SOOutlineDoc alloc] initWithParent:nil
                                                          children:nil
                                                             label:@"Icons"
                                                  documentFilename:nil];
    
    [SOOutlineDoc appendChildToParent:iconsDocs
                            withLabel:@"Troubleshooting"
                             filename:@"Icons Tweak Troubleshooting.html"];
    
    SOOutlineDoc *dockDocs = [[SOOutlineDoc alloc] initWithParent:nil
                                                         children:nil
                                                            label:@"Dock"
                                                 documentFilename:nil];
    
    [SOOutlineDoc appendChildToParent:dockDocs
                            withLabel:@"Troubleshooting"
                             filename:@"Dock Tweak Troubleshooting.html"];
    
    self.documents = @[
        [[SOOutlineDoc alloc] initWithParent:nil children:nil label:@"Read Me!" documentFilename:@"Readme.html"],
        iconsDocs,
        dockDocs
    ];
    
    [self.documentOutlineView reloadData];
    
    [self.documentOutlineView expandItem:nil
                          expandChildren:YES];
    
    [self.documentOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0]
                          byExtendingSelection:NO];
    
    [self.documentOutlineView setAllowsEmptySelection:NO];
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(SOOutlineDoc *)item{
    if (!item)
        return [self.documents objectAtIndex:index];
    
    if (![item children])
        return nil;
    
    SOOutlineDoc *child = [[item children] objectAtIndex:index];
    
    return child;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(SOOutlineDoc *)item{
    if (!item && !self.documents)
        return 0;
    else if (!item)
        return [self.documents count];
    
    return [[item children] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(SOOutlineDoc *)item{
    if (![item isRootObject] || ![item children])
        return NO;
    
    if ([item children])
        return YES;
    
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(SOOutlineDoc *)item{
    return item.label;
}
@end
