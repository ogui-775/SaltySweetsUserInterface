//Created by Salty on 4/23/26.

#import <AppKit/AppKit.h>
#import <SharedBundles/SharedBundles.h>
#import <SharedKeys/SharedKeys.h>

#import "../Services/SONSWindowAuxContext.h"
#import "../../SOControllers/Base/SODragAwareImageView.h"
#import "../Helpers/SOJXLEncoder.h"
#import "../../SaltySweets/AppDelegate.h"

@class SOCreationHolder;

@interface SONSWindowAuxSiconCreationController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(SONSWindowAuxContextSiconCreation *)ctx;

- (IBAction)newSiconWasClicked:(NSMenuItem *)sender;
- (IBAction)openSiconWasClicked:(NSMenuItem *)sender;

@property (weak) SONSWindowAuxContextSiconCreation *context;
@property (strong, nonatomic) NSMutableDictionary<NSString *, SOCreationHolder *> *keyToCreationHolder;

@property (assign) unsigned int currentFileSize;
@property (assign) unsigned int currenImageCount;
@property (assign) unsigned int currentDataOffset;

@property (strong) IBOutlet NSTextField *nameField;
@property (strong) IBOutlet NSTableView *fileDetailTable;
@property (strong) IBOutlet NSButton *compileButton;
@property (strong) NSMutableDictionary *loadedSiconDataDict;
@property (strong) IBOutlet NSSwitch *applyJXLSwitch;
@property (strong) IBOutlet SODragAwareImageView *darkVariantWell;
@property (strong) IBOutlet NSTextField *darkVariantFilesize;
@property (strong) IBOutlet SODragAwareImageView *lightWell;
@property (strong) IBOutlet NSTextField *lightFilesize;
@property (strong) IBOutlet SODragAwareImageView *selectedVariantWell;
@property (strong) IBOutlet NSTextField *selectedVariantFilesize;

@property (strong) IBOutlet NSSegmentedControl *scaleSelector;
@property (strong) IBOutlet NSSegmentedControl *sizeSelector;
@end
