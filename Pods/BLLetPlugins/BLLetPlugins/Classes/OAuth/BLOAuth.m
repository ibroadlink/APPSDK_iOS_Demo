//
//  BLOAuth.m
//  Let
//
//  Created by zhujunjie on 2017/7/30.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "BLOAuth.h"

@interface BLOAuth ()

/** 用户登录成功过后的跳转页面地址 暂定为 bl12345678:// 需要第三方APP在应用里配置该URL*/
@property (nonatomic, copy) NSString *redirectURI;

/** 用户授权类型 暂时只支持 token 方式 */
@property (nonatomic, copy) NSString *response_type;

/** 用户授权代理APP名称 */
@property (nonatomic, copy) NSString *oauthAgentApp;

/** 用户授权URL */
@property (nonatomic, copy) NSString *oauthAgentUrl;

@property (nonatomic, strong) BLApiUrls *apiUrls;

@property (nonatomic, strong) BLConfigParam *configParam;
@end

@implementation BLOAuth

- (id)initWithCliendId:(NSString *)clientId redirectURI:(NSString *)redirectURI {
    self = [super init];
    if (self) {
        self.apiUrls = [BLApiUrls sharedApiUrl];
        self.configParam = [BLConfigParam sharedConfigParam];
        self.clientId = clientId;
        self.redirectURI = redirectURI;
        self.response_type = @"token";
        self.oauthAgentApp = @"ihc://oauth/authenticate";
    }
    return self;
}

#pragma mark - notice method
- (BOOL)authorize:(NSArray *)permissions {
    NSString *scope;
    if (permissions) {
        scope = [permissions componentsJoinedByString:@","];
    }
    
    NSString *encodeRedirectURI = [self.redirectURI stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
    NSString *schemes = [NSString stringWithFormat:@"response_type=%@&client_id=%@&redirect_uri=%@", self.response_type, self.clientId, encodeRedirectURI];
    
    NSURL *ihcUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.oauthAgentApp, schemes]];
    if ([[UIApplication sharedApplication] canOpenURL:ihcUrl]) {
        // 如果已经安装智慧星客户端，就使用客户端打开链接
        // ihc://oauth?response_type=token&client_id=xxxxxxx&redirect_uri=xxxxxxx
        return [[UIApplication sharedApplication] openURL:ihcUrl];
    } else {
        // 如果未安装智慧星客户端，则使用Safari 打开
        // https://(Server)?response_type=token&client_id=xxxxxxx&redirect_uri=xxxxxxx
        NSURL *safariUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [self.apiUrls oauthLoginByTokenURL], schemes]];
        
        return [[UIApplication sharedApplication] openURL:safariUrl];
    }
}

- (void)HandleOpenURL:(NSURL *)url completionHandler:(BLOAuthBlock)completionHandler {
    if (url) {
        NSString *urlString = url.absoluteString;
        NSString *backURL = [NSString stringWithFormat:@"bl%@", self.clientId];
        if ([urlString containsString:backURL]) {  // 指定重定向URL返回
            //处理字符串 bl123456://?access_token=xxxxxxxx&expires_in=7776000
            //bl35b305aeb7abf3ef3847011556045b6e://?cancel=1
            NSArray *params = [urlString componentsSeparatedByString:@"?"];
            if (params.count > 1) {
                NSString *param = params[1];
                if ([param hasPrefix:@"cancel"]) {
                    BLOAuthBlockResult *oauthResult = [BLOAuthBlockResult new];
                    oauthResult.error = -3116;
                    oauthResult.msg = @"user cancel";
                    completionHandler(NO, oauthResult);
                }else{
                    NSArray *tokens = [param componentsSeparatedByString:@"&"];
                    if (tokens.count > 1) {
                        
                        NSInteger expirese_in = 0;
                        
                        for (NSString *token in tokens) {
                            NSString *access_token = @"access_token=";
                            if ([token containsString:access_token]) {
                                self.accessToken = [token substringFromIndex:access_token.length];
                            }
                            
                            NSString *expirese = @"expires_in=";
                            if ([token containsString:expirese]) {
                                expirese_in = [[token substringFromIndex:expirese.length] integerValue];
                                self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:expirese_in];
                            }
                        }
                        
                        BLOAuthBlockResult *oauthResult = [BLOAuthBlockResult new];
                        oauthResult.error = 0;
                        oauthResult.msg = @"success";
                        oauthResult.accessToken = self.accessToken;
                        oauthResult.expires = expirese_in;
                        completionHandler(YES, oauthResult);
                    }
                }
                
            }
        }
    }
    
    completionHandler(NO, nil);
}

- (BOOL)isSessionValid {
    NSDate *nowDate = [NSDate date];
    if ([nowDate compare:self.expirationDate] == NSOrderedDescending) {
        return NO;
    }
    
    return YES;
}

@end
