//
//  wdobject.m
//  WebBridge
//
//  Created by dazhou on 16/3/19.
//  Copyright © 2016年 dazhou. All rights reserved.
//

#import "wdobject.h"

static NSMutableDictionary * globalfuncObjectDict;

@interface wdobject()

/** 保存局部注入函数 */
@property (nonatomic, strong, nullable) NSMutableDictionary * funcObjectDict;

@end


@implementation wdobject

+ (void)initialize
{
    globalfuncObjectDict = [NSMutableDictionary dictionary];
}

- (instancetype)init
{
    if (self = [super init]) {
        _funcObjectDict = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - register functions
+ (BOOL)registerGlobalFunc:(nonnull NSString *)funcName observer:(nullable id)aObserver selector:(nullable SEL)aSelector isOnMainThread:(BOOL)isMainThread
{
    // 反注册
    if (aObserver == nil || aSelector == nil) {
        [globalfuncObjectDict removeObjectForKey:funcName];
        return YES;
    }
    
    // 注册
    FuncObject * aFObject = [[FuncObject alloc] init];
    [aFObject init:aObserver selector:aSelector isOnMainThread:isMainThread];
    if ([globalfuncObjectDict.allKeys containsObject:funcName]) {
        NSAssert(NO, @"not allow register same key in globalfuncObjectDict");
        return NO;
    }
    
    [globalfuncObjectDict setObject:aFObject forKey:funcName];
    
    return YES;
}


- (BOOL)registerFunc:(nonnull NSString *)funcName observer:(nonnull id)aObserver selector:(nonnull SEL)aSelector isOnMainThread:(BOOL)isMainThread
{
    FuncObject * aFObject = [[FuncObject alloc] init];
    [aFObject init:aObserver selector:aSelector isOnMainThread:isMainThread];
    
    if ([_funcObjectDict.allKeys containsObject:funcName]) {
        NSAssert(NO, @"not allow register same key");
        return NO;
    }
    
    [_funcObjectDict setObject:aFObject forKey:funcName];
    
    return YES;
}

- (void)webCallNative:(NSString *)para1
{
    NSLog(@"%@", para1);
}


/** 给js来调的
 *  注入的函数一定要是返回值类型为nsstring的
 */
- (NSString *)shell_Req:(NSString *)jsonStr
{
    NSDictionary * userInfoDict = [self serialization:jsonStr];
    
    if (userInfoDict == nil) {
        return nil;
    }
    
    FuncObject * aObject = [_funcObjectDict objectForKey:[userInfoDict objectForKey:@"operate"]];
    if (aObject == nil) {
        // 尝试去调用全局注入函数
        return [self callGlobalFunc:userInfoDict];;
    }
    
    NSString * result = nil;
    
    if (aObject.isMainThread == YES && [aObject.aObserver respondsToSelector:aObject.aSelector]) {
                [aObject.aObserver performSelectorOnMainThread:aObject.aSelector withObject:userInfoDict waitUntilDone:NO];
    }
    else if ([aObject.aObserver respondsToSelector:aObject.aSelector]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        result = [aObject.aObserver performSelector:aObject.aSelector withObject:userInfoDict withObject:_mWebView];
#pragma clang diagnostic pop
        
    }
    
    return result;
}

- (NSString *)callGlobalFunc:(NSDictionary *)userInfo
{
   FuncObject *  aObject = [globalfuncObjectDict objectForKey:[userInfo objectForKey:@"operate"]];
    if (aObject == nil) {
        return nil;
    }
    
    
    NSString * result = nil;
    
    if (aObject.isMainThread && [aObject.aObserver respondsToSelector:aObject.aSelector]) {
        [aObject.aObserver performSelectorOnMainThread:aObject.aSelector withObject:userInfo waitUntilDone:NO];
    }
    else if ([aObject.aObserver respondsToSelector:aObject.aSelector]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        result = [aObject.aObserver performSelector:aObject.aSelector withObject:userInfo withObject:_mWebView];
#pragma clang diagnostic pop
        
    }
    
    return result;
}


/** 将js端传入得JsonStr字典化 */
- (NSDictionary *)serialization:(NSString *)jsonStr
{
    NSError * error;
    NSDictionary * userInfoDict;
    @try {
        NSString * str = [jsonStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
        userInfoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    } @catch (NSException *exception) {
        NSLog(@"%@, %@", NSStringFromSelector(_cmd), exception);
        return nil;
    } @finally {
        
    }
    
    
    if (error) {
        NSAssert(0, @"error info:%@", error);
        return nil;
    }
    
    return userInfoDict;
}

#pragma mark - UIWebViewDelegate -
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *reallyStr = [request.URL.relativeString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([reallyStr hasPrefix:@"protocol://"]) {
        [self protocolResolve:reallyStr withPrefix:@"protocol://"];
        return NO;
    }
    
    
    id<UIWebViewDelegate> aDelegate = [webView delegate];
    
    if (aDelegate && [aDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        BOOL result = [aDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        return result;
    }
    
    return YES;
}

- (void)protocolResolve:(NSString *) targetString withPrefix:(NSString *) preSttring
{
    NSRange range = [targetString rangeOfString:preSttring];
    NSString *dicStr = [targetString substringFromIndex:(range.location + range.length)];
    
    [self shell_Req:dicStr];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    id<UIWebViewDelegate> aDelegate = [webView delegate];
    
    if (aDelegate && [aDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [aDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    JSContext * jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    jsContext[@"wdobject"] = self;
    
    id<UIWebViewDelegate> aDelegate = [webView delegate];
    
    if (aDelegate && [aDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [aDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    id<UIWebViewDelegate> aDelegate = [webView delegate];
    
    if (aDelegate && [aDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [aDelegate webView:webView didFailLoadWithError:error];
    }
}

- (void)dealloc
{
}


@end
