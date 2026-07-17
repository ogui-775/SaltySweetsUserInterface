//Created by Salty on 2/7/26.

#import <AppKit/AppKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import "../../SaltySweets/SOBaseline.h"
#import "../../SaltySweets/Services/SOAtomicAccessPoint.h"

@interface SOPageControllerBase : NSViewController
@property (strong) SOAtomicAccessPoint *accessPoint;
@end
