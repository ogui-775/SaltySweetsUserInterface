//Created by Salty on 2/21/26.

#import "SOThemeCreationSheetController.h"

@implementation SOThemeCreationSheetController

- (instancetype)init{
    self = [super initWithWindowNibName:@"SOThemeCreationSheet"];
    return self;
}

- (IBAction)createThemeClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                            returnCode:NSModalResponseOK];
}

- (IBAction)cancelClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                            returnCode:NSModalResponseCancel];
}

- (void)controlTextDidChange:(NSNotification *) obj{
    if (![self.nameBox.stringValue isEqualToString:@""]){
        self.createButton.enabled = YES;
    } else {
        self.createButton.enabled = NO;
    }
}

@end

@implementation SOThemeCreationSheet
- (BOOL)canBecomeKeyWindow{
    return YES;
}
@end
