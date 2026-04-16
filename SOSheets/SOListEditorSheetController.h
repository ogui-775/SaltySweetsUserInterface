//Created by Salty on 4/16/26.

#import <AppKit/AppKit.h>

@interface SOListEditorSheetController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>
@property (strong, nonatomic) IBOutlet NSTextField * editorNameLabel;
@property (strong, nonatomic) NSMutableArray<NSString *> * listContents;
@property (strong, nonatomic) IBOutlet NSTableView * listTableView;
@property (strong, nonatomic) NSString * windowName;
@property (weak) NSWindow * sheetParent;

- (instancetype) initWithListContents:(NSMutableArray<NSString *> *)listContents name:(NSString *)name;

- (IBAction)plusWasPressed:(NSButton *)sender;
- (IBAction)minusWasPressed:(NSButton *)sender;
@end

@interface SOListEditorSheet : NSWindow @end
