//Created by Salty on 8/12/26.

#import <Cocoa/Cocoa.h>

@interface SOPackViewItem : NSCollectionViewItem <NSPasteboardWriting>
@property (strong) NSURL *URL;
@property (assign) BOOL hasTags;
@property (strong) NSString *name;
- (instancetype)initWithName:(NSString *)name URL:(NSURL *)URL;
@end
