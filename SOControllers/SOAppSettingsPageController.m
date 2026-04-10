//Created by Salty on 2/16/26.

#import "SOAppSettingsPageController.h"

@implementation SOAppSettingsPageController

static void callback(ConstFSEventStreamRef streamRef
                         , void *clientCallBackInfo
                         , size_t numEvents
                         , void *eventPaths
                         , const FSEventStreamEventFlags *eventFlags
                         , const FSEventStreamEventId *eventIds){
    id obj = (__bridge id)clientCallBackInfo;
    
    if ([obj respondsToSelector:@selector(refreshOrLoadBaseline)]) {
        [obj refreshOrLoadBaseline];
    }
};

static void releaseCallback(const void *info) {
    CFRelease(info);
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self refreshOrLoadBaseline];

    if (!self.keyDirMonitorStream) {

        FSEventStreamContext context = {0};
        context.info = (__bridge_retained void *)self;
        context.release = releaseCallback;

        NSArray * paths = @[[AppDelegate cryptoKeyDir]];

        self.keyDirMonitorStream =
            FSEventStreamCreate(kCFAllocatorDefault,
                                &callback,
                                &context,
                                (__bridge CFArrayRef)paths,
                                kFSEventStreamEventIdSinceNow,
                                1.0,
                                kFSEventStreamCreateFlagFileEvents);

        FSEventStreamSetDispatchQueue(self.keyDirMonitorStream, dispatch_get_main_queue());

        FSEventStreamStart(self.keyDirMonitorStream);
    }
}

- (void)refreshOrLoadBaseline{
    self.appAuthorNameField.stringValue = [AppDelegate appSetAuthorName];
    self.keyStatusImageView.image       = [SOSignatures authoringKeypairExists] ? [NSImage imageNamed:@"NSStatusAvailable"] :
                                                                                  [NSImage imageNamed:@"NSStatusUnavailable"];
    self.keyStatusTextLabel.stringValue = [SOSignatures authoringKeypairExists] ? @"Keys detected" : @"Keys not detected";
}

- (IBAction)openThemesDirectory:(id)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[AppDelegate bundleDir]]];
}

- (IBAction)openIconsDirectory:(id)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[AppDelegate iconsDir]]];
}

- (IBAction)authorNameWasSet:(NSButton *)sender{
    [AppDelegate setAppSetAuthorName:self.appAuthorNameField.stringValue];
}

- (IBAction)generateSigningKeys:(id)sender{
    [SOSignatures generateAndStoreAuthoringKeypair];
}

- (void)dealloc{
    if (self.keyDirMonitorStream) {
        FSEventStreamStop(self.keyDirMonitorStream);
        FSEventStreamInvalidate(self.keyDirMonitorStream);
        FSEventStreamRelease(self.keyDirMonitorStream);
        self.keyDirMonitorStream = NULL;
    }
}

@end
