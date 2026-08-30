//Created by Salty on 8/7/26.

#import "SOCollectionViewItem.h"

@implementation SOCollectionViewItemButton

@end

@implementation SOCollectionViewItem
- (instancetype)init{
    self = [super init];
    if (self){
        CGRect bounds    = CGRectMake(0,
                                      -10,
                                      100,
                                      50);
        
        self.view        = [[NSView alloc] initWithFrame:bounds];
        self.innerButton = [[SOCollectionViewItemButton alloc] initWithFrame:bounds];
        self.innerButton.delegate = self;
        [self.view addSubview:self.innerButton];
        
        self.innerButton.font          = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
        self.innerButton.alignment     = NSTextAlignmentCenter;
        self.innerButton.imagePosition = NSImageAbove;
        self.innerButton.bordered      = NO;
        self.innerButton.imageScaling  = NSImageScaleProportionallyDown;
    }
    return self;
}


@end
