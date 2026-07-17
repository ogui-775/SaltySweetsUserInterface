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
- (void)applyDockChanges:(NSArray<SOChange *> *)changes
                toBundle:(SODockThemeBundle *)bundle
            withBaseline:(NSMutableDictionary *)baseline
              completion:(void (^)(BOOL))completion;
- (void)populateIconDictionary:(NSMutableDictionary *)dict
                    withChange:(SOChange *)change
               purgeCollection:(NSMutableArray<NSString *> *)purgeCollection;
- (void)listChangesToIconBundle:(SOSiconPackBundle *)bundle
                        changes:(NSArray<SOChange *> *)changes
                     completion:(void (^)(NSModalResponse response, NSArray<SOChange *> *approvedChanges))completion;
- (void)listChangesToDockBundle:(SODockThemeBundle *)bundle
                        changes:(NSArray<SOChange *> *)changes
                     completion:(void (^)(NSModalResponse response, NSArray<SOChange *> *approvedChanges))completion;
- (NSMutableDictionary *)recursivelyBuildDictionary:(const SOEncodedKey)encodedKeyWithDict;
@end
