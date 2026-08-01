//Created by Salty on 2/2/26.

#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

#import "SOViewPane.h"
#import "SONavigatorBar.h"

@interface SONavigatorPane : NSViewController <NSSplitViewDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource>
@property (strong) IBOutlet NSSplitView *contentSplitView;
@property (strong) IBOutlet NSOutlineView *submenuChooser;
@property (assign) IBOutlet SOViewPane *viewPaneController;
@property (strong) IBOutlet SONavigatorBar *navBarController;
@end
