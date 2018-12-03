//
//  ViewController.m
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/20.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import "ViewController.h"
#import "JZBaseWKWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"testPush" forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(testPush) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.frame = CGRectMake(100, 100, 100, 50);
}

- (void)testPush {
    JZBaseWKWebViewController *webVc = [[JZBaseWKWebViewController alloc] initWithUrl:@"http://www.baidu.com" title:@""];
    [self.navigationController pushViewController:webVc animated:YES];
}


@end
