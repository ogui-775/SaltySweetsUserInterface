//Created by Salty on 8/10/26.

#import "Base/SOPageControllerBase.h"
#import <WebKit/WebKit.h>

@interface SODocumentationPageController : SOPageControllerBase <NSOutlineViewDataSource>
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet NSOutlineView *documentOutlineView;
@end
