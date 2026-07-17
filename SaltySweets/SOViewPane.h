//Created by Salty on 2/6/26.
#import <Cocoa/Cocoa.h>
#import <notify.h>

#import "Services/SOAtomicAccessPoint.h"
#import "Changes/SOConfigurableContent.h"
#import "Changes/SOSimpleIconChangeCompiler.h"
#import "Changes/SOChangeCompiler.h"
#import "../SOControllers/Base/SOPageControllerBase.h"
#import "../../icon-server/icon-server/SOIconServerXPCProtocol.h"

@interface SOViewPane : NSViewController
- (void)requestPageChangeTo:(NSViewController *)controller;
+ (instancetype)defaultInstance;
@end
