//
//  WKWebView+JZWKExtraCookie.m
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/22.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import "WKWebView+JZWKExtraCookie.h"
#import "JZBaseWKWebViewController.h"
#import <objc/runtime.h>

static const char * extraCookiesKey = "extra_cookiesKey";

@implementation WKWebView (JZWKExtraCookie)

- (NSDictionary *)extraCookies {
    return objc_getAssociatedObject(self, extraCookiesKey);
}
- (void)setExtraCookies:(NSDictionary *)extraCookies {
    objc_setAssociatedObject(self, extraCookiesKey, extraCookies, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    Class selfClass = [self class];
    
    SEL oriSEL = @selector(loadRequest:);
    Method oriM = class_getInstanceMethod(selfClass, oriSEL);
    
    SEL cusSEL = @selector(JZ_loadRequest:);
    Method cus_M = class_getInstanceMethod(selfClass, cusSEL);
    
    BOOL addSuc = class_addMethod(selfClass, oriSEL, method_getImplementation(cus_M), method_getTypeEncoding(cus_M));
    if (addSuc) {
        class_replaceMethod(selfClass, cusSEL, method_getImplementation(oriM), method_getTypeEncoding(oriM));
    }else {
        method_exchangeImplementations(oriM, cus_M);
    }
}

- (nullable WKNavigation *)JZ_loadRequest:(NSURLRequest *)request {
    NSString *cookie = [request.allHTTPHeaderFields objectForKey:@"Cookie"];
    if (cookie.length == 0) {
        NSMutableString *cookieNew = [NSMutableString string];
        NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
        [cookieDic addEntriesFromDictionary:self.extraCookies];
        for (NSString *key in cookieDic) {
            [cookieNew appendFormat:@";%@=%@",key,cookieDic[key]];
        }
        NSMutableURLRequest *requestNew = [NSMutableURLRequest requestWithURL:request.URL];
        [requestNew setValue:[cookieNew copy] forHTTPHeaderField:@"Cookie"];
        return [self JZ_loadRequest:requestNew];
    }else {
        return [self JZ_loadRequest:request];
    }
}

@end
