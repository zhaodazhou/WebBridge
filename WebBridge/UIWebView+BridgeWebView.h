//
//  UIWebView+BridgeWebView.h
//  WebBridge
//
//  Created by dazhou on 16/3/19.
//  Copyright © 2016年 dazhou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <JavaScriptCore/JavaScriptCore.h>


@interface UIWebView (BridgeWebView)

/**
 *  aSelector函数的形式是固定的，有2个参数，分别是字典，一个是UIWebView对象，返回值类型为NSString。
 *  比如：- (NSString *)pagejump:(NSDictionary *)dict webView:(UIWebView *)webView
 */
- (BOOL)registerFunc:(nonnull NSString *)funcName observer:(nonnull id)aObserver selector:(nonnull SEL)aSelector isOnMainThread:(BOOL)isMainThread;


/**
 *  此函数慎用！！！
 *  注册函数进入全局，后续每个webview的实例化时，都会注入这个函数
 *  aSelector函数的形式是固定的，有2个参数，分别是字典，一个是UIWebView对象，返回值类型为NSString。
 *  比如：- (NSString *)callGlobalFunc:(NSDictionary *)dict webView:(UIWebView *)webView
 */
+ (BOOL)registerGlobalFunc:(nonnull NSString *)funcName observer:(nonnull id)aObserver selector:(nonnull SEL)aSelector isOnMainThread:(BOOL)isMainThread;

/**
 *  反注册掉全局的注入函数
 */
+ (BOOL)unRegisterGlobalFunc:(nonnull NSString *)funcName;


/**
 *  native调用webView的函数
 *  注意：web端需要定义相应的js方法来被调用，目前定义的函数名为：NativeCallWeb('')
 */
- (nullable NSString *)nativeCallWeb:(nonnull NSString *)jsonStr;

/**
 *  native调用webView的函数
 *  注意：web端需要定义相应的js方法来被调用，目前定义的函数名为：NativeCallWeb('')
 */
- (nullable NSString *)nativeCallWebByDict:(nonnull NSDictionary *)dict;

@end
