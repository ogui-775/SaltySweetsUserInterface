//Created by Salty on 7/14/26.
#import <Foundation/Foundation.h>
#import <SharedClasses/SharedClasses.h>
#import <SharedBundles/SharedBundles.h>

#import "SOConfigurableContent.h"
#import "../../SOSheets/SOChangeConfirmSheetController.h"
#import "../Services/SOSignatures.h"

@interface SOChangeCompilerBase : NSObject
@property (strong) SOChangeConfirmSheetController *iconThemeConfirmSheet;
@property (strong) SOChangeConfirmSheetController *dockThemeConfirmSheet;

- (NSString *)describeChange:(SOChange *)change;
- (void)purgeFilesIfNeededWithRelativePaths:(NSMutableArray<NSString *> *)purgeFileRelativePathCollection fromBundle:(SONSBundle *)bundle;
- (BOOL)writeFileFromChange:(SOChange *)change toBundle:(SONSBundle *)bundle;
- (void)populateIconDictionary:(NSMutableDictionary *)dict
                    withChange:(SOChange *)change
               purgeCollection:(NSMutableArray<NSString *> *)purgeCollection;
- (void)listChangesToIconBundle:(SOSiconPackBundle *)bundle
                        changes:(NSArray<SOChange *> *)changes
                     completion:(void (^)(NSModalResponse reponse, NSArray<SOChange *> *approvedChanges))completion;
@end
