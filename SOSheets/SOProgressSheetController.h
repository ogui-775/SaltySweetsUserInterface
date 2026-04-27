//Created by Salty on 4/26/26.

#import <AppKit/AppKit.h>
#import "../SOControllers/Base/SOMarqueeTextField.h"

@interface SOProgressSheetController : NSWindowController
@property (strong) IBOutlet NSProgressIndicator *progressBar;
@property (strong) IBOutlet SOMarqueeTextField *progressLabel;
@property (strong) IBOutlet NSImageView *previewImage;
@end

@interface SOProgressSheet : NSWindow @end
