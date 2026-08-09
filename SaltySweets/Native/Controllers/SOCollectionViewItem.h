//Created by Salty on 8/7/26.

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface SOCollectionViewItem : NSCollectionViewItem
@property (weak) NSViewController *boundController;
@property (assign) BOOL underlined;
@end
