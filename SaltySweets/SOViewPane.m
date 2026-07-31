//Created by Salty on 2/6/26.

#import "SOViewPane.h"

static SOViewPane * _instance = nil;

@interface SOViewPane()  <SOConfigurableContentDelegate>
@property (nonatomic, strong) IBOutlet NSButton * applyButton;

@property (nonatomic, strong) NSViewController * currentPage;

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

- (void)addFooterView:(NSViewController *)controller {
    [self addChildViewController:controller];
    [self.infoView setSubviews:@[controller.view]];
}

- (void)requestPageChangeTo:(NSViewController *)page {
    if (![self.childViewControllers containsObject:page])
        [self addChildViewController:page];
    
    page.view.frame = self.topView.bounds;
    [self.topView setSubviews:@[page.view]];

    self.currentPage = page;

    if ([page conformsToProtocol:@protocol(SOConfigurableContent)]) {
        ((id<SOConfigurableContent>)page).changeDelegate = self;
    }
}

- (IBAction)expandOrContractInfoView:(NSButton *)sender {
    [self.infoView.window makeFirstResponder:nil];
    
    CGFloat expandedHeight = 400.0;
    CGFloat collapsedHeight = 34.0;
    CGFloat viewWidth = self.topView.bounds.size.width;
    
    if (!self.infoView) {
        self.infoViewController = [NSClassFromString(@"SOCollectionPageController") new];
        
        [self.infoViewController.view setFrame:CGRectMake(0, 0, viewWidth, expandedHeight)];
        
        [self.view addSubview:self.infoViewController.view
                    positioned:NSWindowBelow
                    relativeTo:self.splitBarView];
        
        self.infoView = self.infoViewController.view;
        self.infoView.autoresizingMask = NSViewWidthSizable;
        [self.infoView setHidden:YES];
    }
    
    if (self.infoViewExpanded) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.3;
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            [[self.topView animator] setContentFilters:@[]];
            
            [[self.splitBarView animator] setFrame:CGRectMake(0, collapsedHeight, viewWidth, collapsedHeight)];
            [[self.infoView animator] setHidden:YES];
        } completionHandler:^{
            self.infoViewExpanded = NO;
        }];
        return;
    }

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.3;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        static CIFilter *filter = nil;
        if (!filter) {
            filter = CIFilter.gaussianBlurFilter;
            [filter setDefaults];
            [filter setValue:@(5) forKey:@"radius"];
            [self.infoView setWantsLayer:YES];
            self.infoView.layer.backgroundColor = NSColor.windowBackgroundColor.CGColor;
        }
        [[self.topView animator] setContentFilters:@[filter]];
        
        [[self.splitBarView animator] setFrame:CGRectMake(0, expandedHeight, viewWidth, collapsedHeight)];
        
    } completionHandler:^{
        self.infoViewExpanded = YES;
        [[self.infoView animator] setHidden:NO];
    }];
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
                if (!success){
                    dispatch_group_leave(group);
                    return;
                }

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
                if (!success){
                    dispatch_group_leave(group);
                    return;
                }
                
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
