//Created by Salty on 2/23/26.

#import "SOIconReplacementPageController.h"

@implementation SOIconReplacementPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    self.lastSelectedFolder = self.folderComboBox.stringValue;
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    
}

- (IBAction)folderSelectionDidChange:(NSComboBox *)sender{
    if ([sender.stringValue isEqualToString:self.lastSelectedFolder])
        return;
    
    self.lastSelectedFolder = sender.stringValue;
    
    if ([sender.stringValue isEqualToString:@"Applications"]){
        
    } else if ([sender.stringValue isEqualToString:@"CoreServices"]){
        
    } else if ([sender.stringValue isEqualToString:@"Open File Picker..."]){
        
    }
}

@end
