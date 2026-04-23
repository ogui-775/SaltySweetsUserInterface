//Created by Salty on 2/6/26.

#import "SOViewPane.h"

static SOViewPane * _instance = nil;

@interface SOViewPane()  <SOConfigurableContentDelegate>
@property (nonatomic, strong) IBOutlet NSButton * applyButton;
@property (nonatomic, strong) IBOutlet NSButton * previewButton;

@property (nonatomic, strong) NSViewController * currentPage;
@property (nonatomic, strong) IBOutlet NSScrollView * internalScrollView;
@end

@implementation SOViewPane

@synthesize pendingChangesCache = _pendingChangesCache;

- (instancetype)init{
    self = [super init];
    if (self)
    {
        _instance = self;
    }
    return self;
}

+ (instancetype)defaultInstance{
    return _instance;
}

- (void)requestPageChangeTo:(NSViewController *)page {
    if (![self.childViewControllers containsObject:page])
        [self addChildViewController:page];
        
    [self.internalScrollView setDocumentView:page.view];
    
    [page.view setFrame:self.internalScrollView.contentView.bounds];
    
    self.currentPage = page;
    
    if ([page conformsToProtocol:@protocol(SOConfigurableContent)]) {
        id<SOConfigurableContent> configurablePage = (id<SOConfigurableContent>)page;
        configurablePage.changeDelegate = self;
    }
}

- (void)contentDidChangeState:(id<SOConfigurableContent>)content{
    if (!self.pendingChangesCache)
        self.pendingChangesCache = [NSMapTable strongToStrongObjectsMapTable];
    
    [self.pendingChangesCache setObject:[content pendingChanges] forKey:content];
    
    BOOL hasAnyChanges = NO;
    
    for (id<SOConfigurableContent> page in self.pendingChangesCache) {
        NSArray<SOChange *> * changes = [self.pendingChangesCache objectForKey:page];
        if (changes.count > 0) {
            hasAnyChanges = YES;
            break;
        }
    }
    
    self.applyButton.enabled = hasAnyChanges;
}

- (IBAction)doApplyAction:(NSButton *)sender{
    if (!self.applyButton.enabled)
        return;

    NSMutableArray * changesFlat = [NSMutableArray new];
    id baseline = nil;

    for (id<SOConfigurableContent> page in self.pendingChangesCache) {
        NSArray<SOChange *> * changes = [self.pendingChangesCache objectForKey:page];
        if (changes.count > 0) {
            [changesFlat addObjectsFromArray:changes];
            baseline = page.baselineState;
        }
    }

    SOChangeCompiler * compiler = [[SOChangeCompiler alloc] init];
    
    [compiler generateBundleWithBaseline:baseline
                                 changes:changesFlat
                            shortCircuit:kSONoShort
                              completion:^(SOHandlerCompletionCodes completionCode) {
        if (completionCode == kSOAbort || completionCode == kSOErrorResult)
            return;

        [[NSNotificationCenter defaultCenter]
            postNotificationName:SONotificationBaseClassUpdateBaseline
                          object:self];

        for (id<SOConfigurableContent> page in self.childViewControllers) {
            if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
                [page refreshOrLoadBaseline];
        }
        
        if (completionCode == kSONoChange)
            return;

        for (id<SOConfigurableContent> page in self.childViewControllers) {
            if ([page respondsToSelector:@selector(purgePendingChanges)])
                [page purgePendingChanges];
        }

        [self.pendingChangesCache removeAllObjects];

        [[[AppDelegate appIconServerConnection] remoteObjectProxy]
                                requestGlobalSettingsInvalidation];
        
        self.applyButton.enabled = NO;
        
        [AppDelegate clearAllUndoManagers];
    }];
}
@end
