//Created by Salty on 2/8/26.

#import <Cocoa/Cocoa.h>

//#import "AppDelegate.h"
#import "SOConfigurableContent.h"
#import <SharedKeys/SOSharedKeys.h>
#import <SharedBundles/SharedBundles.h>
#import "SOSHA256.h"
#import "../Services/SOSignatures.h"
#import "../../SOSheets/SOChangeConfirmSheetController.h"
#import "../../SOSheets/SOThemeCreationSheetController.h"
#import "../Services/SOErrorAlert.h"

@interface SOChangeCompiler : NSObject

@property (strong, nonatomic) SOChangeConfirmSheetController * dockThemeConfirmSheet;
@property (strong, nonatomic) SOChangeConfirmSheetController * iconThemeConfirmSheet;
@property (strong, nonatomic) SOThemeCreationSheetController * dockThemeCreateSheet;
@property (strong, nonatomic) SOThemeCreationSheetController * iconThemeCreateSheet;
@property (strong, nonatomic) NSDictionary * suppliedBaseline;
@end
