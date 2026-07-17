//Created by Salty on 2/8/26.

#import "SOChangeCompiler.h"

@implementation SOChangeCompiler
/*
- (void)ensureBundlesWithShortCircuit:(SOShortCircuit)shortCir withCompletion:(void (^)(SODockThemeBundle *, SOSiconPackBundle *, BOOL aborted))completion
{
    NSWindow *parentWindow = NSApp.mainWindow;
    
    SODockThemeBundle *dock = [AppDelegate currentDockThemeBundle];
    SOSiconPackBundle *icon = [AppDelegate currentIconThemeBundle];
    
        self.dockThemeCreateSheet = [[SOThemeCreationSheetController alloc] initWithCreationType:@"Dock Theme"];

        [parentWindow beginSheet:self.dockThemeCreateSheet.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode != NSModalResponseOK) {
                completion(nil, nil, YES);
                return;
            }

            NSFileManager *fm = [NSFileManager defaultManager];
            NSString * newName = [self.dockThemeCreateSheet.nameBox.stringValue stringByAppendingString:@".bundle"];
            [AppDelegate setCurrentThemeBundleName:newName];

            NSError * error = nil;
            
            NSURL * newThemeURL =
                [NSURL fileURLWithPath:[[AppDelegate bundleDir] stringByAppendingPathComponent:newName]];

            [fm copyItemAtURL:
             [[NSBundle mainBundle] URLForResource:@"Template.bundle" withExtension:@""]
                        toURL:newThemeURL
                        error:&error];

            if (error) {
                NSLog(@"Bundle copy error: %@", error);
            }

            [[NSWorkspace sharedWorkspace]
                setIcon:[NSImage imageNamed:@"CompiledThemeIcon"]
                forFile:newThemeURL.path
                options:0];
            
            
                SOChange * authorWrite = [[SOChange alloc] init];
                authorWrite.plistKey = &kSODockThemePlainAuthorName;
                authorWrite.plistValue = [AppDelegate appSetAuthorName];
                authorWrite.changeType = kSOChangeTypePlist;

        return;
    }
 */
@end
