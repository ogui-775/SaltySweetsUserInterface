//Created by Salty on 4/19/26.

#import "SOErrorAlert.h"

@implementation SOErrorAlert

+ (void)runModalTerminatingError:(NSString *)errorStr{
    dispatch_async(dispatch_get_main_queue(), ^void{
        NSAlert * alert = [[NSAlert alloc] init];
        alert.messageText = errorStr;
        alert.alertStyle = NSAlertStyleCritical;
        [alert addButtonWithTitle:@"Ok"];
        alert.buttons[0].keyEquivalent = @"\r";
        NSModalResponse response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            [alert.window close];
        }
    });
}

@end
