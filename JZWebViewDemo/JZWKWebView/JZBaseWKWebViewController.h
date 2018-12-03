//
//  JZBaseWKWebViewController.h
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/20.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JZWKWebViewConfigDelegate <NSObject>
- (NSDictionary *)extraCookies;
- (NSString *)wkCookieDomain;
@end

@interface JZBaseWKWebViewController : UIViewController
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, weak) id <JZWKWebViewConfigDelegate> _Nullable child;

- (void)rightBtnClick;
@property (nonatomic, copy) void (^rightBtnClickBlock)(void);

/**
 重置cookie,wkWebView的cookie自己管理，有cookie变动时需要手动重置cookie
 */
- (void)resetCookie;
- (void)goBack; // 点击返回
- (void)addBackActionListener:(NSString *)jsMethod;
- (instancetype)initWithUrl:(NSString *)url title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
