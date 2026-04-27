//Created by Salty on 4/27/26.

#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SOMarqueeTextField : NSView
- (void)animateFieldToShow:(NSString *)nextText;
@end
