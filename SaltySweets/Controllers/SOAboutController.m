//Created by Salty on 8/16/26.

#import "SOAboutController.h"

const NSString *attrStr = @"Special thanks to:\n\n\nDavi for testing, theme support, GUI elements, and icons.\n\nschm1dt for testing and feedback on design.\n\nbedtime for ammonia, PluginPlayground, and guidance.\n\n♡﹒ Joke_Bamb﹒♡ for application icons and GUI elements.";

@implementation SOAboutController
- (void)awakeFromNib{
    [super awakeFromNib];
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *ver = [info objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.stringValue = [NSString stringWithFormat:@"v%@", ver];
    
    self.creditsTextView.string = (NSString *)attrStr;
}
@end
