//Created by Salty on 2/16/26.

#import "Base/SOConfigurablePageControllerBase.h"

#import "../SaltySweets/Services/SOSignatures.h"

@interface SOAppSettingsPageController : SOConfigurablePageControllerBase
@property (strong, nonatomic) IBOutlet NSButton * openFinderToThemesButton;
@property (strong, nonatomic) IBOutlet NSTextField * appAuthorNameField;
@property (strong, nonatomic) IBOutlet NSImageView * keyStatusImageView;
@property (strong, nonatomic) IBOutlet NSTextField * keyStatusTextLabel;

@property (nonatomic) FSEventStreamRef keyDirMonitorStream;
@end
