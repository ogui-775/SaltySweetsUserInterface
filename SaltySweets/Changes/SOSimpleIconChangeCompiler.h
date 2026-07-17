//Created by Salty on 7/14/26.

#import <Foundation/Foundation.h>

#import "SOChangeCompilerBase.h"
#import "../../SOSheets/SOProgressSheetController.h"
#import "../../SOSheets/SOThemeCreationSheetController.h"
#import "../SOViewPane.h"

@interface SOSimpleIconChangeCompiler : SOChangeCompilerBase
@property (strong) SOThemeCreationSheetController *creationController;
@property (strong) SOProgressSheetController *progressController;

- (void)overwriteCurrentPackWithChanges:(NSArray<SOChange *> *)changeArrayForInsertion
                               baseline:(NSDictionary<NSString *, id> *)baseline
                      completionHandler:(void(^)(BOOL success))completion;

- (void)overrideCurrentPackWithTemporaryChanges:(NSArray<SOChange *> *)changeArrayForTemporaryUsage
                                       baseline:(NSDictionary<NSString *, id> *)baseline
                              completionHandler:(void(^)(BOOL success))completion;

- (void)createNewPackWithCompletionHandler:(void (^)(BOOL success))completion;
@end
