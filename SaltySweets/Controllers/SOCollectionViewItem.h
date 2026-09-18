//Created by Salty on 8/7/26.

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <CoreImage/CIFilterBuiltins.h>

@class SOCollectionViewItemButton;

@interface SOCollectionViewItem : NSCollectionViewItem
@property (strong) SOCollectionViewItemButton *innerButton;
@property (weak) NSViewController *boundController;
@property (assign) BOOL isSiconStudioButton;
@end

@interface SOCollectionViewItemButton : NSButton
@property (weak) NSCollectionView *collectionView;
@property (weak) SOCollectionViewItem *delegate;
@end
