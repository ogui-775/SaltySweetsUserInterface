//Created by Salty on 2/20/26.

#import <AppKit/AppKit.h>
#import "../SaltySweets/SOConfigurableContent.h"

@interface SOChangeConfirmSheetController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>
@property (strong, nonatomic) IBOutlet NSTableView * changeTable;
@property (strong, nonatomic) NSArray<SOChange *> * internalChangeArray;
@property (strong, nonatomic) NSMapTable * applyToChange;

@property (strong, nonatomic) IBOutlet NSButton * confirmButton;

- (void)supplyChanges:(NSArray<SOChange *> *)pendingChangeArray;
- (IBAction)applyToggleClicked:(NSButton *)sender;
@end

@interface SOChangeConfirmSheet : NSWindow @end
