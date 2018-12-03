//
//  JZWeakScriptMessageDelegate.h
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/21.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JZWeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;
@end

NS_ASSUME_NONNULL_END
