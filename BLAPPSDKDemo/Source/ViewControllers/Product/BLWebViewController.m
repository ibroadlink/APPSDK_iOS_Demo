//
//  BLWebViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/28.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLWebViewController.h"
#import <WebKit/WebKit.h>

@interface BLWebViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, strong)WKWebView *webView;
@end

@implementation BLWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
}

- (void)viewInit {
    self.webView = [[WKWebView alloc]initWithFrame:self.view.frame];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
}

@end
