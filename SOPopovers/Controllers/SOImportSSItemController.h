//Created by Salty on 7/20/26.

#import <AppKit/AppKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import "../../SaltySweets/Services/SOAtomicAccessPoint.h"
#import "../../SaltySweets/SOViewPane.h"
#import "../../SaltySweets/Native/Controllers/SOPackViewController.h"


@interface SOImportSSItemController : NSViewController
@property (weak) IBOutlet SOPackViewController *packViewController;
@end

@interface SOImportDestinationBox : NSBox <NSDraggingDestination>

@end
