//Created by Salty on 2/6/26.

#import "Base/SOPageControllerBase.h"
#import "Base/SOConfigurablePageControllerBase.h"
#import "../SaltySweets/SOConfigurableContent.h"
#import <SharedKeys/SOSharedKeys.h>

@interface SOPoofPageController : SOConfigurablePageControllerBase
//Settings box
- (IBAction)setPoofEnabled:(id)sender;
- (IBAction)openFilePicker:(id)sender;
@property (nonatomic, strong) IBOutlet NSButton * poofEnabledRadio;
@property (nonatomic, strong) IBOutlet NSButton * poofDisabledRadio;

@property (nonatomic, strong) IBOutlet NSButton * filePickerOpen;
@property (nonatomic, strong) IBOutlet NSTextField * filePathDisplay;
@property (nonatomic, strong) IBOutlet NSButton * playButton;

//Custom assets box
- (IBAction)addImageToBlock:(id)sender;
- (IBAction)setContentsScaleForBlocks:(id)sender;
@property (nonatomic, strong) IBOutlet NSComboBox * scaleSelector;
@property (nonatomic, strong) IBOutlet NSImageView * imageWell1;
@property (nonatomic, strong) IBOutlet NSImageView * imageWell2;
@property (nonatomic, strong) IBOutlet NSImageView * imageWell3;
@property (nonatomic, strong) IBOutlet NSImageView * imageWell4;
@property (nonatomic, strong) IBOutlet NSImageView * imageWell5;

@end
