//
//  JZBaseWKWebViewController.m
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/20.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import "JZBaseWKWebViewController.h"
#import <Masonry.h>
#import "JZWKWebService.h"
#import "JZWKMessageHandlerServer.h"
#import "JZWeakScriptMessageDelegate.h"

@interface JZBaseWKWebViewController ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property(nonatomic, copy, readwrite) NSString *url;
@property (nonatomic, strong) WKUserContentController *userContentController;
@property (nonatomic, strong) WKWebViewConfiguration * webConfiguration;

@property (nonatomic, copy) NSString *goBackJsMethod;
@property (nonatomic, copy) NSString *naviTitle;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) JZWeakScriptMessageDelegate *scriptDele;
@end

@implementation JZBaseWKWebViewController

- (instancetype)initWithUrl:(NSString *)url title:(NSString *)title {
    if (self = [self init]) {
        url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.url = url;
        self.naviTitle = title;
    }
    return self;
}
- (instancetype)initWithURL:(NSString *)url {
    if (self = [self init]) {
        url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.url = url;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.child = (id<JZWKWebViewConfigDelegate>) self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets = UIEdgeInsetsZero;
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    if (self.naviTitle.length > 0) {
        self.navigationItem.title = self.naviTitle;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
    
    WKUserContentController *userCtrl = self.webView.configuration.userContentController;
    self.scriptDele = [[JZWeakScriptMessageDelegate alloc] initWithDelegate:self];
    for (NSString *messageHanderName in [JZWKMessageHandlerServer sharedInstance].messageHandlerList) {
        [userCtrl addScriptMessageHandler:self.scriptDele name:messageHanderName];
    }
}

#pragma mark - private method
- (void)changeTitle:(NSString *)title {
    if (self.naviTitle.length == 0) {
        self.navigationItem.title = title;
    }
}
- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        return;
    }else {
        if (self.navigationController.viewControllers.count > 1 &&
            self.navigationController.topViewController == self) {
            self.backButton.hidden = NO;
        }else {
            self.backButton.hidden = YES;
        }
    }
}
// 直接回退
- (void)goBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
// 受到js回退拦截的回退(有拦截时不进行回退)
- (void)wkWebOnBack {
    if (self.goBackJsMethod != nil) {
        [self.webView evaluateJavaScript:self.goBackJsMethod completionHandler:nil];
        return;
    }
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addBackActionListener:(NSString *)jsMethod {
    if ([jsMethod isKindOfClass:[NSString class]]
        &&jsMethod.length > 0) {
        self.goBackJsMethod = jsMethod;
    }else {
        self.goBackJsMethod = nil;
    }
}

- (void)dealloc {
    if (@available(iOS 9.0, *)) {
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                         completionHandler:^(NSArray<WKWebsiteDataRecord *> *__nonnull records) {
                             [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] forDataRecords:records completionHandler:^{
                                 NSLog(@"");
                             }];
                         }];
    } else {
        // Fallback on earlier versions
    }
    
    for (NSString *messageHanderName in [JZWKMessageHandlerServer sharedInstance].messageHandlerList) {
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:messageHanderName];
    }
}

- (void)rightBtnClick {
    if (self.rightBtnClickBlock) {
        self.rightBtnClickBlock();
    }
}

- (void)resetCookie {
    NSMutableString *cookieSource = [NSMutableString string];
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    [cookieDic addEntriesFromDictionary:self.child.extraCookies];
    
    for (NSString *key in cookieDic) {
        [cookieSource appendFormat:@"document.cookie ='%@=%@;domain=%@;path=/';", key, cookieDic[key],self.child.wkCookieDomain];
    }
    [self.webView evaluateJavaScript:cookieSource completionHandler:nil];
}

#pragma mark -WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.body isKindOfClass:[NSDictionary class]] || [message.body isKindOfClass:[NSNull class]]) {
        NSDictionary *body = message.body;
        NSString *methodName = message.name;
        NSLog(@"method:%@,params:%@", methodName, body);
        [[JZWKMessageHandlerServer sharedInstance] handleMethod:methodName params:body source:self];
    } else {
        NSLog(@"json字符串参数格式错误，必须使用字典参数");
    }
}

#pragma mark -WKWebViewDelegate
// 如果不添加这个，那么wkwebview跳转不了AppStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *url = [navigationAction.request.URL absoluteString];
    if ([url hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else if ([url hasPrefix:@"tel:"]) {
        [url stringByReplacingOccurrencesOfString:@"tel:" withString:@"tel://"];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if ([url hasPrefix:@"daojia://"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载%@--%@", webView.title, [webView.URL absoluteString]);
    [self changeTitle:webView.title];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"内容开始返回%@--%@", webView.title, [webView.URL absoluteString]);
    [self changeTitle:webView.title];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"页面加载完成%@--%@", webView.title, [webView.URL absoluteString]);
    [self changeTitle:webView.title];
    NSString *urlStr = webView.URL.absoluteString;
    if (![urlStr isEqualToString:@"about:blank"]) {
        self.url = urlStr;
    }
    
    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"页面加载失败%@--%@--reason:%@", webView.title, [webView.URL absoluteString], error);
    [self changeTitle:webView.title];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message ?: @"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                           completionHandler();
                                                       }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - lazy load
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"navbar_back"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"navbar_back"] forState:UIControlStateHighlighted];
        [_backButton sizeToFit];
        [_backButton addTarget:self action:@selector(wkWebOnBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.webConfiguration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    return _webView;
}

- (WKUserContentController *)userContentController {
    if (!_userContentController) {
        // WKWebView cookie JS注入
        NSMutableString *cookieSource = [NSMutableString string];
        NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
        [cookieDic addEntriesFromDictionary:self.child.extraCookies];
        for (NSString *key in cookieDic) {
            [cookieSource appendFormat:@"document.cookie ='%@=%@;domain=%@;path=/';", key, cookieDic[key], self.child.wkCookieDomain];
        }
        WKUserScript *script = [[WKUserScript alloc] initWithSource:[cookieSource copy] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        _userContentController = [[WKUserContentController alloc] init];
        [_userContentController addUserScript:script];
    }
    return _userContentController;
}

- (WKWebViewConfiguration *)webConfiguration {
    if (!_webConfiguration) {
        _webConfiguration = [[WKWebViewConfiguration alloc] init];
        _webConfiguration.preferences = [WKPreferences new];
        _webConfiguration.preferences.minimumFontSize = 10;
        _webConfiguration.preferences.javaScriptEnabled = YES;
        _webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        _webConfiguration.userContentController = self.userContentController;
    }
    return _webConfiguration;
}

#pragma mark - JZWKWebViewConfigDelegate
- (NSDictionary *)extraCookies {
    return @{@"dj_os":@"ios"};
}
- (NSString *)wkCookieDomain {
    return @".daojia.com";
}
@end
