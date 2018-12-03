//
//  WKWebView+JZWKExtraCookie.h
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/22.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (JZWKExtraCookie)
@property (nonatomic, strong) NSDictionary *extraCookies;
@end

NS_ASSUME_NONNULL_END
