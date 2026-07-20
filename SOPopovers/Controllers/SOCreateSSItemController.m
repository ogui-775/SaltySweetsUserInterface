//Created by Salty on 7/20/26.

#import "SOCreateSSItemController.h"

@implementation SOCreateSSItemController
- (IBAction)closeWasPressed:(id)sender{
    [self.view.window close];
}

- (IBAction)createDockTheme:(id)sender{
    SOSimpleDockChangeCompiler *compiler = [[SOSimpleDockChangeCompiler alloc] init];
    
    [compiler createNewThemeWithCompletionHandler:^(BOOL success) {
        [self.view.window close];
    }];
}

- (IBAction)createIconPack:(id)sender{
    SOSimpleIconChangeCompiler *compiler = [[SOSimpleIconChangeCompiler alloc] init];
    
    [compiler createNewPackWithCompletionHandler:^(BOOL success) {
        [self.view.window close];
    }];
}
@end
