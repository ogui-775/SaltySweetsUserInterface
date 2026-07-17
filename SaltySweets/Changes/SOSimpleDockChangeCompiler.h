//Created by Salty on 7/16/26.

#import "SOChangeCompilerBase.h"
#import "../../SOSheets/SOThemeCreationSheetController.h"
#import "../../SOSheets/SOProgressSheetController.h"
#import "../SOViewPane.h"

@interface SOSimpleDockChangeCompiler : SOChangeCompilerBase
@property (strong) SOThemeCreationSheetController *creationController;
@property (strong) SOProgressSheetController *progressController;

- (void)createNewThemeWithCompletionHandler:(void(^)(BOOL success))completion;

- (void)overwriteCurrentThemeWithChanges:(NSArray<SOChange *> *)changeArrayForInsertion
                                baseline:(NSDictionary<NSString *, id> *)baseline
                       completionHandler:(void(^)(BOOL success))completion;

- (void)overrideCurrentThemeWithTemporaryChanges:(NSArray<SOChange *> *)changeArrayForTemporaryUsage
                                        baseline:(NSDictionary<NSString *, id> *)baseline
                               completionHandler:(void(^)(BOOL success))completion;
@end
