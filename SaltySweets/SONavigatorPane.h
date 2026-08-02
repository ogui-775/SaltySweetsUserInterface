//Created by Salty on 2/2/26.

#import <AppKit/AppKit.h>

#import "Services/SOAtomicAccessPoint.h"

@interface SONavigatorPane : NSViewController <NSOutlineViewDataSource>
@property (weak, nonatomic) IBOutlet NSOutlineView *outlineView;
@end

@interface SONavigatorPaneObject : NSObject
@property (strong) NSString *title;
@property (assign) BOOL containsChildren;
@property (strong) NSMutableArray<SONavigatorPaneObject *> *children;

@property (strong) SONSBundle *bundle;

- (instancetype)initWithTitle:(NSString *)title bundle:(SONSBundle *)bundle containsChildren:(BOOL)containsChildren;
@end
