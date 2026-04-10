//Created by Salty on 2/8/26.

#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"
#import "SOConfigurableContent.h"
#import <SharedKeys/SOSharedKeys.h>
#import "SOSHA256.h"
#import "Services/SOSignatures.h"
#import "../SOSheets/SOChangeConfirmSheetController.h"
#import "../SOSheets/SOThemeCreationSheetController.h"

@interface SOChangeCompiler : NSObject

@property (strong, nonatomic) SOChangeConfirmSheetController * confirmSheet;
@property (strong, nonatomic) SOThemeCreationSheetController * createSheet;

- (void)generateThemeBundleWithBaseline:(NSDictionary *)baseline
                                changes:(NSArray<SOChange *> *)changeArray
                               asUpdate:(BOOL)update
                             completion:(void (^)(BOOL success))completion;

@end
