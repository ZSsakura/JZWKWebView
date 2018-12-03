//
//  JZWeakScriptMessageDelegate.m
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/21.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import "JZWeakScriptMessageDelegate.h"

@interface JZWeakScriptMessageDelegate ()
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
@end

@implementation JZWeakScriptMessageDelegate
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}
@end
