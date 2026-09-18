//Created by Salty on 8/7/26.

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOMainMenuLayout : NSCollectionViewCompositionalLayout
- (instancetype)initCustom;
@end

@interface SOMainMenuSectionHeader : NSView
@property (copy, nonatomic) NSString *title;
@end
NS_ASSUME_NONNULL_END
