//
//  JZWkWebCookieManager.m
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/20.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import "JZWkWebCookieManager.h"

@implementation JZWkWebCookieManager
+ (NSDictionary *)wkCommonExtraCookies {
    NSMutableDictionary *extraCookies = [NSMutableDictionary dictionary];
    extraCookies[@"dj_os"] = @"ios";
    return extraCookies;
}
@end
