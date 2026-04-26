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
        self.loadedSiconDataDict = [self defaultTableValues];
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

    [self.fileDetailTable reloadData];
    
    [self updateWells];
}

- (NSMutableDictionary *)defaultTableValues{
    NSArray *keys = [self tableSetKeys];
    return [NSMutableDictionary dictionaryWithDictionary:@{
        keys[0] : @"SICO",
        keys[1] : @1,
        keys[2] : @0,
        keys[3] : @(sizeof(SOSiconHeader)),
        keys[4] : @(sizeof(SOSiconHeader) + (sizeof(SOSiconDescriptor) * [[self.loadedSiconDataDict objectForKey:@"Image Count"] intValue])),
        keys[5] : @0,
        keys[6] : @"NO",
        keys[7] : @"NO"
    }];
}

- (NSArray *)tableSetKeys{
    return @[
        @"Magic",
        @"Version",
        @"Image Count",
        @"Descriptor Offset",
        @"Data Offset",
        @"File Size",
        @"Has Selected Variant",
        @"Has Dark Variant"
    ];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.loadedSiconDataDict.count;
}

- (NSView *)tableView:(NSTableView *)tableView
    viewForTableColumn:(NSTableColumn *)tableColumn
                   row:(NSInteger)row
{
    NSTextField *cell =
        [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if (!cell)
        cell = [[NSTextField alloc] initWithFrame:tableView.bounds];
    
    cell.editable = NO;
    cell.drawsBackground = NO;
    cell.bordered = NO;

    NSString *key = [self tableSetKeys][row];

    if ([tableColumn.identifier isEqualToString:@"c0"]) {
        cell.stringValue = key;
    } else if ([tableColumn.identifier isEqualToString:@"c1"]) {
        id value = self.loadedSiconDataDict[key];
        cell.stringValue = [value description];
    }

    cell.font = [NSFont fontWithName:@"Helvetica" size:10];
    
    return cell;
}

- (CGSize)getSizeForSelectedSegment{
    long    scale = self.scaleSelector.selectedSegment + 1;
    CGSize   size = CGSizeZero;
    switch(self.sizeSelector.selectedSegment){
        case 0:
            size = CGSizeMake(16 * scale, 16 * scale);
            break;
        case 1:
            size = CGSizeMake(32 * scale, 32 * scale);
            break;
        case 2:
            size = CGSizeMake(128 * scale, 128 * scale);
            break;
        case 3:
            size = CGSizeMake(256 * scale, 256 * scale);
            break;
        case 4:
            size = CGSizeMake(512 * scale, 512 * scale);
            break;
        default:
            size = CGSizeMake(512 * scale, 512 * scale);
            break;
    };
    
    return size;
}

#pragma mark - Operational Section

- (IBAction)newSiconWasClicked:(NSMenuItem *)sender{
    self.context = [SONSWindowAuxContextSiconCreation siconCreationContext];
    self.nameField.stringValue = @"";
    self.loadedSiconDataDict = [self defaultTableValues];
    self.darkVariantFilesize.stringValue = @"";
    self.lightFilesize.stringValue = @"";
    self.selectedVariantFilesize.stringValue = @"";
    [self.keyToCreationHolder removeAllObjects];
    [self.fileDetailTable reloadData];
}

- (IBAction)openSiconWasClicked:(NSMenuItem *)sender{
    
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
    
    if (well.image)
        [self.keyToCreationHolder setObject:holder forKey:key];
    else if (!well.image && [self.keyToCreationHolder objectForKey:key])
        [self.keyToCreationHolder removeObjectForKey:key];
    
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
        
        label.stringValue = [NSString stringWithFormat:@"Size: %ix%i - %@",
                             (int)well.image.size.width,
                             (int)well.image.size.height,
                             [formatter stringFromByteCount:(value != nil ? (long)value.unsignedLongValue : 0)]];
        
        [SOCreationHolder setDictionaryToLatest:self.loadedSiconDataDict fromCreationHolder:self.keyToCreationHolder];
        [self.fileDetailTable reloadData];
    }
}

- (IBAction)compileWasClicked:(NSButton *)sender{
    NSString *filename = [[self.nameField.stringValue stringByDeletingPathExtension] stringByAppendingString:@".sicon"];
    
    if (!filename || [filename isEqualToString:@".sicon"]){
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"You must set a name for the new icon before compiling.";
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            return;
        }];
    }
    
    BOOL compressToJXL = self.applyJXLSwitch.state == NSControlStateValueOn;
    
    NSMutableArray<SOSiconEntry *> *entryArray = [NSMutableArray array];
    
    for (SOCreationHolder *holder in self.keyToCreationHolder.allValues){
        BOOL eligibleForJXL = ![[[holder.originalFileURL lastPathComponent] pathExtension] isEqualToString:@"jxl"];
        
        NSData *data = nil;
        SOSiconEntry *entry = [SOSiconEntry new];
        SOSiconDef   *def   = [SOSiconDef new];
        
        if (eligibleForJXL && compressToJXL){
            NSData *imageData = [NSData dataWithContentsOfURL:holder.originalFileURL];
            
            if (!imageData)
                continue;
            
            data = [SOJXLEncoder encodeImageDataToJXL:imageData error:nil];
            def.isJXL = YES;
        } else {
            data = [NSData dataWithContentsOfURL:holder.originalFileURL];
        }
        
        if (!data)
            continue;
        
        def.size = holder.displayImage.size;
        def.filename = holder.originalFileURL.lastPathComponent;
        NSArray *components = [holder.key componentsSeparatedByString:@"|"];
        def.isRetina = [components[1] isEqualToString:@"1"] ? NO : YES;
        def.variantKey = [components[0] isEqualToString:@"0"] ? &kSOSiconLight : [components[0] isEqualToString:@"1"] ? &kSOSiconDark : &kSOSiconSelected;
        
        entry.def = def;
        entry.imageData = data;
        
        [entryArray addObject:entry];
    }
    
    NSURL *newURL = [NSURL fileURLWithPath:[[AppDelegate iconsDir] stringByAppendingPathComponent:filename]];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm copyItemAtURL:[[NSBundle mainBundle] URLForResource:@"Template" withExtension:@"sicon"]
                toURL:newURL
                error:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SOSiconBundle *newIcon = [SOSiconBundle bundleWithURL:newURL];
        [newIcon writeBlobArrayToDisk:entryArray];
    });
}
@end
