//
//  LoginByOauthViewController.m
//  BLAPPSDKDemo
//
//  Created by zhujunjie on 2017/7/26.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "LoginByOauthViewController.h"

#define OAUTH_SERVER    @"172.16.10.210"
#define OAUTH_CLIENT_ID @"35b305aeb7abf3ef3847011556045b6e"
#define OAUTH_CLIENT_SECRET @"a74e73441370e41febe186e7ab3270ae"
#define OAUTH_REDIRECTURI   @"bl35b305aeb7abf3ef3847011556045b6e://"

#define IOSVersion                              [[[UIDevice currentDevice] systemVersion] floatValue]
#define IsiOS10Later                            !(IOSVersion < 10.0)

@interface LoginByOauthViewController () <UIWebViewDelegate>

@property (nonatomic, strong) NSString *requestUrl;

@end

@implementation LoginByOauthViewController

+ (instancetype)viewController {
    LoginByOauthViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initContentView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initContentView {
    NSURL *url = [NSURL URLWithString:self.requestUrl];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - getter / setter
- (NSString *)requestUrl {
    if (!_requestUrl) {
        NSString *redirect_uri = [OAUTH_REDIRECTURI stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
        _requestUrl = [NSString stringWithFormat:@"http://%@?response_type=token&client_id=%@&redirect_uri=%@",
                             OAUTH_SERVER, OAUTH_CLIENT_ID, redirect_uri];
        
    }
    return _requestUrl;
}

- (void)jumpToOtherAppWithURL:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString: urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
