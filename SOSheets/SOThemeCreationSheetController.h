//Created by Salty on 2/21/26.

#import <AppKit/AppKit.h>

@interface SOThemeCreationSheetController : NSWindowController <NSControlTextEditingDelegate>
@property (strong, nonatomic) IBOutlet NSTextField * nameBox;
@property (strong, nonatomic) IBOutlet NSButton * createButton;
@end

@interface SOThemeCreationSheet : NSWindow @end
