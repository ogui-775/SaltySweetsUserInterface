//Created by Salty on 2/21/26.

#import <AppKit/AppKit.h>

@interface SOThemeCreationSheetController : NSWindowController <NSControlTextEditingDelegate>
- (instancetype)initWithCreationType:(NSString *)type;
@property (strong, nonatomic) IBOutlet NSTextField * nameBox;
@property (strong, nonatomic) IBOutlet NSButton * createButton;
@property (strong, nonatomic) IBOutlet NSTextField * typeBox;
@property (strong) NSString * type;
@end

@interface SOThemeCreationSheet : NSWindow @end
