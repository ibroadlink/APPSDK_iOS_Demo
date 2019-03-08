//
//  BLSNotificationService.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/7.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSNotificationService.h"
#import "BLUserDefaults.h"
#import <BLLetBase/BLLetBase.h>

@implementation BLSNotificationService

+ (BLSNotificationService *)sharedInstance {
    static BLSNotificationService *notificationService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!notificationService) {
            notificationService = [[BLSNotificationService alloc] init];
        }
    });
    
    return notificationService;
}

/**
 上报token给云端，注册推送服务。
 @param userid 用户的id
 @param touser deviceToken
 @param tousertype 推送的类型，可选四种类型"app"、"短信"、"微信"、"邮件"。
 */
- (void)registerDevice {
    NSString *userID = [[BLUserDefaults shareUserDefaults] getUserId] ?: @"";
    
    NSDictionary *bodyDic = @{
                              @"userid" : userID,
                              @"touser" : _deviceToken,
                              @"tousertype" : @"app"
                              };
    NSArray *manageInfoArray = [NSArray arrayWithObject:bodyDic];
    NSData *data = [NSJSONSerialization dataWithJSONObject:manageInfoArray
                                                       options:0
                                                         error:nil];
    
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:@"/appfront/v1/pusher/registerforremotenotify"];
    
    NSDictionary *head = [self getHeadDic];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:head data:data timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSInteger status = [result[@"status"] integerValue];
            if (status == 0) {
                [self setAllPushState:YES];
            }
        }
    }];
    
}

/**
 用户设置推送方式
 
 @param state 推送状态，BOOL型
 @param managetypeinfo 推送类型的一个列表，可以设置多个推送类型（最多四个）
 @param action 推送开关
 @param tokentype 字典类型用于保存deviceToken和推送类型的
 @param touser deviceToken
 @param tousertype 推送的类型，可选四种类型"app"、"短信"、"微信"、"邮件"。
 */
- (void)setAllPushState:(BOOL)state {
    NSString *userID = [[BLUserDefaults shareUserDefaults] getUserId] ?: @"";
    
    NSDictionary *tokentypeDic = @{
                                   @"touser" : _deviceToken ? _deviceToken:@"",
                                   @"tousertype" : @"app"
                                   };
    NSDictionary *infoDic = @{
                              @"action" : state ? @"favor":@"quitfavor",
                              @"tokentype" : tokentypeDic
                              };
    NSArray *manageInfoArray = [NSArray arrayWithObject:infoDic];
    NSDictionary *bodyDic = @{
                              @"userid" : userID,
                              @"managetypeinfo" : manageInfoArray
                              };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:bodyDic options:0 error:nil];
    
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:@"/appfront/v1/notifypush/query"];
    NSDictionary *head = [self getHeadDic];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:head data:data timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error || data == nil) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"setAllPushState %@", result);
        }
    }];
}

/**
 推送操作的通用头部
 @param userid 用户的id
 @param language 用户使用系统的语言，后台推送的时候选择语言模板要用到
 @param system 推送的平台，后台选择推送平台的时候要用到（两种类型ios和android）
 @param appid app的一个标示，后台在选择推送证书的时候要用到（一个appid对应一个证书，debug和release版本对应的证书也不一样）
 @return 返回一个字典类型
 */
- (NSDictionary *)getHeadDic {
    
    NSString *userID = [[BLUserDefaults shareUserDefaults] getUserId] ?: @"";
    NSString *loginSession = [[BLUserDefaults shareUserDefaults] getSessionId] ?: @"";
    
#ifdef DEBUG
    NSString *appId = @"cn.com.broadlink.blappsdkdemo.baihk";
#else
    NSString *appId = @"cn.com.broadlink.blappsdkdemo.baihk_release";
#endif
    
    NSDictionary *headDic = @{
                              @"userid" : userID,
                              @"loginsession" : loginSession,
                              @"appid" : appId
                              };
    return headDic;
}

@end
