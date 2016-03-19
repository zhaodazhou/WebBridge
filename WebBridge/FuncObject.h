//
//  FuncObject.h
//  WebBridge
//
//  Created by dazhou on 16/3/19.
//  Copyright © 2016年 dazhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FuncObject : NSObject

@property (nonatomic, assign) BOOL isMainThread;
@property (nonatomic, weak) id aObserver;
@property (nonatomic, assign, nonnull) SEL aSelector;

- (void)init:(nonnull id)aObserver selector:(nonnull SEL)aSelector isOnMainThread:(BOOL)isMainThread;

@end
