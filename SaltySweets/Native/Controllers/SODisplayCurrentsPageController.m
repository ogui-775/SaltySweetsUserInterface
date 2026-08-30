//Created by Salty on 8/30/26.

#import "SODisplayCurrentsPageController.h"

#import "../../SOViewPane.h"

@interface SODisplayCurrentsPopoverController : NSViewController
@property (weak) NSTextField *fingerprint;
@property (weak) NSTextField *signatureConfirmation;
@end

@implementation SODisplayCurrentsPopoverController
@end

@interface SODisplayCurrentsPageController ()
@property (strong) NSPopover *popover;
@end

@implementation SODisplayCurrentsPageController
- (void)awakeFromNib{
    [super awakeFromNib];
    
    [[SOViewPane defaultInstance] registerConfigurablePageControllerForBaselineUpdates:self];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    self.dockThemeNameDisplay.stringValue = [[[SOAtomicAccessPoint sharedInstance] currentDockThemeBundle] themeNameAndAuthor];
    
    self.iconPackNameDisplay.stringValue = [[[SOAtomicAccessPoint sharedInstance] currentIconPackBundle] packNameAndAuthor];
}

- (IBAction)showDockThemeFingerprint:(NSButton *)sender{
    static BOOL isPopoverShown = NO;
    
    if (!self.popover){
        self.popover = [[NSPopover alloc] init];

        SODisplayCurrentsPopoverController *c = [SODisplayCurrentsPopoverController new];
        NSView *inner = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 600, 60)];
        [c setView:inner];
        NSTextField *fingerprintField = [[NSTextField alloc] initWithFrame:CGRectMake(10,
                                                                                      10,
                                                                                      inner.bounds.size.width - 5,
                                                                                      15)];
        fingerprintField.editable = NO;
        fingerprintField.bordered = NO;
        fingerprintField.usesSingleLineMode = NO;
        fingerprintField.lineBreakMode = NSLineBreakByWordWrapping;
        fingerprintField.drawsBackground = NO;
        fingerprintField.selectable = YES;
        
        [inner addSubview:fingerprintField];
        [c setFingerprint:fingerprintField];
        
        NSTextField *signatureConfirmation = [[NSTextField alloc] initWithFrame:CGRectMake(10, 40, 600, 15)];
        signatureConfirmation.editable = NO;
        signatureConfirmation.drawsBackground = NO;
        signatureConfirmation.bordered = NO;
        signatureConfirmation.usesSingleLineMode = YES;
        signatureConfirmation.selectable = NO;
        
        [inner addSubview:signatureConfirmation];
        [c setSignatureConfirmation:signatureConfirmation];
        
        [[self popover] setContentViewController:c];
    }
    
    if (!isPopoverShown){
        SODisplayCurrentsPopoverController *c = (SODisplayCurrentsPopoverController *)[self.popover contentViewController];
        
        [[c fingerprint] setStringValue:[SOSignatures themeAuthorFingerprint:self.accessPoint.currentDockThemeBundle]];
        BOOL valid = [SOSignatures verifyThemeAuthorship:self.accessPoint.currentDockThemeBundle];
        [[c signatureConfirmation] setStringValue:valid ? @"Dock theme signature is verified original. See fingerprint below."
                                                            : @"Dock theme signature cannot be verified."];
        
        [[self popover] showRelativeToRect:self.dockThemeSigningInfoButton.bounds
                                    ofView:self.dockThemeSigningInfoButton
                             preferredEdge:NSRectEdgeMinY];
        isPopoverShown = YES;
    }
    else{
        [[self popover] close];
        isPopoverShown = NO;
    }
}
@end
