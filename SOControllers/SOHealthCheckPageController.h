//Created by Salty on 8/10/26.

#import "Base/SOPageControllerBase.h"
#import <libproc.h>

@interface SOHealthCheckPageController : SOPageControllerBase <NSComboBoxDataSource>
@property (weak, nonatomic) IBOutlet NSBox *injectorStatusBox;
@property (weak, nonatomic) IBOutlet NSImageView *injectorStatusImageView;
@property (weak, nonatomic) IBOutlet NSTextField *injectorStatusTextField;

@property (weak, nonatomic) IBOutlet NSComboBox *runningProcessesComboBox;
@property (weak, nonatomic) IBOutlet NSImageView *runningProcessesImageView;
@property (weak, nonatomic) IBOutlet NSTextField *runningProcessesTextField;
@end
