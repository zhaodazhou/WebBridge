# WebBridge

web端与native端的交互的方式有
1：URL重定向
2：通过JSExport协议

本工程是将二者合二为一，通过对UIWebView的category，实现对原生的WebView的功能扩充；同时，通过iOS的运行时机制的method swizzle，将UIWebViewDelegate的实现交于wdobject对象，而对于业务方，亦能够通过正常的方式来实现UIWebViewDelegate代理方法，而不着痕迹。不论是直接代码生成UIWebView还是通过xib控件生成，都能够实现预定于功能。

业务方直接通过注入函数的方式来供web端的JavaScript代码来调，从而实现web端调用native端的功能。
例如：
// 注册局部函数
    [_mWebView registerFunc:@"pagejumpForSelect" observer:self selector:@selector(pagejumpForSelect:webView:) isOnMainThread:YES];
    
    web端的js代码可以通过函数名pagejumpForSelect来调用native端的pagejumpForSelect:webView:函数。
