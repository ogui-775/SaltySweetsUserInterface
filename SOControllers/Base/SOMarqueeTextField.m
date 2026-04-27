//Created by Salty on 4/27/26.

#import "SOMarqueeTextField.h"

@interface SOMarqueeTextField ()
@property (strong) CATextLayer *currentText;
@property (strong) CATextLayer *upcomingText;
@end

@implementation SOMarqueeTextField

- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]){
        [self setWantsLayer:YES];
        
        self.currentText = [CATextLayer layer];
        self.upcomingText = [CATextLayer layer];
        
        CGColorRef textColor = [[NSColor labelColor] CGColor];
        [self.currentText setForegroundColor:textColor];
        [self.upcomingText setForegroundColor:textColor];
        
        [self.currentText setFontSize:14];
        [self.currentText setAlignmentMode:kCAAlignmentLeft];
        [self.upcomingText setFontSize:14];
        [self.upcomingText setAlignmentMode:kCAAlignmentLeft];
        
        CGFloat scale = [[NSScreen mainScreen] backingScaleFactor];
        [self.layer setContentsScale:scale];
        [self.currentText setContentsScale:scale];
        [self.upcomingText setContentsScale:scale];
    
        [self.layer addSublayer:self.currentText];
        [self.layer addSublayer:self.upcomingText];
        
        CGRect bounds = self.bounds;
        [self.currentText setFrame:bounds];
        [self.upcomingText setFrame:bounds];
    }
    return self;
}

- (void)animateFieldToShow:(NSString *)nextText{
    if (!self.currentText.string) {
           self.currentText.string = nextText;
           return;
       }

    CGFloat width = self.bounds.size.width;
    self.upcomingText.string = nextText;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.upcomingText.position = CGPointMake(width + (width/2), CGRectGetMidY(self.bounds));
    [CATransaction commit];

    [CATransaction begin];
    [CATransaction setAnimationDuration:0.5];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    [CATransaction setCompletionBlock:^{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.currentText.string = nextText;
        
        [self.currentText removeAllAnimations];
        [self.upcomingText removeAllAnimations];
        
        self.currentText.frame = self.bounds;
        self.upcomingText.string = @"";
        
        [CATransaction commit];
    }];

    CABasicAnimation *shift = [CABasicAnimation animationWithKeyPath:@"position.x"];
    shift.byValue = @(-width);
    shift.fillMode = kCAFillModeForwards;
    shift.removedOnCompletion = NO;

    [self.currentText addAnimation:shift forKey:@"marquee"];
    [self.upcomingText addAnimation:shift forKey:@"marquee"];

    [CATransaction commit];
    
}

@end
