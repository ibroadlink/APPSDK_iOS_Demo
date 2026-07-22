//
//  LoginByOauthViewController.m
//  BLAPPSDKDemo
//
//  Created by zhujunjie on 2017/7/26.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "LoginByOauthViewController.h"
#import "BLTheme.h"
#import "BLStatusBar.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>

#define OAUTH_SERVER    @"172.16.10.210"
#define OAUTH_CLIENT_ID @"35b305aeb7abf3ef3847011556045b6e"
#define OAUTH_CLIENT_SECRET @"a74e73441370e41febe186e7ab3270ae"
#define OAUTH_REDIRECTURI   @"bl35b305aeb7abf3ef3847011556045b6e://"

@interface LoginByOauthViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *loginWebView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) NSString *requestUrl;
@end

@implementation LoginByOauthViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"OAuth Login";
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self buildUI];
    [self loadOAuthPage];
}

- (void)buildUI {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.loginWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.loginWebView.navigationDelegate = self;
    self.loginWebView.backgroundColor = [BLTheme backgroundColor];
    self.loginWebView.opaque = NO;
    [self.view addSubview:self.loginWebView];

    if (@available(iOS 13.0, *)) {
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    } else {
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];

    [self.loginWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self.loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)loadOAuthPage {
    NSURL *url = [NSURL URLWithString:self.requestUrl];
    if (!url) {
        [BLStatusBar showTipMessageWithStatus:@"Invalid OAuth URL"];
        return;
    }
    [self.loadingIndicator startAnimating];
    [self.loginWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)openURLString:(NSString *)URLString {
    NSURL *url = [NSURL URLWithString:URLString];
    if (!url) {
        return;
    }
    if ([self shouldHandleOAuthRedirectURL:url]) {
        [self handleOAuthRedirectURL:url];
        return;
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (BOOL)shouldHandleOAuthRedirectURL:(NSURL *)url {
    NSString *scheme = url.scheme.lowercaseString;
    NSString *redirectScheme = [NSURL URLWithString:OAUTH_REDIRECTURI].scheme.lowercaseString;
    return [scheme isEqualToString:redirectScheme];
}

- (void)handleOAuthRedirectURL:(NSURL *)url {
    NSString *fragment = url.fragment ?: @"";
    NSString *absolute = url.absoluteString ?: @"";
    NSString *payload = fragment.length > 0 ? fragment : absolute;

    if ([payload containsString:@"access_token="]) {
        [BLStatusBar showTipMessageWithStatus:@"OAuth login succeeded"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if ([payload containsString:@"error="]) {
        [BLStatusBar showTipMessageWithStatus:@"OAuth login failed"];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([self shouldHandleOAuthRedirectURL:url]) {
        [self handleOAuthRedirectURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    NSString *scheme = url.scheme.lowercaseString;
    if (scheme.length > 0 &&
        ![scheme isEqualToString:@"http"] &&
        ![scheme isEqualToString:@"https"] &&
        ![scheme isEqualToString:@"about"]) {
        [self openURLString:url.absoluteString];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.loadingIndicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.loadingIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.loadingIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.loadingIndicator stopAnimating];
}

#pragma mark - Public

- (void)jumpToOtherAppWithURL:(NSString *)urlString {
    [self openURLString:urlString];
}

#pragma mark - Getter

- (NSString *)requestUrl {
    if (!_requestUrl) {
        NSString *redirect_uri = [OAUTH_REDIRECTURI stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
        _requestUrl = [NSString stringWithFormat:@"http://%@?response_type=token&client_id=%@&redirect_uri=%@",
                       OAUTH_SERVER, OAUTH_CLIENT_ID, redirect_uri];
    }
    return _requestUrl;
}

@end
