//
//  LoginByOauthViewController.m
//  BLAPPSDKDemo
//
//  Created by zhujunjie on 2017/7/26.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "LoginByOauthViewController.h"
#import "Tools.h"

#define OAUTH_SERVER    @"172.16.10.210"
#define OAUTH_CLIENT_ID @"35b305aeb7abf3ef3847011556045b6e"
#define OAUTH_CLIENT_SECRET @"a74e73441370e41febe186e7ab3270ae"
#define OAUTH_REDIRECTURI   @"bl35b305aeb7abf3ef3847011556045b6e://"

@interface LoginByOauthViewController ()

@property (nonatomic, strong) NSString *requestUrl;

@end

@implementation LoginByOauthViewController

+ (instancetype)viewController {
    return [Tools viewControllerFromMainStoryboard:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self openURLString:self.requestUrl];
}

- (void)openURLString:(NSString *)URLString {
    NSURL *url = [NSURL URLWithString:URLString];
    if (!url || ![[UIApplication sharedApplication] canOpenURL:url]) {
        return;
    }
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
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
    [self openURLString:urlString];
}

@end
