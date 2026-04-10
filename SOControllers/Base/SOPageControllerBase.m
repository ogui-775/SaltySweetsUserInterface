//Created by Salty on 2/7/26.

#import "SOPageControllerBase.h"

@implementation SOPageControllerBase
- (instancetype)init {
    NSString *nibName = [[self className] stringByReplacingOccurrencesOfString:@"PageController"
                                                                   withString:@"View"];
    return [super initWithNibName:nibName bundle:nil];
}
@end
