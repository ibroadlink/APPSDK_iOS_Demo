//
//  BLSNotificationService.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/7.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSNotificationService.h"
#import "BLUserDefaults.h"




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
    [self registerDeviceCompletionHandler:^(NSString * _Nonnull result) {}];
}

- (void)registerDeviceCompletionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler {
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
            NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:0];
            [result setObject:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil] forKey:@"Return"];
            NSInteger status = [result[@"status"] integerValue];
            if (status == 0) {
                [self setAllPushState:YES];
            }
            [result setObject:self.deviceToken forKey:@"Token"];
            completionHandler([BLCommonTools serializeMessage:result]);
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
    [self setAllPushState:state completionHandler:^(NSString * _Nonnull result) {}];
}

- (void)setAllPushState:(BOOL)state completionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler {
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
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:0];
        [result setObject:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil] forKey:@"Return"];
        [result setObject:@(state) forKey:@"Set"];
        completionHandler([BLCommonTools serializeMessage:result]);
        NSLog(@"setAllPushState %@", result);
    }];
}


/**
 用户退出通知
 */
- (void)userLogoutCompletionHandler:(nullable void (^)(NSString * _Nonnull result))completionHandler {
    NSDictionary *bodyDic = @{
                              @"touser" : _deviceToken ? _deviceToken:@"",
                              @"accountlabel" : @1
                              };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:bodyDic options:0 error:nil];
    
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:@"/ec4/v1/pusher/signoutaccount"];
    NSDictionary *head = [self getHeadDic];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:head data:data timeout:3000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:0];
        [result setObject:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil] forKey:@"Return"];
        completionHandler([BLCommonTools serializeMessage:result]);
    }];
}


/**
 模板查询

 @param category 分类
 @param completionHandler
 */
- (void)queryCategory:(NSArray *)category TemplateWithCompletionHandler:(nullable void (^)(BLTemplate * _Nonnull template))completionHandler {
    NSArray *categoryArray;
    if (category) {
        NSArray *tempArray = [[category firstObject] componentsSeparatedByString:@"."];
        categoryArray = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%@.%@", [tempArray firstObject], [tempArray lastObject]], nil];
    }
    NSDictionary *bodyDic = @{
                              @"category" : categoryArray?:@[],
                              @"companyid" :[BLConfigParam sharedConfigParam].licenseId,
                              @"pagestart" : @1,
                              @"pagesize" : @100
                              };
    NSData *data = [NSJSONSerialization dataWithJSONObject:bodyDic options:0 error:nil];
    
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:@"/appfront/v1/tempalte/query"];
    NSDictionary *head = [self getHeadDic];
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:head data:data timeout:60000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        BLTemplate *template = [BLTemplate BLS_modelWithJSON:data];
        completionHandler(template);
    }];
}


/**
 联动新增，模板实例化

 @param linkage linkage description
 @param module module description
 @param deviceRoom deviceRoom description
 @param block block description

 */
- (void)addLinkageWithTemplate:(BLTemplateElement *)template
                   module:(NSDictionary *)module
                 CompletionHandler:(void (^)(BLBaseResult *result))completionHandler {
    __block BLLinkage *info = [[BLLinkage alloc] init];
    info.familyid = @"016b134aaacecae761d4e621a40ea1d9";
    info.ruletype = 1;
    info.rulename = @"RuleEcho";
    info.enable = 1;
    
    info.locationinfo = @"";
    info.moduleid = @[module[@"moduleid"]];
    info.subscribe = @[];
    info.linkEnable = true;
    
    BLLinkagedevices *linkageDevices = [[BLLinkagedevices alloc]init];
    NSMutableArray *actionArray = [[NSMutableArray alloc] init];
    for (BLAction *action in template.action) {
        NSDictionary *contentDic = @{@"devname" : module[@"name"]?:@""};
        NSString *contentStr = [BLCommonTools serializeMessage:contentDic];
        action.ios.content = [self base64EncodeString:contentStr];
        action.gcm.content = [self base64EncodeString:contentStr];
        action.alicloud.content = [self base64EncodeString:contentStr];
        action.name = @"";
        action.alicloud.did = module[@"did"];
        action.alicloud.enable = info.enable;
        action.gcm.did = module[@"did"];
        action.gcm.enable = info.enable;
        action.ios.did = module[@"did"];
        action.ios.enable = info.enable;
        [actionArray addObject:[action BLS_modelToJSONObject]];
    }
    NSDictionary *actionDic = @{@"action" : actionArray};
    NSString *externStr = [BLCommonTools serializeMessage:actionDic]?:@"";
    linkageDevices.did = module[@"did"];
    linkageDevices.linkagedevicesExtern = [self base64EncodeString:externStr];
    linkageDevices.linkagetype = @"notify";
    
   
    info.linkagedevices = linkageDevices;
    info.source = [NSString stringWithFormat:@"notify_%@",template.templateid];

    NSMutableDictionary *characteristicinfo = [NSMutableDictionary dictionaryWithCapacity:0];
    [characteristicinfo setObject:[template.events BLS_modelToJSONObject] forKey:@"events"];
    [characteristicinfo setObject:[template.conditionsinfo BLS_modelToJSONObject] forKey:@"conditionsinfo"];
    info.characteristicinfo = [BLCommonTools serializeMessage:characteristicinfo];
    NSDictionary *bodyDic = [info BLS_modelToJSONObject];
    NSData *data = [NSJSONSerialization dataWithJSONObject:bodyDic options:0 error:nil];

    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:@"/appfront/v2/linkage/add"];
    NSDictionary *head = [self getHeadDic];

    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    NSLog(@"bodyDic:%@",bodyDic);
    [httpAccessor post:url head:head data:data timeout:60000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
        completionHandler(result);
    }];
}


/**
 联动查询

 @param completionHandler completionHandler description
 */
- (void)queryLinkageInfoWithCompletionHandler:(void (^)(BLLinkageTemplate *linkageTemplate))completionHandler{
    NSDictionary *bodyDic = @{};
    NSData *data = [NSJSONSerialization dataWithJSONObject:bodyDic options:0 error:nil];
    
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:@"/appfront/v2/linkage/query"];
    NSDictionary *head = [self getHeadDic];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:head data:data timeout:60000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        BLLinkageTemplate *linkageTemplate = [BLLinkageTemplate BLS_modelWithJSON:data];
        completionHandler(linkageTemplate);
    }];
}

- (void)deleteLinkageInfoWithRuleid:(NSString *)ruleid CompletionHandler:(void (^)(BLBaseResult *result))completionHandler{
    NSDictionary *bodyDic = @{
                              @"ruleid":ruleid
                              };
    NSData *data = [NSJSONSerialization dataWithJSONObject:bodyDic options:0 error:nil];
    
    NSString *url = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:@"/appfront/v2/linkage/delete"];
    NSDictionary *head = [self getHeadDic];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    [httpAccessor post:url head:head data:data timeout:60000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        BLBaseResult *result = [BLBaseResult BLS_modelWithJSON:data];
        completionHandler(result);
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
    NSString *appId = @"cn.com.broadlink.blappsdkdemo";
#else
    NSString *appId = @"cn.com.broadlink.blappsdkdemo.baihk_release";
#endif
    
    NSDictionary *headDic = @{
                              @"userid" : userID,
                              @"loginsession" : loginSession,
                              @"licenseid": [BLConfigParam sharedConfigParam].licenseId,
                              @"appid" : appId,
                              @"familyid": @"016b134aaacecae761d4e621a40ea1d9",
                              @"testuser":@"false"
                              };
    return headDic;
}

-(NSString *)base64EncodeString:(NSString *)string{
    //1、先转换成二进制数据
    NSData *data =[string dataUsingEncoding:NSUTF8StringEncoding];
    //2、对二进制数据进行base64编码，完成后返回字符串
    return [data base64EncodedStringWithOptions:0];
}

-(NSString *)base64DecodeString:(NSString *)string{
    //注意：该字符串是base64编码后的字符串
    //1、转换为二进制数据（完成了解码的过程）
    NSData *data=[[NSData alloc]initWithBase64EncodedString:string options:0];
    //2、把二进制数据转换成字符串
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end
