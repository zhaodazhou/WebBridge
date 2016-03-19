//
//  UIWebView+BridgeWebView.m
//  WebBridge
//
//  Created by dazhou on 16/3/19.
//  Copyright © 2016年 dazhou. All rights reserved.
//

#import "UIWebView+BridgeWebView.h"
#import <objc/runtime.h>
#import "wdobject.h"

static char delegateKey;
static char wdobjectKey;

@implementation UIWebView (BridgeWebView)

+ (void)load
{
    [[self class] switchIMP:@selector(setDelegate:) swizzleIMP:@selector(setSwizzleDelegate:)];
    [[self class] switchIMP:@selector(delegate) swizzleIMP:@selector(swizzleDelegate)];
    [[self class] switchIMP:@selector(initWithFrame:) swizzleIMP:@selector(swizzleInitWithFrame:)];
    [[self class] switchIMP:@selector(initWithCoder:) swizzleIMP:@selector(swizzleInitWithCoder:)];
}

+ (void)switchIMP:(SEL)originalSEL swizzleIMP:(SEL)swizzleSEL
{
    Class aClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(aClass, originalSEL);
    Method swizzleMethod = class_getInstanceMethod(aClass, swizzleSEL);
    method_exchangeImplementations(originalMethod, swizzleMethod);
}

- (instancetype)swizzleInitWithFrame:(CGRect)frame
{
    [self swizzleInitWithFrame:frame];
    [self setDefaultDelegateAndObject];
    
    return self;
}

- (instancetype)swizzleInitWithCoder:(NSCoder *)aDecoder
{
    [self swizzleInitWithCoder:aDecoder];
    [self setDefaultDelegateAndObject];
    return self;
}

- (void)setDefaultDelegateAndObject
{
    wdobject * aObject = [self getWdobject];
    aObject.mWebView = self;
    [self setSwizzleDelegate:aObject];
}

- (nullable JSContext *)getJsContext
{
    return [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
}

- (nullable wdobject *)getWdobject
{
    wdobject * aWdobject = objc_getAssociatedObject(self, &wdobjectKey);
    if (aWdobject) {
        return aWdobject;
    }
    
    aWdobject = [wdobject new];
    
    objc_setAssociatedObject(self, &wdobjectKey, aWdobject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return aWdobject;
}

- (nullable id<UIWebViewDelegate>)swizzleDelegate
{
    id<UIWebViewDelegate> aDelegate = objc_getAssociatedObject(self, &delegateKey);
    return aDelegate;
}

- (void)setSwizzleDelegate:(id<UIWebViewDelegate>)delegate
{
    objc_setAssociatedObject(self, &delegateKey, delegate, OBJC_ASSOCIATION_ASSIGN);
}


#pragma mark - register functions -
- (BOOL)registerFunc:(nonnull NSString *)funcName observer:(nonnull id)aObserver selector:(nonnull SEL)aSelector isOnMainThread:(BOOL)isMainThread
{
    if (funcName == nil || funcName.length == 0 || aObserver == nil) {
        NSAssert(NO, @"data illegal");
        return NO;
    }
    
    wdobject * aWdobject = [self getWdobject];
    return [aWdobject registerFunc:funcName observer:aObserver selector:aSelector isOnMainThread:isMainThread];
}


+ (BOOL)registerGlobalFunc:(nonnull NSString *)funcName observer:(nonnull id)aObserver selector:(nonnull SEL)aSelector isOnMainThread:(BOOL)isMainThread
{
    return [wdobject registerGlobalFunc:funcName observer:aObserver selector:aSelector isOnMainThread:isMainThread];
}

+ (BOOL)unRegisterGlobalFunc:(nonnull NSString *)funcName
{
    return [wdobject registerGlobalFunc:funcName observer:nil selector:nil isOnMainThread:NO];
}


#pragma mark - native call web functions -
- (nullable NSString *)nativeCallWeb:(NSString *)jsonStr
{
    NSString * str = [NSString stringWithFormat:@"NativeCallWeb('%@')", jsonStr];
    
    return [[[self getJsContext] evaluateScript:str] toString];
}

- (nullable NSString *)nativeCallWebByDict:(nonnull NSDictionary *)dict
{
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (error) {
        NSAssert(NO, @"error : %@", error);
        return nil;
    }
    
    NSString * str = [NSString stringWithFormat:@"NativeCallWeb('%@')", jsonString];
    
    return [[[self getJsContext] evaluateScript:str] toString];
}



@end
