//
//  JZWKMessageHandlerServer.m
//  JZWebViewDemo
//
//  Created by 广羽孙 on 2018/11/22.
//  Copyright © 2018 广羽孙. All rights reserved.
//

#import "JZWKMessageHandlerServer.h"
#import "JZWKBasicPlugin.h"

@interface JZWKMessageHandlerServer ()
@property (nonatomic, copy) NSArray *messageHandlerList;

@property (nonatomic, strong) NSMutableDictionary *messageHandlersDict;
@end

@implementation JZWKMessageHandlerServer
+ (void)registerUserPluginWithPluginClass:(Class)pluginClass messageHandlerList:(NSArray *)list {
    JZWKMessageHandlerServer *server = [JZWKMessageHandlerServer sharedInstance];
    [server addPluginWithPluginClass:pluginClass messageHandlerList:list];
}

+ (instancetype)sharedInstance {
    static JZWKMessageHandlerServer *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[JZWKMessageHandlerServer alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.messageHandlersDict = [NSMutableDictionary dictionary];
        [self messageHandlerList];
    }
    return self;
}

- (NSArray *)messageHandlerList {
    if (!_messageHandlerList) {
        NSString *listPath = [[NSBundle mainBundle] pathForResource:@"JZWKBasicMessageHandlerNames" ofType:@"plist"];
        _messageHandlerList = [NSArray arrayWithContentsOfFile:listPath];
        [self.messageHandlersDict setObject:[JZWKBasicPlugin class] forKey:_messageHandlerList];
    }
    return _messageHandlerList;
}

- (void)addPluginWithPluginClass:(Class)pluginClass messageHandlerList:(NSArray *)list {
    [self.messageHandlersDict setObject:pluginClass forKey:list];
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.messageHandlerList];
    [tempArr addObjectsFromArray:list];
    self.messageHandlerList = [tempArr copy];
}

- (void)handleMethod:(NSString *)methodName params:(NSDictionary *)params source:(JZBaseWKWebViewController *)sourceVC {
    
    Class pluginClass;
    for (NSArray *messageHandlerList in self.messageHandlersDict) {
        if ([messageHandlerList containsObject:methodName]) {
            pluginClass = [self.messageHandlersDict objectForKey:messageHandlerList];
        }
    }
    if (pluginClass == nil) {
        NSLog(@"js交互方法列表中不存在此方法");
        return;
    }
    BOOL hasParam = NO;
    if (params && ![params isKindOfClass:[NSNull class]]) {
        methodName = [methodName stringByAppendingString:@":"];
        hasParam = YES;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(methodName);
    if ([pluginClass respondsToSelector:selector]) {
        [pluginClass performSelector:selector withObject:params];
    }else {
        methodName = [methodName stringByAppendingString:@"source:"];
        selector = NSSelectorFromString(methodName);
        if ([pluginClass respondsToSelector:selector]) {
            if (hasParam) {
                [pluginClass performSelector:selector withObject:params withObject:sourceVC];
            }else {
                [pluginClass performSelector:selector withObject:sourceVC];
            }
        }else {
            NSLog(@"error,native方法不存在 methodName = %@ +%@",[pluginClass class],methodName);
        }
    }
#pragma clang diagnostic pop
}
@end
