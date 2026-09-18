//Created by Salty on 2/7/26.

#import "Base/SOPageControllerBase.h"
#import "../AppDelegate.h"
#import "Base/SOConfigurablePageControllerBase.h"
#import "../Services/SOSignatures.h"

@interface SOWelcomePageController : SOConfigurablePageControllerBase
@property (strong, nonatomic) IBOutlet NSTextField * currentThemeDisplay;
@property (strong, nonatomic) IBOutlet NSTextField * currentIconPackDisplay;
@property (strong, nonatomic) IBOutlet NSTextField * currentApplicationVersionDisplay;
@property (strong, nonatomic) IBOutlet NSTextField * currentThemeAuthorNameDisplay;
@property (strong, nonatomic) IBOutlet NSTextField * currentThemeAuthorFingerprintDisplay;
@property (strong, nonatomic) IBOutlet NSImageView * currentThemeStatusImageView;
@property (strong, nonatomic) IBOutlet NSTextField * currentThemeStatusTextLabel;
@end
