//Created by Salty on 2/17/26.

#import "SOAttributionsPageController.h"

@implementation SOAttributionsPageController

- (void)awakeFromNib{
    [self.attributionsStaticBox setString:[self attributesText]];
    [self.attributionsStaticBox setFont:[NSFont fontWithName:@"Lucida Grande" size:24]];
}

- (NSString *)attributesText{
    return @"Special thanks to:\n\n\nDavi for testing, theme support, and icons.\n\nschm1dt for testing and feedback on design.\n\nbedtime for ammonia, PluginPlayground, and guidance.\n\n♡﹒ Joke_Bamb﹒♡ for application icons and GUI elements.";
}

@end
