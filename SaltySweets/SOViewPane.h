//Created by Salty on 2/6/26.

#import <Cocoa/Cocoa.h>
#import <notify.h>
#import <CoreImage/CoreImage.h>
#import <CoreImage/CIFilterBuiltins.h>

#import "Services/SOAtomicAccessPoint.h"
#import "Changes/SOConfigurableContent.h"
#import "Changes/SOSimpleIconChangeCompiler.h"
#import "Changes/SOSimpleDockChangeCompiler.h"
#import "../SOControllers/Base/SOPageControllerBase.h"
#import "../../icon-server/icon-server/SOIconServerXPCProtocol.h"

@interface SOViewPane : NSViewController
- (void)requestPageChangeTo:(NSViewController *)controller;
@property (weak, nonatomic) IBOutlet NSView *displayView;
+ (instancetype)defaultInstance;
@end
