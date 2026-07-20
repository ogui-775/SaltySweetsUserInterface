//Created by Salty on 2/6/26.

#import "SOViewPane.h"

static SOViewPane * _instance = nil;

@interface SOViewPane()  <SOConfigurableContentDelegate>
@property (nonatomic, strong) IBOutlet NSButton * applyButton;
@property (nonatomic, strong) IBOutlet NSButton * previewButton;

@property (nonatomic, strong) NSViewController * currentPage;
@property (nonatomic, strong) IBOutlet NSScrollView * internalScrollView;

@property (atomic, assign) BOOL containsDockChanges;
@property (atomic, assign) BOOL containsIconChanges;
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

- (IBAction)doApplyAction:(id)sender{
    if (!self.applyButton.enabled)
        return;

    NSMutableArray * changesFlat = [NSMutableArray new];
    id baseline = nil;

    for (id<SOConfigurableContent> page in self.pendingChangesCache) {
        NSArray<SOChange *> *changes = [self.pendingChangesCache objectForKey:page];
        
        for (SOChange *change in changes){
            [changesFlat addObject:change];
            
            if (change.iconChange)
                self.containsIconChanges = YES;
            else
                self.containsDockChanges = YES;
        }
        baseline = page.baselineState;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    if (self.containsIconChanges){
        dispatch_group_enter(group);
        SOSimpleIconChangeCompiler *iconCompiler = [[SOSimpleIconChangeCompiler alloc] init];
        
        SOSiconPackBundle *iconPack = [[SOAtomicAccessPoint sharedInstance] currentIconPackBundle];
        if (!iconPack.bundleIdentifier){
            [iconCompiler createNewPackWithCompletionHandler:^(BOOL success) {
                if (!success)
                    return;
                
                [iconCompiler overwriteCurrentPackWithChanges:changesFlat
                                                     baseline:[baseline mutableCopy]
                                            completionHandler:^(BOOL success) {
                    dispatch_group_leave(group);
                }];
            }];
        } else {
            [iconCompiler overwriteCurrentPackWithChanges:changesFlat
                                                 baseline:[baseline mutableCopy]
                                        completionHandler:^(BOOL success) {
                dispatch_group_leave(group);
            }];
        }
    }
    
    if (self.containsDockChanges){
        dispatch_group_enter(group);
        SOSimpleDockChangeCompiler *dockCompiler = [[SOSimpleDockChangeCompiler alloc] init];
        
        SODockThemeBundle *dockTheme = [[SOAtomicAccessPoint sharedInstance] currentDockThemeBundle];
        if (!dockTheme.bundleIdentifier){
            [dockCompiler createNewThemeWithCompletionHandler:^(BOOL success) {
                if (!success)
                    return;
                
                [dockCompiler overwriteCurrentThemeWithChanges:changesFlat
                                                      baseline:[baseline mutableCopy]
                                             completionHandler:^(BOOL success) {
                    dispatch_group_leave(group);
                }];
            }];
        } else {
            [dockCompiler overwriteCurrentThemeWithChanges:changesFlat
                                                  baseline:[baseline mutableCopy]
                                         completionHandler:^(BOOL success) {
                dispatch_group_leave(group);
            }];
        }
    }
    
    dispatch_notify(group, dispatch_get_main_queue(), ^{
        [self completionAction];
    });
}

- (void)completionAction{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:SONotificationBaseClassUpdateBaseline
                      object:self];

    for (id<SOConfigurableContent> page in self.childViewControllers) {
        if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
            [page refreshOrLoadBaseline];
    }

    for (id<SOConfigurableContent> page in self.childViewControllers) {
        if ([page respondsToSelector:@selector(purgePendingChanges)])
            [page purgePendingChanges];
    }

    [self.pendingChangesCache removeAllObjects];

    [[[[SOAtomicAccessPoint sharedInstance] appIconServerConnection] remoteObjectProxy]
                            requestGlobalSettingsInvalidation];
    
    self.applyButton.enabled = NO;
    
    [[SOAtomicAccessPoint sharedInstance] clearAllUndoManagers];
    
    notify_post("com.saltysoft.themeChanged");
}
@end
