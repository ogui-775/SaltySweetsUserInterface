//Created by Salty on 7/31/26.

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Symbols/Symbols.h>

#import "../SOControllers/Base/SOPageControllerBase.h"

@interface SONavigatorBarItem : NSTabViewItem
- (instancetype)initWithFallbackSymbolName:(NSString *)symbolName
                       preferredImageNamed:(NSString *)assetImage
                                     title:(NSString *)title
                                controller:(NSViewController *)controller;
@end
