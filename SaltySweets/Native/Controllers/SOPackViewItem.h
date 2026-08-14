//Created by Salty on 8/12/26.

#import <Cocoa/Cocoa.h>

@interface SOPackViewItem : NSCollectionViewItem
@property (strong) NSURL *URL;

- (instancetype)initWithName:(NSString *)name URL:(NSURL *)URL;
@end
