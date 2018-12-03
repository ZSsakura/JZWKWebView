//
//  JZWKMessageHandlerServer.h
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/22.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JZBaseWKWebViewController;
NS_ASSUME_NONNULL_BEGIN

@interface JZWKMessageHandlerServer : NSObject
+ (void)registerUserPluginWithPluginClass:(Class)pluginClass messageHandlerList:(NSArray *)list;

+ (instancetype)sharedInstance;
- (NSArray *)messageHandlerList;
- (void)handleMethod:(NSString *)methodName params:(NSDictionary *)params source:(JZBaseWKWebViewController *)sourceVC;
@end

NS_ASSUME_NONNULL_END
