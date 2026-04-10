//Created by Salty on 2/20/26.

#import "SOChangeConfirmSheetController.h"

@implementation SOChangeConfirmSheetController

- (instancetype)init{
    return [self initWithWindowNibName:@"SOChangeConfirmSheet"];
}

- (void)supplyChanges:(NSArray<SOChange *> *)pendingChangeArray{
    self.internalChangeArray = [[NSArray alloc] initWithArray:pendingChangeArray];
    self.applyToChange       = [NSMapTable strongToStrongObjectsMapTable];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.internalChangeArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSInteger idx = [tableColumn.identifier isEqualToString:@"ApplyColumn"] ? 0 : 1;
    
    if (idx == 0) {
        NSTableCellView * cell =
            [tableView makeViewWithIdentifier:@"ApplyCell" owner:self];

        if (!cell) {
            cell = [[NSTableCellView alloc] init];
            cell.identifier = @"ApplyCell";

            NSButton * button = [[NSButton alloc] init];
            button.buttonType = NSButtonTypeSwitch;
            button.title = @"";
            button.target = self;
            button.action = @selector(applyToggleClicked:);
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.state = NSControlStateValueOn;
            [self.applyToChange setObject:button forKey:@(row)];

            [cell addSubview:button];

            [NSLayoutConstraint activateConstraints:@[
                [button.centerXAnchor constraintEqualToAnchor:cell.centerXAnchor],
                [button.centerYAnchor constraintEqualToAnchor:cell.centerYAnchor]
            ]];

            cell.textField = nil;
        }

        return cell;
    } else if (idx == 1){
        NSTextField * text = [[NSTextField alloc] init];
        text.drawsBackground = NO;
        [text setBezeled:NO];
        text.stringValue = [self.internalChangeArray objectAtIndex:row].changeNote;
        text.cell.lineBreakMode = NSLineBreakByWordWrapping;
        text.cell.usesSingleLineMode = NO;
        text.frame = tableView.frame;
        return text;
    } else {
        return nil;
    }
}

- (IBAction)applyToggleClicked:(NSButton *)sender {
    BOOL anyOn = NO;

    for (NSButton * b in self.applyToChange.objectEnumerator) {
        if (b.state == NSControlStateValueOn) {
            anyOn = YES;
            break;
        }
    }

    self.confirmButton.enabled = anyOn;
}

- (IBAction)cancelClicked:(id)sender{
    [self.window.sheetParent endSheet:self.window
                            returnCode:NSModalResponseCancel];
}

- (IBAction)confirmClicked:(id)sender{
    NSMutableIndexSet * results = [[NSMutableIndexSet alloc] init];
    
    for (NSNumber * i in self.applyToChange){
        if ([[self.applyToChange objectForKey:i] state] == NSControlStateValueOn){
            [results addIndex:i.unsignedIntValue];
        }
    }
    
    self.internalChangeArray = [self.internalChangeArray objectsAtIndexes:results];
    
    [self.window.sheetParent endSheet:self.window
                            returnCode:NSModalResponseOK];
}

@end

@implementation SOChangeConfirmSheet
- (BOOL)canBecomeKeyWindow{
    return YES;
}
@end
