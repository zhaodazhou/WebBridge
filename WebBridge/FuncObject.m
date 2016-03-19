//
//  FuncObject.m
//  WebBridge
//
//  Created by dazhou on 16/3/19.
//  Copyright © 2016年 dazhou. All rights reserved.
//

#import "FuncObject.h"

@implementation FuncObject

- (void)init:(nonnull id)aObserver selector:(nonnull SEL)aSelector isOnMainThread:(BOOL)isMainThread
{
    self.aObserver = aObserver;
    self.aSelector = aSelector;
    _isMainThread = isMainThread;
}

@end
