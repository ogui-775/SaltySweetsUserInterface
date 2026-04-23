//Created by Salty on 4/19/26.

#import <AppKit/AppKit.h>
#import "../AppDelegate.h"

@interface SOErrorAlert : NSObject
+ (void)runModalTerminatingError:(NSString *)errorStr;
@end
