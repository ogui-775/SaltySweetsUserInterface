
#import "SOCalendarDockTileReplacementPageController.h"
@interface SOCalendarDockTileReplacementPageController ()
@property (strong) SOCalendarConfigHolder *config;
@end

@implementation SOCalendarDockTileReplacementPageController
- (void)awakeFromNib{
    [super awakeFromNib];
    [self.compositionView setWantsLayer:YES];
    [self.compositionView.layer setBackgroundColor:NSColor.darkGrayColor.CGColor];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    self.config = [SOCalendarConfigHolder currentPackConfig:self.baselineState];
    [self drawCalendar];
}

- (void)drawCalendar{
    SOCalendarConfigHolder *c = [self config];
    
    const SOEncodedKeyPath tCal = {
        .rootKey = &kSOIconsDockTilePluginDict,
        .components = @[@"calendar.base"]
    };
    
    NSImage *base = [self loadImageForEncodedKeypath:&tCal];
    
    if (!base)
        return;
    
    CGImageRef img = [base CGImageForProposedRect:NULL
                                          context:nil
                                            hints:nil];
    
    if (!img)
        return;
    
    CGImageRef outImage = [SOCalendarDrawing drawDateStringsToImage:img
                                                         withConfig:c
                                                           withDate:[NSDate now]];
    
    if (!outImage)
        return;
    
    NSImage *drawn = [[NSImage alloc] initWithCGImage:outImage
                                                 size:CGSizeMake(0, 0)];
    
    [self.compositionView.layer setContents:drawn];
}
@end
