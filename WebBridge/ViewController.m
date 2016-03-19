//
//  ViewController.m
//  WebBridge
//
//  Created by dazhou on 16/3/19.
//  Copyright © 2016年 dazhou. All rights reserved.
//

#import "ViewController.h"

#import "UIWebView+BridgeWebView.h"

@interface ViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * mWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWebView];
    [self initBtn1];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"html"];
    NSURL * url = [NSURL fileURLWithPath:path];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
    
    
    [_mWebView loadRequest:request];
    
    // 注册局部函数
    [_mWebView registerFunc:@"pagejumpForSelect" observer:self selector:@selector(pagejumpForSelect:webView:) isOnMainThread:YES];
    
    // 注册全局函数
    [UIWebView registerGlobalFunc:@"callGlobalFunc" observer:self selector:@selector(callGlobalFunc:webView:) isOnMainThread:YES];
}

- (NSString *)callGlobalFunc:(NSDictionary *)dict webView:(UIWebView *)webView
{
    NSLog(@"调用本地端的全局函数");
    return @"调用本地端的全局函数 success";
}

- (NSString *)pagejumpForSelect:(NSDictionary *)dict webView:(UIWebView *)webView
{
    NSLog(@"调用本地端的局部函数");
    return @"调用本地端的局部函数 success";
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"call local shouldStartLoadWithRequest 0");
    return YES;
}

- (void)testNativeCallWeb
{
    NSDictionary * dict = @{@"operate" : @"pagejump",
                            @"data" : @{@"param1" : @"1",
                                        @"param2" : @"2"}
                            };
    
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (error) {
        NSLog(@"error1: %@", error);
        return;
    }
    
    [_mWebView nativeCallWeb:jsonString];
}


- (void)initBtn1
{
    UIButton * btn1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 40, 300, 25)];
    btn1.backgroundColor = [UIColor greenColor];
    [btn1 setTitle:@"native Call Web" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(testNativeCallWeb) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}

- (void)initWebView
{
    CGRect frame = CGRectMake(0, 110, CGRectGetWidth([UIScreen mainScreen].bounds), 500);
    _mWebView = [[UIWebView alloc] initWithFrame:frame];
    _mWebView.delegate = self;
    
    [self.view addSubview:_mWebView];
}

@end
