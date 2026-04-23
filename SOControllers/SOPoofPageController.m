//Created by Salty on 2/9/26.

#import "SOPoofPageController.h"
#import "../SaltySweets/SOChangeCompiler.h"
#import "../SaltySweets/SOConfigurableContent.h"

@interface SOPoofPageController ()

// Cache images per scale index
@property (nonatomic, strong) NSMapTable * scale1Images;
@property (nonatomic, strong) NSMapTable * scale2Images;

@end

@implementation SOPoofPageController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self refreshOrLoadBaseline];
}

- (void)refreshOrLoadBaseline{
    self.poofEnabledRadio.state =
        [[self getBaselineForEncodedKey:&kSODockPoofAnimationEnabled] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.poofDisabledRadio.state = !self.poofEnabledRadio.state;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.scaleSelector selectItemAtIndex:0];

        self.scale1Images =
            [NSMapTable strongToStrongObjectsMapTable];
        self.scale2Images =
            [NSMapTable strongToStrongObjectsMapTable];
        
        self.scaleSelector.enabled = self.poofEnabledRadio.state;
        self.imageWell1.enabled =    self.poofEnabledRadio.state;
        self.imageWell2.enabled =    self.poofEnabledRadio.state;
        self.imageWell3.enabled =    self.poofEnabledRadio.state;
        self.imageWell4.enabled =    self.poofEnabledRadio.state;
        self.imageWell5.enabled =    self.poofEnabledRadio.state;
    });
    
    if (![[self getBaselineForEncodedKey:&kSODockPoofSoundAsset] isEqualToString:kSODockResourceNotProvided]){
        self.filePickerOpen.image =
            [NSImage imageWithSystemSymbolName:@"xmark"
                      accessibilityDescription:nil];
        self.filePathDisplay.stringValue = [[self getBaselineForEncodedKey:&kSODockPoofSoundAsset] stringValue];
        self.playButton.enabled = YES;
        self.playButton.sound = [[NSSound alloc] initWithContentsOfFile:[[AppDelegate currentDockThemeBundle]
                                                                         pathForResource:@"poof_sound.aiff"
                                                                         ofType:nil
                                                                         inDirectory:kSODockPoofSoundAsset.key]
                                                                         byReference:NO];
    }

    self.scaleSelector.enabled =
        self.poofEnabledRadio.state == NSControlStateValueOn &&
        [[self getBaselineForEncodedKey:&kSODockUsesRetinaResourcesWhereRequested] boolValue];
    
    for (NSImageView * well in @[self.imageWell1, self.imageWell2, self.imageWell3, self.imageWell4, self.imageWell5]){
        for (NSString *     scaleKey in @[@"1x", @"2x"]){
            NSMapTable *    relevantMap = [scaleKey isEqualToString:@"1x"] ? self.scale1Images : self.scale2Images;
            NSString *      frameKey = [NSString stringWithFormat:@"frame%ld", well.tag];
            SOEncodedKeyPath pathKey = {
                .rootKey = &kSODockPoofAnimationAssets,
                .components = @[ scaleKey, frameKey ]
            };
            
            [relevantMap setObject:[self loadImageForEncodedKeypath:&pathKey] forKey:well];
        }
        
        NSMapTable * relevantMap = self.scaleSelector.indexOfSelectedItem + 1 == 1 ? self.scale1Images : self.scale2Images;
        if ([relevantMap objectForKey:well])
            [well setImage:[relevantMap objectForKey:well]];
    }
}

#pragma mark - Settings Box

- (IBAction)setPoofEnabled:(NSButton *)sender {
    BOOL enabled = self.poofEnabledRadio.state == NSControlStateValueOn;
    
    // Toggle UI elements
    if ([[self getBaselineForEncodedKey:&kSODockUsesRetinaResourcesWhereRequested] boolValue])
        self.scaleSelector.enabled = enabled;
    
    self.imageWell1.enabled = enabled;
    self.imageWell2.enabled = enabled;
    self.imageWell3.enabled = enabled;
    self.imageWell4.enabled = enabled;
    self.imageWell5.enabled = enabled;
    
    // Track change
    [self setPendingBoolChangeForKey:&kSODockPoofAnimationEnabled
                             enabled:enabled
                                note:[NSString stringWithFormat:@"Toggle poof animation to %@", enabled ? @"on" : @"off"]];
}

- (IBAction)openFilePicker:(NSButton *)sender {
    BOOL hasPendingSound =
    ([self.pendingChangeArray indexOfObjectPassingTest:^BOOL(SOChange * obj, NSUInteger idx, BOOL * stop){
        return [obj.plistKey->key isEqualToString:kSODockPoofSoundAsset.key];
    }] != NSNotFound);

    if (hasPendingSound ||
        ![[[self getBaselineForEncodedKey:&kSODockPoofSoundAsset] stringValue] isEqualToString:kSODockResourceNotProvided]) {
        // Remove pending change
        [self setPendingResourceChangeForKey:&kSODockPoofSoundAsset
                                    resource:nil
                                        type:kSOChangeResourceTypeAIFF
                                    filename:@"poof_sound.aiff"
                                        note:@"Cleared custom poof sound"];
        
        self.playButton.enabled = NO;
        self.playButton.sound = nil;

        // Restore baseline UI
        self.filePathDisplay.stringValue = kSODockPoofSoundAsset.defaultValue ?: @"";

        // Restore button image
        self.filePickerOpen.image =
            [NSImage imageWithSystemSymbolName:@"folder"
                      accessibilityDescription:nil];

        return;
    }

    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowedContentTypes = @[UTTypeAIFF];
    panel.allowsMultipleSelection = NO;

    [panel beginSheetModalForWindow:self.view.window
                  completionHandler:^(NSModalResponse result) {

        if (result != NSModalResponseOK)
            return;

        NSURL * fileURL = panel.URL;
        NSData * fileData = [NSData dataWithContentsOfURL:fileURL];
        if (!fileData)
            return;

        self.filePathDisplay.stringValue = fileURL.path;

        [self setPendingResourceChangeForKey:&kSODockPoofSoundAsset
                                    resource:fileData
                                        type:kSOChangeResourceTypeAIFF
                                    filename:@"poof_sound.aiff"
                                        note:@"Set custom poof sound"];
        
        // Switch button to "clear"
        self.filePickerOpen.image =
            [NSImage imageWithSystemSymbolName:@"xmark"
                      accessibilityDescription:nil];
    }];
}


#pragma mark - Custom Poof Images

- (IBAction)addImageToBlock:(NSImageView *)sender {
    long currentSetScale = [self.scaleSelector indexOfSelectedItem] + 1;
    NSMapTable * relevantMap = currentSetScale == 1 ? self.scale1Images : self.scale2Images;
    
    NSString * scaleKey = currentSetScale == 1 ? @"1x" : @"2x";
    NSString * frameKey = [NSString stringWithFormat:@"frame%ld", sender.tag];
    SOEncodedKeyPath pathKey = {
        .rootKey = &kSODockPoofAnimationAssets,
        .components = @[ scaleKey, frameKey ]
    };
    
    if (sender.image){
        [relevantMap setObject:sender.image forKey:sender];
    }
    else{
        if ([relevantMap objectForKey:sender])
            [relevantMap removeObjectForKey:sender];
        
        [self setPendingResourceChangeForKeypath:&pathKey
                                        resource:nil
                                            type:kSOChangeResourceTypeNSImage
                                        filename:[frameKey stringByAppendingString:@".png"]
                                            note:[NSString stringWithFormat:@"Cleared %@ for scale %lu", frameKey, currentSetScale]
                                    contentScale:currentSetScale];

        sender.image = [NSImage imageWithSystemSymbolName:[NSString stringWithFormat:@"%li.circle", (long)sender.tag]
                                 accessibilityDescription:nil];
        return;
    }
    
    [self setPendingResourceChangeForKeypath:&pathKey
                                    resource:sender.image
                                        type:kSOChangeResourceTypeNSImage
                                    filename:[frameKey stringByAppendingString:@".png"]
                                        note:[NSString stringWithFormat:@"Set %@ for scale %lu", frameKey, currentSetScale]
                                contentScale:currentSetScale];
}

- (IBAction)setContentsScaleForBlocks:(NSComboBox *)sender{
    long currentSetScale = [self.scaleSelector indexOfSelectedItem] + 1;
    NSMapTable * relevantMap = currentSetScale == 1 ? self.scale1Images : self.scale2Images;
    for (NSImageView * well in @[self.imageWell1, self.imageWell2, self.imageWell3, self.imageWell4, self.imageWell5]){
        if ([relevantMap objectForKey:well])
            [well setImage:[relevantMap objectForKey:well]];
        else
            [well setImage:[NSImage imageWithSystemSymbolName:[NSString stringWithFormat:@"%li.circle", (long)well.tag] accessibilityDescription:nil]];
    }
}

@end
