//Created by Salty on 7/23/26.

#import "../Base/SOConfigurablePageControllerBase.h"
#import <SharedClasses/SharedClasses.h>

@interface SOCalendarPositioningView : NSView

@end

@interface SOCalendarDockTileReplacementPageController : SOConfigurablePageControllerBase <NSComboBoxDataSource>
@property (weak, nonatomic) IBOutlet SOCalendarPositioningView *compositionView;
@property (weak, nonatomic) IBOutlet SODragAwareImageView *baseImageWell;

@property (strong, nonatomic) IBOutlet NSColorWell *dayColorPanel;

@property (strong, nonatomic) IBOutlet NSColorWell *monthColorPanel;

@property (weak, nonatomic) IBOutlet NSTextField *fontNameTextField;
@property (weak, nonatomic) IBOutlet NSComboBox *dayFontSizeComboBox;
@property (weak, nonatomic) IBOutlet NSComboBox *monthFontSizeComboBox;
@property (weak, nonatomic) IBOutlet NSButton *dayBoldCheckbox;
@property (weak, nonatomic) IBOutlet NSButton *monthBoldCheckbox;
@end
