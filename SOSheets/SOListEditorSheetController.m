//Created by Salty on 4/16/26.

#import "SOListEditorSheetController.h"

@implementation SOListEditorSheetController
- (instancetype)initWithListContents:(NSMutableArray<NSString *> *)listContents name:(NSString *)name{
    if (self = [super initWithWindowNibName:@"SOListEditorSheet"]){
        self.listContents = [[listContents sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        self.windowName = name;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.editorNameLabel setStringValue:self.windowName];
    [self.listTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.listContents.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    NSTextField * cell = [[NSTextField alloc] initWithFrame:tableView.frame];
    cell.bordered = NO;
    cell.drawsBackground = NO;
    cell.editable = YES;
    cell.stringValue = self.listContents[row] ?: @"";
    cell.delegate = self;
    
    return cell;
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    NSTextField * sender = obj.object;
    NSInteger row = [self.listTableView rowForView:sender];
    
    if (row != -1 && row < self.listContents.count) {
        NSString * newValue = sender.stringValue;
        
        if (newValue.length == 0) {
            [self.listContents removeObjectAtIndex:row];
            [self.listTableView reloadData];
        } else {
            self.listContents[row] = newValue;
        }
    }
}

- (IBAction)minusWasPressed:(NSButton *)sender {
    if (self.listContents.count == 0) return;

    NSInteger selectedRow = self.listTableView.selectedRow;
    NSInteger indexToRemove;

    if (selectedRow != -1) {
        indexToRemove = selectedRow;
    } else {
        indexToRemove = self.listContents.count - 1;
    }

    [self.listContents removeObjectAtIndex:indexToRemove];
    [self.listTableView reloadData];
}

- (IBAction)plusWasPressed:(NSButton *)sender {
    BOOL hasEmptyRow = NO;
    for (NSString * str in self.listContents) {
        if (str.length == 0) {
            hasEmptyRow = YES;
            break;
        }
    }

    if (!hasEmptyRow) {
        [self.listContents addObject:@""];
        [self.listTableView reloadData];
        
        NSInteger newRow = self.listContents.count - 1;
        [self.listTableView scrollRowToVisible:newRow];
        [self.listTableView editColumn:0 row:newRow withEvent:nil select:YES];
    }
}

- (IBAction)okWasPressed:(NSButton *)sender{
    [self.window makeFirstResponder:sender];
    [self.sheetParent endSheet:self.window
                    returnCode:NSModalResponseOK];
}
@end

@implementation SOListEditorSheet
- (BOOL)canBecomeKeyWindow{
    return YES;
}

- (BOOL)acceptsFirstResponder{
    return YES;
}
@end
