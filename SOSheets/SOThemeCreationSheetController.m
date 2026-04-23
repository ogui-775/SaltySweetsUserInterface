//Created by Salty on 2/21/26.

#import "SOThemeCreationSheetController.h"

@implementation SOThemeCreationSheetController

- (instancetype)initWithCreationType:(NSString *)type{
    if (self = [super initWithWindowNibName:@"SOThemeCreationSheet"]){
        self.type = type;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.typeBox.stringValue = [NSString stringWithFormat:@"Create new %@", self.type];
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
