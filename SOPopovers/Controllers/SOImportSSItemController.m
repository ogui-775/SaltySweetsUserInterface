//Created by Salty on 7/20/26.

#import "SOImportSSItemController.h"

@interface SOImportSSItemController ()
@property (strong) NSOpenPanel *openPanel;
@end

@implementation SOImportSSItemController
- (IBAction)closeWasPressed:(id)sender{
    [self.view.window close];
}

- (IBAction)openFilePickerWasPressed:(id)sender {
    self.openPanel = [[NSOpenPanel alloc] init];
    self.openPanel.allowedContentTypes = @[
        [UTType typeWithIdentifier:@"com.saltysoft.siconpack"],
        [UTType typeWithIdentifier:@"com.apple.bundle"]
    ];
    self.openPanel.allowsMultipleSelection = NO;

    NSWindow *targetWindow = NSApp.mainWindow ?: NSApp.keyWindow;

    [self.view.window close];

    [targetWindow makeKeyAndOrderFront:nil];

    [self.openPanel beginWithCompletionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            if (!self.openPanel.URL)
                return;
            
            if (![[self.openPanel.URL pathExtension] isEqualToString:@"siconpack"]
                    && ![[self.openPanel.URL pathExtension] isEqualToString:@"bundle"])
                return;
            
            NSFileManager *fm = [NSFileManager defaultManager];
            NSAlert *alert = [[NSAlert alloc] init];
            NSURL *itemURL = [self.openPanel URL];
            BOOL isIconPack = [[itemURL pathExtension] isEqualToString:@"siconpack"];
            
            if (isIconPack){
                NSURL *iconsDirURL = [NSURL fileURLWithPath:[SOAtomicAccessPoint sharedInstance].iconPackBundleDirectory
                                                isDirectory:YES];
                
                [fm copyItemAtURL:itemURL
                            toURL:[iconsDirURL URLByAppendingPathComponent:itemURL.lastPathComponent]
                            error:nil];
                
                alert.messageText = [NSString stringWithFormat:@"Set %@ as the current Icon Pack?",
                                     [itemURL.lastPathComponent stringByDeletingPathExtension]];
                alert.alertStyle = NSAlertStyleInformational;
                
                [alert addButtonWithTitle:@"OK"];
                [alert.buttons[0] setKeyEquivalent:@"\r"];
                [alert addButtonWithTitle:@"No"];
                
                NSModalResponse resp = [alert runModal];
                
                if (resp == NSAlertFirstButtonReturn){
                    [[SOAtomicAccessPoint sharedInstance] setCurrentIconPackBundleName:itemURL.lastPathComponent];
                    
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:SONotificationBaseClassUpdateBaseline
                                      object:self];
                    
                    for (id<SOConfigurableContent> page in [SOViewPane defaultInstance].childViewControllers) {

                        if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
                            [page refreshOrLoadBaseline];

                        if ([page respondsToSelector:@selector(purgePendingChanges)])
                            [page purgePendingChanges];
                        
                        [(id<SOConfigurableContentDelegate>)[SOViewPane defaultInstance] contentDidChangeState:page];
                    }
                }
            } else {
                NSURL *themeDirURL = [NSURL fileURLWithPath:[SOAtomicAccessPoint sharedInstance].dockThemeBundleDirectory
                                                isDirectory:YES];
                
                [fm copyItemAtURL:itemURL
                            toURL:[themeDirURL URLByAppendingPathComponent:itemURL.lastPathComponent]
                            error:nil];
                
                alert.messageText = [NSString stringWithFormat:@"Set %@ as the current Dock Theme?",
                                     [itemURL.lastPathComponent stringByDeletingPathExtension]];
                alert.alertStyle = NSAlertStyleInformational;
                
                [alert addButtonWithTitle:@"OK"];
                [alert.buttons[0] setKeyEquivalent:@"\r"];
                [alert addButtonWithTitle:@"No"];
                
                NSModalResponse resp = [alert runModal];
                
                if (resp == NSAlertFirstButtonReturn){
                    [[SOAtomicAccessPoint sharedInstance] setCurrentDockThemeBundleName:itemURL.lastPathComponent];
                    
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:SONotificationBaseClassUpdateBaseline
                                      object:self];
                    
                    for (id<SOConfigurableContent> page in [SOViewPane defaultInstance].childViewControllers) {

                        if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
                            [page refreshOrLoadBaseline];

                        if ([page respondsToSelector:@selector(purgePendingChanges)])
                            [page purgePendingChanges];
                        
                        [(id<SOConfigurableContentDelegate>)[SOViewPane defaultInstance] contentDidChangeState:page];
                    }
                }
            }
        }
    }];
}


@end

@implementation SOImportDestinationBox
- (void)awakeFromNib{
    [super awakeFromNib];
    [self registerForDraggedTypes:@[NSPasteboardTypeURL]];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([pboard availableTypeFromArray:@[NSPasteboardTypeFileURL]]) {
        NSURL *URL = [pboard readObjectsForClasses:@[[NSURL class]]
                                           options:nil].firstObject;
        
        if (!URL)
            return NSDragOperationNone;
        
        if (![[URL pathExtension] isEqualToString:@"siconpack"]
                && ![[URL pathExtension] isEqualToString:@"bundle"])
            return NSDragOperationNone;
        
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([pboard availableTypeFromArray:@[NSPasteboardTypeFileURL]]) {
        NSURL *URL = [pboard readObjectsForClasses:@[[NSURL class]]
                                           options:nil].firstObject;
        
        if (!URL)
            return NO;
        
        if (![[URL pathExtension] isEqualToString:@"siconpack"]
            && ![[URL pathExtension] isEqualToString:@"bundle"])
            return NO;
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSAlert *alert = [[NSAlert alloc] init];
        NSURL *itemURL = URL;
        BOOL isIconPack = [[itemURL pathExtension] isEqualToString:@"siconpack"];
        
        if (isIconPack){
            NSURL *iconsDirURL = [NSURL fileURLWithPath:[SOAtomicAccessPoint sharedInstance].iconPackBundleDirectory
                                            isDirectory:YES];
            
            [fm copyItemAtURL:itemURL
                        toURL:[iconsDirURL URLByAppendingPathComponent:itemURL.lastPathComponent]
                        error:nil];
            
            alert.messageText = [NSString stringWithFormat:@"Set %@ as the current Icon Pack?",
                                 [itemURL.lastPathComponent stringByDeletingPathExtension]];
            alert.alertStyle = NSAlertStyleInformational;
            
            [alert addButtonWithTitle:@"OK"];
            [alert.buttons[0] setKeyEquivalent:@"\r"];
            [alert addButtonWithTitle:@"No"];
            
            NSModalResponse resp = [alert runModal];
            
            if (resp == NSAlertFirstButtonReturn){
                [[SOAtomicAccessPoint sharedInstance] setCurrentIconPackBundleName:itemURL.lastPathComponent];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:SONotificationBaseClassUpdateBaseline
                 object:self];
                
                for (id<SOConfigurableContent> page in [SOViewPane defaultInstance].childViewControllers) {
                    
                    if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
                        [page refreshOrLoadBaseline];
                    
                    if ([page respondsToSelector:@selector(purgePendingChanges)])
                        [page purgePendingChanges];
                    
                    [(id<SOConfigurableContentDelegate>)[SOViewPane defaultInstance] contentDidChangeState:page];
                }
            }
            
            return YES;
        } else {
            NSURL *themeDirURL = [NSURL fileURLWithPath:[SOAtomicAccessPoint sharedInstance].dockThemeBundleDirectory
                                            isDirectory:YES];
            
            [fm copyItemAtURL:itemURL
                        toURL:[themeDirURL URLByAppendingPathComponent:itemURL.lastPathComponent]
                        error:nil];
            
            alert.messageText = [NSString stringWithFormat:@"Set %@ as the current Dock Theme?",
                                 [itemURL.lastPathComponent stringByDeletingPathExtension]];
            alert.alertStyle = NSAlertStyleInformational;
            
            [alert addButtonWithTitle:@"OK"];
            [alert.buttons[0] setKeyEquivalent:@"\r"];
            [alert addButtonWithTitle:@"No"];
            
            NSModalResponse resp = [alert runModal];
            
            if (resp == NSAlertFirstButtonReturn){
                [[SOAtomicAccessPoint sharedInstance] setCurrentDockThemeBundleName:itemURL.lastPathComponent];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:SONotificationBaseClassUpdateBaseline
                 object:self];
                
                for (id<SOConfigurableContent> page in [SOViewPane defaultInstance].childViewControllers) {
                    
                    if ([page respondsToSelector:@selector(refreshOrLoadBaseline)])
                        [page refreshOrLoadBaseline];
                    
                    if ([page respondsToSelector:@selector(purgePendingChanges)])
                        [page purgePendingChanges];
                    
                    [(id<SOConfigurableContentDelegate>)[SOViewPane defaultInstance] contentDidChangeState:page];
                }
            }
            
            return YES;
        }
    }
    
    return NO;
}
@end
