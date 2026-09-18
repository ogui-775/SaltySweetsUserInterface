//Created by Salty on 8/10/26.

#import "SOHealthCheckPageController.h"

@interface SOHealthCheckPageController ()
@property (strong) NSString *injectorName;
@property (strong) NSMutableArray<NSRunningApplication *> *runningApps;
@property (strong) NSArray<NSString *> *serverKeys;
@end

@implementation SOHealthCheckPageController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self refreshAllInformation:nil];
}

- (IBAction)refreshAllInformation:(NSButton *)sender{
    [self pulseCheckInjector];
    [self populateRunningApps];
    [self populateIconServerKeys];
}

- (void)populateIconServerKeys{
    NSXPCConnection *xpc = [[SOAtomicAccessPoint sharedInstance] appIconServerConnection];
    
    if (!xpc)
        return;
    
    id proxy = [xpc synchronousRemoteObjectProxyWithErrorHandler:^(NSError *error) {
    }];
    
    [proxy getSurfaceKeyListWithReply:^(NSArray<NSString *> *keys) {
       if (keys){
           self.serverKeys = [keys copy];
       }
    }];
    
    [self.iconServerIconKeyComboBox reloadData];
}

- (IBAction)checkServerImage:(NSComboBox *)sender{
    NSXPCConnection *xpc = [[SOAtomicAccessPoint sharedInstance] appIconServerConnection];
    
    if (!xpc)
        return;
    
    id proxy = [xpc synchronousRemoteObjectProxyWithErrorHandler:^(NSError *error) {
    }];
    
    SOIconIOSurfaceRequestToken *token = [SOIconIOSurfaceRequestToken tokenFromKey:sender.stringValue];
    
    [proxy getSurfaceRefForToken:token withReply:^(IOSurface *surface){
        if (!surface)
            return;
        
        CIImage *image = [CIImage imageWithIOSurface:(__bridge IOSurfaceRef)surface];
        NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:image];
        NSImage *nsImage = [[NSImage alloc] initWithSize:[rep size]];
        [nsImage addRepresentation:rep];
        self.iconServerIconImageView.image = nsImage;
    }];
}

- (IBAction)checkTweakInjected:(NSComboBox *)sender{
    NSRunningApplication *selectedApp = nil;
    for (NSRunningApplication *app in self.runningApps){
        if ([app.bundleIdentifier isEqualToString:sender.stringValue]){
            selectedApp = app;
            break;
        }
    }
    
    if (!selectedApp){
        self.runningProcessesImageView.image = [NSImage imageNamed:@"NSStatusUnavailable"];
        self.runningProcessesTextField.stringValue = @"Could not check injection status of process.";
        return;
    }
    
    BOOL dockReflectionsInjected = [self isLibraryInserted:@"libDockReflections.dylib" inProcess:selectedApp.processIdentifier];
    BOOL iconRefCaptureInjected  = [self isLibraryInserted:@"libIconRefCapture.dylib" inProcess:selectedApp.processIdentifier];
    
    if (dockReflectionsInjected && iconRefCaptureInjected){
        self.runningProcessesImageView.image = [NSImage imageNamed:@"NSStatusAvailable"];
        self.runningProcessesTextField.stringValue = @"Both libDockReflections and libIconRefCapture are injected to target.";
    } else if (dockReflectionsInjected && !iconRefCaptureInjected){
        self.runningProcessesImageView.image = [NSImage imageNamed:@"NSStatusPartiallyAvailable"];
        self.runningProcessesTextField.stringValue = @"Only libDockReflections is injected to target.";
    } else if (!dockReflectionsInjected && iconRefCaptureInjected){
        self.runningProcessesImageView.image = [NSImage imageNamed:@"NSStatusPartiallyAvailable"];
        self.runningProcessesTextField.stringValue = @"Only libIconRefCapture is injected to target.";
    } else if (!dockReflectionsInjected && !iconRefCaptureInjected){
        self.runningProcessesImageView.image = [NSImage imageNamed:@"NSStatusUnavailable"];
        self.runningProcessesTextField.stringValue = @"Neither tweaks are injected to target.";
    }
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox{
    if ([[comboBox identifier] isEqualToString:@"ram"]){
        return [self.serverKeys count];
    }
    
    if (self.runningApps)
        return [self.runningApps count];
    
    return 0;
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index{
    if ([[comboBox identifier] isEqualToString:@"ram"]){
        return [self.serverKeys objectAtIndex:index];
    }
    
    if (self.runningApps)
        return [self.runningApps objectAtIndex:index].bundleIdentifier ?: nil;
    
    return nil;
}

- (void)pulseCheckInjector{
    BOOL ammoniaIsRunning = [self isLaunchDaemonEnabled:@"com.bedtime.ammonia"];
    BOOL ppIsRunning      = [self isLaunchDaemonEnabled:@"com.pluginplayground.grant"];
    
    if (ammoniaIsRunning && !ppIsRunning)
        self.injectorName = @"Ammonia";
    else if (ppIsRunning && !ammoniaIsRunning)
        self.injectorName = @"Plugin Playground";
    else
        self.injectorName = @"Unknown";
    
    self.injectorStatusBox.title = [NSString stringWithFormat:@"Injector Status (%@)",
                                    self.injectorName];
    self.injectorStatusImageView.image = (ammoniaIsRunning || ppIsRunning) ? [NSImage imageNamed:@"NSStatusAvailable"] : [NSImage imageNamed:@"NSStatusUnavailable"];
    self.injectorStatusTextField.stringValue = ammoniaIsRunning ? @"Ammonia is running." : ppIsRunning ? @"Plugin Playground is running." : @"No injector was found to be running.";
}

- (BOOL)isLaunchDaemonEnabled:(NSString *)serviceName {
    NSTask *task = [[NSTask alloc] init];
    [task setExecutableURL:[NSURL fileURLWithPath:@"/bin/launchctl"]];
    
    NSString *serviceTarget = [NSString stringWithFormat:@"system/%@", serviceName];
    [task setArguments:@[@"print", serviceTarget]];
    
    [task setStandardOutput:[NSFileHandle fileHandleWithNullDevice]];
    [task setStandardError:[NSFileHandle fileHandleWithNullDevice]];
    
    NSError *error = nil;
    if (![task launchAndReturnError:&error]) {
        NSLog(@"Failed to launch launchctl: %@", error);
        return NO;
    }
    
    [task waitUntilExit];
    
    return ([task terminationStatus] == 0);
}

- (BOOL)isLibraryInserted:(NSString *)libraryName inProcess:(pid_t)pid {
    NSTask *task = [[NSTask alloc] init];
    [task setExecutableURL:[NSURL fileURLWithPath:@"/usr/sbin/lsof"]];
    
    NSString *pidString = [NSString stringWithFormat:@"%d", pid];
    [task setArguments:@[@"-p", pidString, @"-Fn"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:[NSFileHandle fileHandleWithNullDevice]];
    
    NSError *error = nil;
    if (![task launchAndReturnError:&error]) {
        return NO;
    }
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return [output containsString:libraryName];
}

- (void)populateRunningApps{
    if (!self.runningApps)
        self.runningApps = [NSMutableArray array];
    else
        [self.runningApps removeAllObjects];
    
    int numberOfPids = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    if (numberOfPids <= 0) {
        perror("Failed to fetch PID count");
        return;
    }

    pid_t *pids = malloc(numberOfPids * sizeof(pid_t));
    if (pids == NULL) {
        perror("Memory allocation failed");
        return;
    }

    int bufferSize = numberOfPids * sizeof(pid_t);
    int bytesReturned = proc_listpids(PROC_ALL_PIDS, 0, pids, bufferSize);
    int actualPidCount = bytesReturned / sizeof(pid_t);

    for (int i = 0; i < actualPidCount; i++) {
        if (pids[i] == 0) continue;

        NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:pids[i]];
        
        if (app && app.bundleIdentifier && ![app.bundleIdentifier isEqualToString:@""])
            [self.runningApps addObject:app];
    }

    free(pids);
}
@end
