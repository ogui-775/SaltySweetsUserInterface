//Created by Salty on 7/31/26.

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Symbols/Symbols.h>

#import "../SOControllers/Base/SOPageControllerBase.h"

@interface SONavigatorBarItem : NSObject
@property (strong, readonly) NSImage *image;
@property (strong, readonly) NSString *title;
@property (strong, readonly) NSViewController *boundController;

- (instancetype)initWithSymbolName:(NSString *)symbolName title:(NSString *)title controller:(NSViewController *)controller;
@end
