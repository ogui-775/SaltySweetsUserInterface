//Created by Salty on 4/23/26.

#import "SONSWindowAuxSiconCreationController.h"

typedef enum : NSUInteger {
    Light,
    Dark,
    Selected,
} WellType;

@interface SOCreationHolder : NSObject
+ (NSString *)keyForWellType:(WellType)wellType scale:(unsigned int)scale size:(CGSize)size;
+ (void)setDictionaryToLatest:(NSMutableDictionary *)dict fromCreationHolder:(NSMutableDictionary *)holder;
@property (strong) NSString *key;
@property (strong) NSImage  *displayImage;
@property (strong) NSURL    *originalFileURL;
@property (strong) NSData   *icnsData;
@end

@implementation SOCreationHolder
+ (NSString *)keyForWellType:(WellType)wellType scale:(unsigned int)scale size:(CGSize)size{
    return [NSString stringWithFormat:@"%lu|%i|%fx%f",
            (unsigned long)wellType,
            scale,
            size.width,
            size.height];
}

+ (void)setDictionaryToLatest:(NSMutableDictionary *)dict fromCreationHolder:(NSMutableDictionary *)holder{
    if ([dict objectForKey:@"Image Count"])
        [dict setObject:@(holder.count) forKey:@"Image Count"];
    if ([dict objectForKey:@"Data Offset"])
        [dict setObject:@(sizeof(SOSiconHeader) + (sizeof(SOSiconDescriptor) * [[dict objectForKey:@"Image Count"] intValue])) forKey:@"Data Offset"];
}
@end

@implementation SONSWindowAuxSiconCreationController
#pragma mark - View Setup Section

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(SONSWindowAuxContextSiconCreation *)ctx{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.context = ctx;
        self.keyToCreationHolder = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)event{
    [self.view.window makeFirstResponder:nil];
}

- (void)viewDidAppear{
    [self.view.window makeFirstResponder:nil];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    for (NSTextField *f in @[self.darkVariantFilesize, self.lightFilesize, self.selectedVariantFilesize]){
        f.font = [NSFont fontWithName:@"Helvetica" size:10];
    }
    
    [self updateWells];
}

- (CGSize)getSizeForSelectedSegment{
    CGSize   size = CGSizeZero;
    switch(self.sizeSelector.selectedSegment){
        case 0:
            size = CGSizeMake(16, 16);
            break;
        case 1:
            size = CGSizeMake(32, 32);
            break;
        case 2:
            size = CGSizeMake(128, 128);
            break;
        case 3:
            size = CGSizeMake(256, 256);
            break;
        case 4:
            size = CGSizeMake(512, 512);
            break;
        default:
            size = CGSizeMake(512, 512);
            break;
    };
    
    return size;
}

#pragma mark - Operational Section

- (IBAction)newSiconWasClicked:(NSMenuItem *)sender{
    self.context = [SONSWindowAuxContextSiconCreation siconCreationContext];
    self.nameField.stringValue = @"";
    self.darkVariantFilesize.stringValue = @"";
    self.lightFilesize.stringValue = @"";
    self.selectedVariantFilesize.stringValue = @"";
    [self.keyToCreationHolder removeAllObjects];
    for (NSImageView *well in @[self.lightWell, self.darkVariantWell, self.selectedVariantWell])
        well.image = nil;
}

- (IBAction)convertFromICNS:(NSButton *)sender{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles = YES;
    openPanel.allowedContentTypes = @[[UTType typeWithFilenameExtension:@"icns"]];
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK)
            return;
        
        NSURL *url = openPanel.URLs.firstObject;
        
        if (!url)
            return;
        
        ISIcns *icns = [NSClassFromString(@"ISIcns") icnsWithContentsOfURL:url];
        
        if (!icns)
            return;
        
        [self processICNS:icns];
        
        NSArray<ISIcns *> *variants = [icns variants];
        
        for (ISIcns *item in variants)
            [self processICNS:item];
    }];
}

- (void)processICNS:(ISIcns *)icns{
    NSString *name = [icns name];

    [icns enumerateElementsUsingBlock:^(NSUInteger index, OSType type, NSData *data, BOOL *stop) {
        WellType wtype = [name isEqualToString:@"dark"] ? Dark : [name isEqualToString:@"selected"] ? Selected : Light;
        CGSize    size = [icns sizeAtIndex:index];
        long     scale = [icns scaleAtIndex:index];
        NSString  *key = [SOCreationHolder keyForWellType:wtype
                                                    scale:(uint)scale
                                                     size:size];
        
        SOCreationHolder *holder = [SOCreationHolder new];
        holder.key = key;
        holder.displayImage = [[NSImage alloc] initWithData:data];
        holder.icnsData = data;
        
        if (!holder.displayImage){
            CGImageRef img = [icns copyCGImageWithIndex:index];
            
            if (img){
                holder.displayImage = [[NSImage alloc] initWithCGImage:img size:size];
                
                if (holder.displayImage.TIFFRepresentation)
                    holder.icnsData = holder.displayImage.TIFFRepresentation;
                
                CGImageRelease(img);
            }
        }
        
        [self willChangeValueForKey:@"keyToCreationHolder"];
        [self.keyToCreationHolder setObject:holder forKey:key];
        [self didChangeValueForKey:@"keyToCreationHolder"];
    }];
    
    [self updateWells];
}

- (IBAction)wellWasInteractedWith:(SODragAwareImageView *)well{
    WellType type = [well.identifier isEqualToString:@"dark"] ? Dark : [well.identifier isEqualToString:@"selected"] ? Selected : Light;
    CGSize   size = [self getSizeForSelectedSegment];
    long    scale = self.scaleSelector.selectedSegment + 1;
    NSString *key = [SOCreationHolder keyForWellType:type scale:(uint)scale size:size];
    
    SOCreationHolder *holder = [[SOCreationHolder alloc] init];
    holder.key = key;
    holder.displayImage = well.image;
    holder.originalFileURL = well.draggedFileURL;
    
    if (well.image){
        [self willChangeValueForKey:@"keyToCreationHolder"];
        [self.keyToCreationHolder setObject:holder forKey:key];
        [self didChangeValueForKey:@"keyToCreationHolder"];
    }
    else if (!well.image && [self.keyToCreationHolder objectForKey:key]){
        [self willChangeValueForKey:@"keyToCreationHolder"];
        [self.keyToCreationHolder removeObjectForKey:key];
        [self didChangeValueForKey:@"keyToCreationHolder"];
    }
    
    [self updateWells];
}

- (IBAction)scaleOrSizeWasChanged:(NSSegmentedControl *)sender{
    [self updateWells];
}

- (void)updateWells{
    static NSByteCountFormatter *formatter = nil;
    
    if (!formatter)
        formatter = [NSByteCountFormatter new];
    
    for (SODragAwareImageView *well in @[self.lightWell, self.darkVariantWell, self.selectedVariantWell]){
        WellType type = [well.identifier isEqualToString:@"dark"] ? Dark : [well.identifier isEqualToString:@"selected"] ? Selected : Light;
        CGSize   size = [self getSizeForSelectedSegment];
        long    scale = self.scaleSelector.selectedSegment + 1;
        NSString *key = [SOCreationHolder keyForWellType:type scale:(uint)scale size:size];
        
        SOCreationHolder *holder = [self.keyToCreationHolder objectForKey:key];
        well.image = holder.displayImage;
        well.draggedFileURL = holder.originalFileURL;
        
        NSTextField *label = [well.identifier isEqualToString:@"dark"] ? self.darkVariantFilesize : [well.identifier isEqualToString:@"selected"]
            ? self.selectedVariantFilesize : self.lightFilesize;
        
        NSNumber *value = nil;
        [well.draggedFileURL getResourceValue:&value
                                       forKey:NSURLFileSizeKey
                                        error:nil];
        
        if (!value && holder.icnsData)
            value = [NSNumber numberWithUnsignedInteger:holder.icnsData.length];
        
        label.stringValue = [NSString stringWithFormat:@"Size: %ix%i - %@",
                             (int)well.image.size.width,
                             (int)well.image.size.height,
                             [formatter stringFromByteCount:(value != nil ? (long)value.unsignedLongValue : 0)]];
        
        [SOCreationHolder setDictionaryToLatest:self.loadedSiconDataDict
                             fromCreationHolder:self.keyToCreationHolder];
    }
}

- (IBAction)compileWasClicked:(NSButton *)sender{
    NSString *filename = [[self.nameField.stringValue stringByDeletingPathExtension] stringByAppendingString:@".sicon"];
    
    if (!filename || [filename isEqualToString:@".sicon"]){
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"You must set a name for the new icon before compiling.";
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        }];
        return;
    }
    
    BOOL compressToJXL = self.applyJXLSwitch.state == NSControlStateValueOn;

    NSMutableArray<SOSiconEntry *> *entryArray = [NSMutableArray array];
    
    NSOperationQueue *opQueue =
        [[NSOperationQueue alloc] init];
    opQueue.maxConcurrentOperationCount = 2;
    
    SOProgressSheetController *progress =
        [[SOProgressSheetController alloc] initWithWindowNibName:@"SOProgressSheet"];
    [self.view.window beginSheet:progress.window
               completionHandler:nil];
    
    [opQueue addOperationWithBlock:^{
        opQueue.progress.totalUnitCount = self.keyToCreationHolder.allValues.count;
        for (SOCreationHolder *holder in self.keyToCreationHolder.allValues){
            BOOL eligibleForJXL = ![[[holder.originalFileURL lastPathComponent] pathExtension] isEqualToString:@"jxl"];
            
            opQueue.progress.fileURL = holder.originalFileURL;
            dispatch_async(dispatch_get_main_queue(),
                   ^{
                progress.progressBar.maxValue = opQueue.progress.totalUnitCount;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [progress.progressLabel setFrame:progress.progressLabel.frame];
                });
                [progress.progressLabel  animateFieldToShow:[NSString stringWithFormat:@"Writing %@...",
                                                             holder.originalFileURL.lastPathComponent ?: [NSString stringWithFormat:@"%lu", [holder.icnsData hash]]]];
            });
            
            NSData *data = nil;
            SOSiconEntry *entry = [SOSiconEntry new];
            SOSiconDef   *def   = [SOSiconDef new];
            
            if (eligibleForJXL && compressToJXL){
                NSData *imageData = [NSData dataWithContentsOfURL:holder.originalFileURL] ?: holder.icnsData;
                
                if (!imageData)
                    continue;
                
                data = [SOJXLEncoder encodeImageDataToJXL:imageData error:nil];
                def.isJXL = YES;
            } else {
                data = [NSData dataWithContentsOfURL:holder.originalFileURL] ?: holder.icnsData;
            }
            
            if (!data)
                continue;
            
            def.size = holder.displayImage.size;
            def.filename = holder.originalFileURL.lastPathComponent ?: [NSString stringWithFormat:@"%lu", [holder.icnsData hash]];
            NSArray *components = [holder.key componentsSeparatedByString:@"|"];
            def.isRetina = [components[1] isEqualToString:@"1"] ? NO : YES;
            def.variantKey = [components[0] isEqualToString:@"0"] ? &kSOSiconLight : [components[0] isEqualToString:@"1"] ? &kSOSiconDark : &kSOSiconSelected;
            
            entry.def = def;
            entry.imageData = data;
            
            [entryArray addObject:entry];
            
            opQueue.progress.completedUnitCount++;
            dispatch_async(dispatch_get_main_queue(), ^{
                progress.progressBar.doubleValue += 1;
                progress.previewImage.image = [[NSImage alloc] initWithData:data];
            });
        }
    }];
    
    [opQueue addBarrierBlock:^{
        NSURL *newURL = [NSURL fileURLWithPath:[[[SOAtomicAccessPoint sharedInstance] iconPackBundleDirectory] stringByAppendingPathComponent:filename]];
        
        SOSicon *newIcon = [[SOSicon alloc] init];
        [newIcon writeBlobArrayToDisk:entryArray atURL:newURL];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.view.window endSheet:progress.window];
        });
    }];
}

- (IBAction)clearWells:(NSButton *)sender{
    if (self.keyToCreationHolder)
        [self.keyToCreationHolder removeAllObjects];
    
    [self updateWells];
}
@end
