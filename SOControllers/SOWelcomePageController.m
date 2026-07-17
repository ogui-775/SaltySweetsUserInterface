//Created by Salty on 2/7/26.

#import "SOWelcomePageController.h"

@implementation SOWelcomePageController
- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self refreshOrLoadBaseline];
    
    self.currentApplicationVersionDisplay.stringValue = [NSString stringWithFormat:@"v%@",
                                                         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

- (void)refreshOrLoadBaseline{
    self.currentIconPackDisplay.stringValue = [[self.accessPoint currentIconPackBundleName] stringByReplacingOccurrencesOfString:@".siconpack" withString:@""];
    self.currentThemeDisplay.stringValue = [[self.accessPoint currentDockThemeBundleName] stringByReplacingOccurrencesOfString:@".bundle" withString:@""];
    self.currentThemeAuthorNameDisplay.stringValue = [self getBaselineForEncodedKey:&kSODockThemePlainAuthorName];
    
    NSString * currentTheme = [self.accessPoint currentDockThemeBundleName];
    
    if (![currentTheme isEqualToString:@""]){
        
        NSBundle * currentThemeBundle = [self.accessPoint currentDockThemeBundle];
        
        BOOL verified = [SOSignatures verifyThemeAuthorship:currentThemeBundle];
        
        self.currentThemeStatusImageView.image = verified ?
            [NSImage imageNamed:@"NSStatusAvailable"] : [NSImage imageNamed:@"NSStatusUnavailable"];
        
        self.currentThemeStatusTextLabel.stringValue = verified ?
        @"Theme verified (Original)" : @"Theme is redist/copy - check fingerprint";
        
        self.currentThemeAuthorFingerprintDisplay.stringValue = [SOSignatures themeAuthorFingerprint:currentThemeBundle] ?: @"";
        
    } else {
        self.currentThemeStatusImageView.image = [NSImage imageNamed:@"NSStatusPartiallyAvailable"];
        self.currentThemeStatusTextLabel.stringValue = @"Theme is unsigned/no theme loaded";
    }
}

@end
