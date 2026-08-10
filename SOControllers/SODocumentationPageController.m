#import "SODocumentationPageController.h"

@implementation SODocumentationPageController

- (void)awakeFromNib{
    [super awakeFromNib];

    [self displayReadme];
}

- (void)displayReadme{
    NSURL *url =
        [[[NSBundle mainBundle] resourceURL]
            URLByAppendingPathComponent:@"Readme.html"];

    [self.webView loadFileURL:url
      allowingReadAccessToURL:url.URLByDeletingLastPathComponent];
}

@end
