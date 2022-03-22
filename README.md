# WebBridge

实际业务中，通过web端来展示某些功能的需求变得越来越多。为了方便web端与native端的交互，特意的开发了此库，便于各个业务部门开发自己的web后，native端能方便的进行支持。

native端与web端的交互一般有URL重定向的方式和通过JavaScriptCore这2种方式。
### URL重定向
通过实现协议UIWebViewDelegate中方法，如下：
```
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
```
若返回NO，则WebView不会对request进行处理，业务端就可以取出特定的参数进行处理。
### JavaScriptCore
通过继承JSExport协议，往web中注入被调用的方法。如下：
```
@protocol wdobjectProtocol <JSExport>
/**
*  函数功能：提供给js端来调用的函数，和Android端一致，和pc端的方式也是类似的
*  函数参数：userInfo：js端传入得json字符串，格式类似：{“operate”:”pagejump”,”data”:{“functionid”:fid,”windcode”:windcode}};
*/
- (nullable NSString *)shell_Req:(nullable NSString *)userInfo;

- (void)webCallNative:(nullable NSString *)para1;
@end
```
这两者方式都需要提前定义好接口规则，否则不能被支持。

此库对二者都支持，一来是兼容老的接口，二来为后续的需求提供便捷的 ~**通道**~ 。

### 主要思路
1. 在UIWebView的load系统函数中，对initWithFrame、initWithCoder、delegate的setter与getter函数进行method swizzling。
将一个的wdobject对象赋值给WebView对象的delegate（实现UIWebViewDelegate协议中函数的拦截），当业务端进行setDelegate时，通过关联对象技术，将设置对应保存下来，以便于拦截以后，再回调到业务端的实现；
2. 通过JSExport协议注入的函数，可以直接给web端调用。native端实现该函数的具体功能，包括解析参数，判断函数是否可以支持被调用；
3. 在注入函数方面，支持注入局部函数（某个webview对象可以调用），也支持全局函数（注入一次，所有的WebView对象都可以调用）。

### 涉及技术
category技术，JSExport协议，Method Swizzle技术和关联对象技术。





# 如何在release模式下进行真机调试？
1：编辑工程的scheme模式，将【Run】模式下的【Build Configuration】选项设置为Release模式；
2：设置工程的【Build Settings】，将【Code Signing Identity】与【Provisioning Profile】的Release的设置为相应的开发者cer和pro证书。

这个，就能在release模式下进行真机调试，毕竟有些问题在debug模式下是不复现的，而在release模式下却必现（比如对象的延迟释放问题）。

