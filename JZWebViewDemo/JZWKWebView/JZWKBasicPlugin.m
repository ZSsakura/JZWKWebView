//
//  JZWKBasicPlugin.m
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/22.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import "JZWKBasicPlugin.h"
#import "JZBaseWKWebViewController.h"

@implementation JZWKBasicPlugin
// 更换VC的导航栏标题
+ (void)modifyTitle:(NSDictionary *)params source:(JZBaseWKWebViewController *)sourceVC {
    NSString *title = params[@"title"];
    if ([title isKindOfClass:[NSString class]] && title.length > 0) {
        [sourceVC setTitle:title];
    }
}
// 导航栏展示右按钮
+ (void)showRight:(NSDictionary *)params source:(JZBaseWKWebViewController *)sourceVC {
    if ([params[@"visible"] boolValue]) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitle:params[@"title"] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [rightBtn setTitleColor:[UIColor colorWithRed:41.0/255 green:45.0/255 blue:51.0/255 alpha:1] forState:UIControlStateNormal];
        [rightBtn sizeToFit];
        [rightBtn addTarget:sourceVC action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
        sourceVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        __weak JZBaseWKWebViewController *weakVc = sourceVC;
        [sourceVC setRightBtnClickBlock:^{
            [weakVc.webView evaluateJavaScript:params[@"callBack"] completionHandler:nil];
        }];
    } else {
        sourceVC.navigationItem.rightBarButtonItem = nil;
    }
}
// 关闭VC
+ (void)closeActivitysource:(JZBaseWKWebViewController *)sourceVC {
    [sourceVC.navigationController popViewControllerAnimated:YES];
}
// 添加导航返回键点击拦截
+ (void)addBackActionListener:(NSDictionary *)params source:(JZBaseWKWebViewController *)sourceVC {
    if ([params[@"state"] boolValue]) {
        NSString *jsMethod = params[@"callback"];
        [sourceVC addBackActionListener:jsMethod];
    } else {
        [sourceVC addBackActionListener:@""];
    }
}
// 返回
+ (void)goBacksource:(JZBaseWKWebViewController *)sourceVC {
    [sourceVC goBack];
}
// 跳转到app对应设置页面
+ (void)goAppSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
