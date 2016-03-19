//
//  wdobject.h
//  WebBridge
//
//  Created by dazhou on 16/3/19.
//  Copyright © 2016年 dazhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <JavaScriptCore/JavaScriptCore.h>
#import "FuncObject.h"


@protocol wdobjectProtocol <JSExport>


/**
 *  函数功能：提供给js端来调用的函数，和Android端一致，和pc端的方式也是类似的
 *  函数参数：userInfo：js端传入得json字符串，格式类似：{"operate":"pagejump","data":{"functionid":fid,"windcode":windcode}};
 */
- (nullable NSString *)shell_Req:(nullable NSString *)userInfo;

- (void)webCallNative:(nullable NSString *)para1;

@end



@interface wdobject : NSObject<wdobjectProtocol, UIWebViewDelegate>

@property (nonatomic, weak) UIWebView * mWebView;


/**
 *  函数功能：设置全局的注入函数
 *  参数aObject为nil时，表示移除注入的函数； 不为nil时，则表示注入相应的函数
 */
+ (BOOL)registerGlobalFunc:(nonnull NSString *)funcName observer:(nullable id)aObserver selector:(nullable SEL)aSelector isOnMainThread:(BOOL)isMainThread;

/**
 * 函数功能：注入局部函数
 */
- (BOOL)registerFunc:(nonnull NSString *)funcName observer:(nonnull id)aObserver selector:(nonnull SEL)aSelector isOnMainThread:(BOOL)isMainThread;

@end
