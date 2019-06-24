//
//  AccountImpl.m
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLAccountImpl.h"
#import "BLAccountHttpAccessor.h"

@interface BLAccountImpl ()

@property (nonatomic, strong) BLApiUrls *apiUrls;

@property (nonatomic, strong) BLConfigParam *configParam;

@property (nonatomic, strong) BLAccountHttpAccessor *httpAccessor;

@property (nonatomic, copy, readonly) NSString *passwordEncrypt;

@end

@implementation BLAccountImpl

- (instancetype)init {
    self = [super init];
    if (self) {
        _apiUrls = [BLApiUrls sharedApiUrl];
        _configParam = [BLConfigParam sharedConfigParam];
        _httpAccessor = [[BLAccountHttpAccessor alloc] init];
        _passwordEncrypt = @"4969fj#k23#";
    }
    
    return self;
}

#pragma mark - notice method
//发送登录成功通知消息
- (void)sendLoginSuccessNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LetLoginSuccess" object:nil userInfo:[self getLoginNoticeDictionary]];
}

- (void)localLoginWithUsrid:(NSString *)userid session:(NSString *)session completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler {
    BLLoginResult *result = [[BLLoginResult alloc] init];
    [result setError:BL_APPSDK_ERR_INPUT_PARAM];
    [result setMsg:kErrorMsgInputParam];
    
    if (userid != nil && session != nil) {
        self.loginUserid = userid;
        self.loginSession = session;
        
        [self sendLoginSuccessNotification];
        
        [result setError:BL_APPSDK_SUCCESS];
        [result setMsg:kSuccessMsg];
        result.userid = userid;
        result.loginsession = session;
    }
    
    if (completionHandler != nil) {
        completionHandler(result);
    }
}

- (void)login:(LoginParam *)loginParam completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler
{
    BLLoginResult *loginResult = [[BLLoginResult alloc] init];
    
    //判断参数是否合法
    if (loginParam == nil) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:kErrorMsgInputParam];
        
        completionHandler(loginResult);
        return;
    }
    
    if (!loginParam.username || [loginParam.username isEqualToString:@""]) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"username is empty"];
        
        completionHandler(loginResult);
        return;
    }
    
    if (!loginParam.password || [loginParam.password isEqualToString:@""]) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"password is empty"];
        
        completionHandler(loginResult);
        return;
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    if ([BLCommonTools isEmail:loginParam.username]) {
        [dictionary setObject:loginParam.username forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:loginParam.username]) {
        [dictionary setObject:loginParam.username forKey:@"phone"];
    } else {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"username format error"];
        
        completionHandler(loginResult);
        return;
    }
    
    [dictionary setObject:[BLCommonTools sha1:[loginParam.password stringByAppendingString:self.passwordEncrypt]] forKey:@"password"];
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.httpAccessor generalPost:[self.apiUrls getLoginUrl] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        BLLoginResult *loginResult = [[BLLoginResult alloc] init];
        if (error) {
            [loginResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [loginResult setMsg:error.localizedDescription];
            completionHandler(loginResult);
            return;
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            [loginResult setError:BL_APPSDK_ERR_UNKNOWN];
            [loginResult setMsg:error.localizedDescription];
            completionHandler(loginResult);
            return;
        }
        
        //结果
        [loginResult BLS_modelSetWithJSON:resultDic];
        
        if ([loginResult succeed]) {
            self.loginUserid = loginResult.getUserid;
            self.loginSession = loginResult.getLoginsession;
            
            //发送登录成功通知消息
            [self sendLoginSuccessNotification];
        }
        
        completionHandler(loginResult);
    }];
    
}

- (void)thirdAuth:(NSString *)thirdID sdkLicense:(NSString *)sdkLicense completionHandler:(void (^)(BLLoginResult * _Nonnull))completionHandler{
    BLLoginResult *res = [BLLoginResult new];
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:thirdID forKey:@"thirdid"];
    [dic setObject:self.configParam.companyId  forKey:@"companyid"];
    [dic setObject:self.configParam.licenseId forKey:@"lid"];
    [dic setObject:[BLCommonTools sha1:sdkLicense] forKey:@"license"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.httpAccessor generalPost:[self.apiUrls thirdAuthUrl] head:nil dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [res setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [res setMsg:error.localizedDescription];
            return completionHandler(res);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            [res setError:BL_APPSDK_ERR_UNKNOWN];
            [res setMsg:error.localizedDescription];
            return completionHandler(res);
        }
        
        [res BLS_modelSetWithJSON:resultDic];
        
        if ([res succeed]){
            self.loginUserid = res.getUserid;
            self.loginSession = res.getLoginsession;
            
            //发送登录成功通知消息
            [self sendLoginSuccessNotification];
        }
        
        return completionHandler(res);
    }];
}

- (void)sendRegVCode:(SendVCodeParam *)sendVCodeParam completionHandler:(void (^)(BLBaseResult * _Nonnull))completionHandler
{
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (sendVCodeParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    } else {
        if ([sendVCodeParam.getPhoneNumberOrEmail isEqualToString:@""]) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"phone or email is empty"];
            
            return completionHandler(baseResult);
        }
    }
    
    if ([BLCommonTools isEmail:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"phone"];
        
        if ([sendVCodeParam.getCountryCode isEqualToString:@""]) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"countrycode is empty"];
            
            return completionHandler(baseResult);
        }
        
        [dictionary setObject:sendVCodeParam.getCountryCode forKey:@"countrycode"];
    } else {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"username format error"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getRegVCodeUrl] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_TOO_FAST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)regist:(RegistParam *)registParam iconPath:(NSString *)iconPath completionHandler:(void (^)(BLLoginResult * _Nonnull))completionHandler
{
    BLLoginResult *loginResult = [[BLLoginResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (registParam == nil) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(loginResult);
    } else {
        if ([registParam.getUsername isEqualToString:@""]) {
            [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [loginResult setMsg:@"username is empty"];
            
            return completionHandler(loginResult);
        }
        
        if ([registParam.getPassword isEqualToString:@""]) {
            [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [loginResult setMsg:@"password is empty"];
            
            return completionHandler(loginResult);
        }
        
        if ([registParam.getSex isEqualToString:@""]) {
            [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [loginResult setMsg:@"sex is empty"];
            
            return completionHandler(loginResult);
        }
        
        if ([registParam.getCode isEqualToString:@""]) {
            [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [loginResult setMsg:@"vcode is empty"];
            
            return completionHandler(loginResult);
        }
        
        if (iconPath != nil && ![iconPath isEqualToString:@""]) {
            NSFileManager *manager = [NSFileManager defaultManager];
            BOOL isDir;
            
            if (![manager fileExistsAtPath:iconPath isDirectory:&isDir]) {
                [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
                [loginResult setMsg:@"iconPath not exists"];
                
                return completionHandler(loginResult);
            }
            
            if (isDir) {
                [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
                [loginResult setMsg:@"iconPath is a directroy, invalid"];
                
                return completionHandler(loginResult);
            }
        }
    }
    
    if ([BLCommonTools isPhoneNumber:registParam.getUsername]) {
        [dictionary setObject:registParam.getUsername forKey:@"phone"];
        [dictionary setObject:@"phone" forKey:@"type"];
        
        if ([registParam.getCountryCode isEqualToString:@""]) {
            [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [loginResult setMsg:@"countrycode is empty"];
            
            return completionHandler(loginResult);
        }
        [dictionary setObject:registParam.getCountryCode forKey:@"countrycode"];
    } else if ([BLCommonTools isEmail:registParam.getUsername]) {
        [dictionary setObject:registParam.getUsername forKey:@"email"];
        [dictionary setObject:@"email" forKey:@"type"];
    } else {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"username format error"];
        
        return completionHandler(loginResult);
    }
    
    [dictionary setObject:[BLCommonTools sha1:[registParam.getPassword stringByAppendingString:self.passwordEncrypt]] forKey:@"password"];
    [dictionary setObject:registParam.getNickname forKey:@"nickname"];
    [dictionary setObject:registParam.getSex forKey:@"sex"];
    [dictionary setObject:[BLCommonTools getCurrentLanguage] forKey:@"preferlanguage"];
    [dictionary setObject:registParam.getCode forKey:@"code"];
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    
    if (registParam.getCountry && ![registParam.getCountry isEqualToString:@""]) {
        [dictionary setObject:registParam.getCountry forKey:@"country"];
    }
    
    if (registParam.getIconpath && ![registParam.getIconpath isEqualToString:@""]) {
        [dictionary setObject:registParam.getIconpath forKey:@"iconpath"];
    }
    
    if (registParam.getBirthday && ![registParam.getBirthday isEqualToString:@""]) {
        NSDictionary *comDic = @{@"birthday":registParam.getBirthday};
        [dictionary setObject:comDic forKey:@"completeinfo"];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalMultipartPost:[self.apiUrls getRegisterUrl] head:nil dataStr:jsonData filePath:iconPath timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [loginResult setError:BL_APPSDK_HTTP_TOO_FAST_ERR];
            [loginResult setMsg:error.localizedDescription];
            
            return completionHandler(loginResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [loginResult setError:BL_APPSDK_ERR_UNKNOWN];
            [loginResult setMsg:error.localizedDescription];
            
            return completionHandler(loginResult);
        }
        [loginResult BLS_modelSetWithJSON:resultDic];
        
        if ([loginResult succeed]) {
            
            self.loginUserid = loginResult.getUserid;
            self.loginSession = loginResult.getLoginsession;
            
            //发送登录成功通知消息
            [self sendLoginSuccessNotification];
        }
        
        return completionHandler(loginResult);
    }];
}

- (void)modifyUserGender:(NSString *_Nullable)gender birthday:(NSString *_Nullable)birthday completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    NSDictionary *head = @{@"userid":self.loginUserid,
                           @"loginsession":self.loginSession};
    
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithCapacity:3];
    [body setValue:self.loginUserid forKey:@"userid"];
    if (gender) {
        [body setValue:gender forKey:@"sex"];
    }
    if (birthday) {
        [body setValue:birthday forKey:@"birthday"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.httpAccessor generalPost:[self.apiUrls getModifyGenderUrl] head:head dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_TOO_FAST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);

    }];
}

- (void)modifyUserIcon:(ModifyUserIconParam *)modifyUserIconParam completionHandler:(nullable void (^)(BLModifyUserIconResult * _Nonnull))completionHandler
{
    BLModifyUserIconResult *modifyUserIconResult = [[BLModifyUserIconResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (modifyUserIconParam == nil) {
        [modifyUserIconResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [modifyUserIconResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(modifyUserIconResult);
    }
    
    if ([modifyUserIconParam.getIconPath isEqualToString:@""]) {
        [modifyUserIconResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [modifyUserIconResult setMsg:@"iconPath is nil"];
        
        return completionHandler(modifyUserIconResult);
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir;
    
    if (![manager fileExistsAtPath:modifyUserIconParam.getIconPath isDirectory:&isDir]) {
        [modifyUserIconResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [modifyUserIconResult setMsg:@"iconPath not exist"];
        
        return completionHandler(modifyUserIconResult);
    }
    
    if (isDir) {
        [modifyUserIconResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [modifyUserIconResult setMsg:@"iconPath is a directroy, invalid"];
        
        return completionHandler(modifyUserIconResult);
    }
    
    if (![self isUserLogin]) {
        [modifyUserIconResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [modifyUserIconResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(modifyUserIconResult);
    }
    
    [dictionary setObject:self.loginUserid forKey:@"userid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalMultipartPost:[self.apiUrls getModifyUserIconUrl] head:[self getLoginDictionary] dataStr:jsonData filePath:modifyUserIconParam.getIconPath timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [modifyUserIconResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [modifyUserIconResult setMsg:error.localizedDescription];
            
            return completionHandler(modifyUserIconResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [modifyUserIconResult setError:BL_APPSDK_ERR_UNKNOWN];
            [modifyUserIconResult setMsg:error.localizedDescription];
            
            return completionHandler(modifyUserIconResult);
        }
        [modifyUserIconResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(modifyUserIconResult);
    }];
}

- (void)modifyUserNickname:(ModifyUserNicknameParam *)modifyUserNicknameParam completionHandler:(void (^)(BLBaseResult * _Nonnull))completionHandler
{
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (modifyUserNicknameParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyUserNicknameParam.getNickname isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"nickname is nil"];
        
        return completionHandler(baseResult);
    }
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:modifyUserNicknameParam.getNickname forKey:@"nickname"];
    [dictionary setObject:self.loginUserid forKey:@"userid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getModifyNicknameUrl] head:[self getLoginDictionary] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)getUserInfo:(GetUserInfoParam *)getUserInfoParam completionHandler:(void (^)(BLGetUserInfoResult * _Nonnull))completionHandler
{
    BLGetUserInfoResult *getUserInfoResult = [[BLGetUserInfoResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (getUserInfoParam == nil) {
        [getUserInfoResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [getUserInfoResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(getUserInfoResult);
    }
    
    if ([getUserInfoParam.getUseridArray count] == 0) {
        [getUserInfoResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [getUserInfoResult setMsg:@"no userid found"];
        
        return completionHandler(getUserInfoResult);
    }
    
    if (![self isUserLogin]) {
        [getUserInfoResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [getUserInfoResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(getUserInfoResult);
    }
    
    [dictionary setObject:getUserInfoParam.getUseridArray forKey:@"requserid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getUserinfoUrl] head:[self getLoginDictionary] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [getUserInfoResult setError:BL_APPSDK_HTTP_TOO_FAST_ERR];
            [getUserInfoResult setMsg:error.localizedDescription];
            
            return completionHandler(getUserInfoResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [getUserInfoResult setError:BL_APPSDK_ERR_UNKNOWN];
            [getUserInfoResult setMsg:error.localizedDescription];
            
            return completionHandler(getUserInfoResult);
        }
        [getUserInfoResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(getUserInfoResult);
    }];
}

- (void)modifyPassword:(ModifyPasswordParam *)modifyPasswordParam completionHandler:(void (^)(BLBaseResult * _Nonnull))completionHandler
{
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (modifyPasswordParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyPasswordParam.getTheOldPassword isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"theOldPassword is nil"];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyPasswordParam.getTheNewPassword isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"theNewPassword is nil"];
        
        return completionHandler(baseResult);
    }
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:[BLCommonTools sha1:[modifyPasswordParam.getTheOldPassword stringByAppendingString:self.passwordEncrypt]] forKey:@"oldpassword"];
    [dictionary setObject:[BLCommonTools sha1:[modifyPasswordParam.getTheNewPassword stringByAppendingString:self.passwordEncrypt]] forKey:@"newpassword"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getModifyPasswordUrl] head:[self getLoginDictionary] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)sendModifyVCode:(SendVCodeParam *)sendVCodeParam completionHandler:(void (^)(BLBaseResult * _Nonnull))completionHandler
{
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (sendVCodeParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    }
    
    if ([sendVCodeParam.getPhoneNumberOrEmail isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"phone or email is empty"];
        
        return completionHandler(baseResult);
    }
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    if ([BLCommonTools isEmail:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"phone"];
        
        if ([sendVCodeParam.getCountryCode isEqualToString:@""]) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"countrycode is empty"];
            
            return completionHandler(baseResult);
        }
        
        [dictionary setObject:sendVCodeParam.getCountryCode forKey:@"countrycode"];
    } else {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"username format error"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getModifyVCodeUrl] head:[self getLoginDictionary] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)modifyPhoneOrEmail:(ModifyPhoneOrEmailParam *)modifyPhoneOrEmailParam completionHandler:(void (^)(BLBaseResult * _Nonnull))completionHandler
{
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (modifyPhoneOrEmailParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyPhoneOrEmailParam.getPhoneOrEmail isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"phone or email is empty"];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyPhoneOrEmailParam.getVCode isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"vCode is empty"];
        
        return completionHandler(baseResult);
    }
    
    
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    if ([BLCommonTools isEmail:modifyPhoneOrEmailParam.getPhoneOrEmail]) {
        [dictionary setObject:modifyPhoneOrEmailParam.getPhoneOrEmail forKey:@"newemail"];
    } else if ([BLCommonTools isPhoneNumber:modifyPhoneOrEmailParam.getPhoneOrEmail]) {
        [dictionary setObject:modifyPhoneOrEmailParam.getPhoneOrEmail forKey:@"newphone"];
        
        if ([modifyPhoneOrEmailParam.getCountryCode isEqualToString:@""]) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"countrycode is empty"];
            
            return completionHandler(baseResult);
        }
        
        [dictionary setObject:modifyPhoneOrEmailParam.getCountryCode forKey:@"countrycode"];
    } else {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"username format error"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    [dictionary setObject:self.loginUserid forKey:@"userid"];
    [dictionary setObject:modifyPhoneOrEmailParam.getVCode forKey:@"code"];
    if ([modifyPhoneOrEmailParam.getPassword isEqualToString:@""]) {
        NSString *password = @"";
        [dictionary setObject:[BLCommonTools sha1:[password stringByAppendingString:self.passwordEncrypt]] forKey:@"password"];
    }else {
        [dictionary setObject:[BLCommonTools sha1:[modifyPhoneOrEmailParam.getPassword stringByAppendingString:self.passwordEncrypt]] forKey:@"password"];
    }
    if (![modifyPhoneOrEmailParam.getnewPassword isEqualToString:@""]) {
        [dictionary setObject:[BLCommonTools sha1:[modifyPhoneOrEmailParam.getnewPassword stringByAppendingString:self.passwordEncrypt]] forKey:@"newpassword"];
    }
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getModifyPhoneEmailUrl] head:[self getLoginDictionary] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)sendRetriveVCode:(SendVCodeParam *)sendVcodeParam completionHandler:(void (^)(BLBaseResult * _Nonnull))completionHandler
{
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (sendVcodeParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    }
    
    if ([sendVcodeParam.getPhoneNumberOrEmail isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"phone or email is empty"];
        
        return completionHandler(baseResult);
    }
    
    if ([BLCommonTools isEmail:sendVcodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVcodeParam.getPhoneNumberOrEmail forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:sendVcodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVcodeParam.getPhoneNumberOrEmail forKey:@"phone"];
    } else {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"username format error"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getFindPasswordUrl] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)retrivePassword:(RetrivePasswordParam *)retrivePasswordParam completionHandler:(void (^)(BLLoginResult * _Nonnull))completionHandler
{
    BLLoginResult *loginResult = [[BLLoginResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    //判断参数是否合法
    if (retrivePasswordParam == nil) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(loginResult);
    }
    
    if ([retrivePasswordParam.getUsername isEqualToString:@""]) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"username is empty"];
        
        return completionHandler(loginResult);
    }
    
    if ([retrivePasswordParam.getPassword isEqualToString:@""]) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"password is empty"];
        
        return completionHandler(loginResult);
    }
    
    if ([retrivePasswordParam.getVCode isEqualToString:@""]) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"vcode is empty"];
        
        return completionHandler(loginResult);
    }
    
    if ([BLCommonTools isEmail:retrivePasswordParam.getUsername]) {
        [dictionary setObject:retrivePasswordParam.getUsername forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:retrivePasswordParam.getUsername]) {
        [dictionary setObject:retrivePasswordParam.getUsername forKey:@"phone"];
    } else {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"username format error"];
        
        return completionHandler(loginResult);
    }
    
    [dictionary setObject:[BLCommonTools sha1:[retrivePasswordParam.getPassword stringByAppendingString:self.passwordEncrypt]] forKey:@"newpassword"];
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    [dictionary setObject:retrivePasswordParam.getVCode forKey:@"code"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getRetrivePasswordurl] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [loginResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [loginResult setMsg:error.localizedDescription];
            
            return completionHandler(loginResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [loginResult setError:BL_APPSDK_ERR_UNKNOWN];
            [loginResult setMsg:error.localizedDescription];
            
            return completionHandler(loginResult);
        }
        [loginResult BLS_modelSetWithJSON:resultDic];
        
        if ([loginResult succeed]) {
            
            self.loginUserid = loginResult.getUserid;
            self.loginSession = loginResult.getLoginsession;
            
            //发送登录成功通知消息
            [self sendLoginSuccessNotification];
        }
        
        return completionHandler(loginResult);
    }];
}

- (void)checkPassword:(NSString *)password completionHandler:(void (^)(BLBaseResult * _Nonnull))completionHandler
{
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    if (password == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"password is nil"];
        
        return completionHandler(baseResult);
    }
    
    if ([password isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"password is empty"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.loginUserid forKey:@"userid"];
    [dictionary setObject:self.loginSession forKey:@"loginsession"];
    [dictionary setObject:[BLCommonTools sha1:[password stringByAppendingString:self.passwordEncrypt]] forKey:@"password"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getCheckUserPasswordUrl] head:nil dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)getUserPhoneAndEmailWithCompletionHandler:(void (^)(BLGetUserPhoneAndEmailResult * _Nonnull))completionHandler
{
    BLGetUserPhoneAndEmailResult *getUserPhoneAndEmailResult = [[BLGetUserPhoneAndEmailResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (![self isUserLogin]) {
        [getUserPhoneAndEmailResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [getUserPhoneAndEmailResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(getUserPhoneAndEmailResult);
    }
    
    [dictionary setObject:self.loginUserid forKey:@"userid"];
    [dictionary setObject:self.loginSession forKey:@"loginsession"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls getUserPhoneEmailUrl] head:nil dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [getUserPhoneAndEmailResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [getUserPhoneAndEmailResult setMsg:error.localizedDescription];
            
            return completionHandler(getUserPhoneAndEmailResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [getUserPhoneAndEmailResult setError:BL_APPSDK_ERR_UNKNOWN];
            [getUserPhoneAndEmailResult setMsg:error.localizedDescription];
            
            return completionHandler(getUserPhoneAndEmailResult);
        }
        [getUserPhoneAndEmailResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(getUserPhoneAndEmailResult);
    }];
}

- (void)fastLoginWithPhoneOrEmail:(NSString *_Nonnull)phoneOrEmail countrycode:(NSString *_Nullable)countrycode vcode:(NSString *_Nonnull)vcode completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler {
    
    BLLoginResult *loginResult = [[BLLoginResult alloc] init];
    
    //判断参数是否合法
    if (phoneOrEmail == nil) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"phone or email is empty"];
        
        completionHandler(loginResult);
        return;
    }
    
    if (vcode == nil) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"vcode is empty"];
        
        completionHandler(loginResult);
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    if ([BLCommonTools isEmail:phoneOrEmail]) {
        [dictionary setObject:phoneOrEmail forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:phoneOrEmail]) {
        [dictionary setObject:phoneOrEmail forKey:@"phone"];

        if (countrycode == nil) {
            [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [loginResult setMsg:@"countrycode is empty"];
            
            completionHandler(loginResult);
            return;
        }
        
        [dictionary setObject:countrycode forKey:@"countrycode"];
    } else {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:@"username format error"];
        
        completionHandler(loginResult);
        return;
    }
    [dictionary setObject:vcode forKey:@"code"];
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.httpAccessor generalPost:[self.apiUrls fastLoginUrl] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        BLLoginResult *loginResult = [[BLLoginResult alloc] init];
        if (error) {
            [loginResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [loginResult setMsg:error.localizedDescription];
            completionHandler(loginResult);
            return;
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            [loginResult setError:BL_APPSDK_ERR_UNKNOWN];
            [loginResult setMsg:error.localizedDescription];
            completionHandler(loginResult);
            return;
        }
        
        //结果
        [loginResult BLS_modelSetWithJSON:resultDic];

        if ([loginResult succeed]) {
            
            if ([resultDic valueForKey:@"flag"]) {
                loginResult.flag = [[resultDic valueForKey:@"flag"] integerValue];
            }
            
            if ([resultDic valueForKey:@"pwdflag"]) {
                loginResult.pwdflag = [[resultDic valueForKey:@"pwdflag"] integerValue];
            }
            
            self.loginUserid = loginResult.getUserid;
            self.loginSession = loginResult.getLoginsession;
            
            //发送登录成功通知消息
            [self sendLoginSuccessNotification];
        }
        
        completionHandler(loginResult);
    }];
}


- (void)sendFastVCode:(SendVCodeParam *_Nonnull)sendVCodeParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (sendVCodeParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    } else {
        if ([sendVCodeParam.getPhoneNumberOrEmail isEqualToString:@""]) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"phone or email is empty"];
            
            return completionHandler(baseResult);
        }
    }
    
    if ([BLCommonTools isEmail:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"phone"];
        
        NSString *countrycode = sendVCodeParam.getCountryCode;
        if (countrycode == nil) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"countrycode is empty"];
            
            completionHandler(baseResult);
            return;
        }
        
        [dictionary setObject:countrycode forKey:@"countrycode"];
    } else {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"username format error"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls fastLoginVCodeUrl] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];

    
}

- (void)setFastLoginPassword:(ModifyPhoneOrEmailParam *_Nonnull)modifyPhoneOrEmailParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (modifyPhoneOrEmailParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyPhoneOrEmailParam.getPhoneOrEmail isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"phone or email is empty"];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyPhoneOrEmailParam.getVCode isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"vCode is empty"];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyPhoneOrEmailParam.getPassword isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"password is empty"];
        
        return completionHandler(baseResult);
    }
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    if ([BLCommonTools isEmail:modifyPhoneOrEmailParam.getPhoneOrEmail]) {
        [dictionary setObject:modifyPhoneOrEmailParam.getPhoneOrEmail forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:modifyPhoneOrEmailParam.getPhoneOrEmail]) {
        [dictionary setObject:modifyPhoneOrEmailParam.getPhoneOrEmail forKey:@"phone"];
        
        NSString *countrycode = modifyPhoneOrEmailParam.getCountryCode;
        if (countrycode == nil) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"countrycode is empty"];
            
            completionHandler(baseResult);
            return;
        }
        
        [dictionary setObject:countrycode forKey:@"countrycode"];
    } else {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"username format error"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    [dictionary setObject:self.loginUserid forKey:@"userid"];
    [dictionary setObject:modifyPhoneOrEmailParam.getVCode forKey:@"code"];
    [dictionary setObject:[BLCommonTools sha1:[modifyPhoneOrEmailParam.getPassword stringByAppendingString:self.passwordEncrypt]] forKey:@"password"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls fastLoginModifyPasswordUrl] head:[self getLoginDictionary] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)sendFastLoginPasswordVCode:(SendVCodeParam *_Nonnull)sendVCodeParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (sendVCodeParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    }
    
    if ([sendVCodeParam.getPhoneNumberOrEmail isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"phone or email is empty"];
        
        return completionHandler(baseResult);
    }
    
    if ([BLCommonTools isEmail:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"phone"];
        
        NSString *countrycode = sendVCodeParam.getCountryCode;
        if (countrycode == nil) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"countrycode is empty"];
            
            completionHandler(baseResult);
            return;
        }
        
        [dictionary setObject:countrycode forKey:@"countrycode"];
    } else {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"username format error"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls fastLoginModifyVCodeUrl] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];

}

- (void)oauthLoginWithThirdType:(NSString *_Nonnull)thirdType thirdOpenId:(NSString *_Nonnull)thirdOpenId accesstoken:(NSString *_Nonnull)accesstoken nickname:(NSString *_Nullable)nickname iconUrl:(NSString *_Nullable)iconUrl topsign:(NSString *_Nullable)topsign completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler {

    BLLoginResult *loginResult = [[BLLoginResult alloc] init];
    //判断参数是否合法
    if (thirdType == nil || thirdOpenId == nil || accesstoken == nil) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:kErrorMsgInputParam];
        
        completionHandler(loginResult);
        return;
    }
    
    NSString *companyId = self.configParam.companyId;
    NSDictionary *dictionary = @{@"companyid" : companyId,
                                 @"lid" : self.configParam.licenseId,
                                 @"thirdtype" : thirdType,
                                 @"id" : thirdOpenId,
                                 @"accesstoken" : accesstoken
                                 };
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    if (nickname) {
        [mutableDic setObject:nickname forKey:@"nickname"];
    }
    if (iconUrl) {
        [mutableDic setObject:iconUrl forKey:@"pic"];
    }
    if (topsign) {
        [mutableDic setObject:topsign forKey:@"topsign"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:mutableDic options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.httpAccessor generalPost:[self.apiUrls oauthLoginUrl] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        BLLoginResult *loginResult = [[BLLoginResult alloc] init];
        if (error) {
            [loginResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [loginResult setMsg:error.localizedDescription];
            completionHandler(loginResult);
            return;
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            [loginResult setError:BL_APPSDK_ERR_UNKNOWN];
            [loginResult setMsg:error.localizedDescription];
            completionHandler(loginResult);
            return;
        }
        
        //结果
        [loginResult BLS_modelSetWithJSON:resultDic];
        
        if ([loginResult succeed]) {
            
            if ([resultDic valueForKey:@"flag"]) {
                loginResult.flag = [[resultDic valueForKey:@"flag"] integerValue];
            }
            
            if ([resultDic valueForKey:@"pwdflag"]) {
                loginResult.pwdflag = [[resultDic valueForKey:@"pwdflag"] integerValue];
            }
            
            self.loginUserid = loginResult.getUserid;
            self.loginSession = loginResult.getLoginsession;
            
            //发送登录成功通知消息
            [self sendLoginSuccessNotification];
        }
        
        completionHandler(loginResult);
    }];

}

- (void)queryIhcAccessTokenWithUserName:(NSString *_Nonnull)username password:(NSString *_Nonnull)password cliendId:(NSString *_Nonnull)cliendId redirectUri:(NSString *_Nonnull)redirectUri completionHandler:(nullable void (^)(BLOauthResult * _Nonnull result))completionHandler {
    
    //判断参数是否合法
    if (username == nil || password == nil || cliendId == nil || redirectUri == nil) {
        BLOauthResult *result = [[BLOauthResult alloc] init];

        [result setError:BL_APPSDK_ERR_INPUT_PARAM];
        [result setMsg:kErrorMsgInputParam];
        
        completionHandler(result);
    }
    
    BLBaseHttpAccessor *baseHttpAccessor = [BLBaseHttpAccessor new];
    NSString *url = [NSString stringWithFormat:@"%@?response_type=token&client_id=%@&redirect_uri=%@", [[BLApiUrls sharedApiUrl] oauthLoginInfoURL], cliendId, redirectUri];
    
    NSDictionary *dic = @{
                          @"phone" : username,
                          @"password" : password
                          };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [baseHttpAccessor post:url head:nil data:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        BLOauthResult *result = [[BLOauthResult alloc] init];
        if (error) {
            [result setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [result setMsg:error.localizedDescription];
            completionHandler(result);
            return;
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        //结果
        [result BLS_modelSetWithJSON:resultDic];
        
        completionHandler(result);
    }];
}

- (void)refreshAccessToken:(NSString *_Nonnull)token clientId:(NSString *_Nonnull)clientId clientSecret:(NSString *_Nonnull)clientSecret completionHandler:(nullable void (^)(BLOauthResult * _Nonnull result))completionHandler{
    //判断参数是否合法
    if (token == nil || clientId == nil || clientSecret == nil) {
        BLOauthResult *result = [[BLOauthResult alloc] init];
        
        [result setError:BL_APPSDK_ERR_INPUT_PARAM];
        [result setMsg:kErrorMsgInputParam];
        
        completionHandler(result);
    }
    
    BLBaseHttpAccessor *baseHttpAccessor = [BLBaseHttpAccessor new];
    NSString *url = [NSString stringWithFormat:@"%@?grant_type=refresh_token&client_id=%@&client_secret=%@&refresh_token=%@", [[BLApiUrls sharedApiUrl] oauthTokenURL], clientId, clientSecret, token];
    
    NSDictionary *dic = @{
                          };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [baseHttpAccessor post:url head:nil data:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        BLOauthResult *result = [[BLOauthResult alloc] init];
        if (error) {
            [result setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [result setMsg:error.localizedDescription];
            completionHandler(result);
            return;
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        //结果
        [result BLS_modelSetWithJSON:resultDic];
        
        completionHandler(result);
    }];
    
}

- (void)loginWithIhcAccessToken:(NSString *_Nonnull)accesstoken completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler {
    BLLoginResult *loginResult = [[BLLoginResult alloc] init];
    //判断参数是否合法
    if (accesstoken == nil) {
        [loginResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [loginResult setMsg:kErrorMsgInputParam];
        
        completionHandler(loginResult);
        return;
    }
    
    BLBaseHttpAccessor *baseHttpAccessor = [BLBaseHttpAccessor new];
    NSString *url = [NSString stringWithFormat:@"%@?access_token=%@", [[BLApiUrls sharedApiUrl] oauthLoginDataURL], accesstoken];
    [baseHttpAccessor get:url head:nil timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        BLLoginResult *loginResult = [[BLLoginResult alloc] init];
        if (error) {
            [loginResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [loginResult setMsg:error.localizedDescription];
            completionHandler(loginResult);
            return;
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            [loginResult setError:BL_APPSDK_ERR_UNKNOWN];
            [loginResult setMsg:error.localizedDescription];
            completionHandler(loginResult);
            return;
        }
        
        //结果
        [loginResult BLS_modelSetWithJSON:resultDic];
        
        if ([loginResult succeed]) {
            
            if ([resultDic valueForKey:@"flag"]) {
                loginResult.flag = [[resultDic valueForKey:@"flag"] integerValue];
            }
            
            if ([resultDic valueForKey:@"pwdflag"]) {
                loginResult.pwdflag = [[resultDic valueForKey:@"pwdflag"] integerValue];
            }
            
            self.loginUserid = loginResult.getUserid;
            self.loginSession = loginResult.getLoginsession;
            
            //发送登录成功通知消息
            [self sendLoginSuccessNotification];
        }
        
        completionHandler(loginResult);
    }];
}

#pragma mark -- Private method

- (BOOL)isUserLogin {
    if (self.loginUserid && self.loginSession) {
        return YES;
    }
    
    return NO;
}

- (NSDictionary *)getLoginNoticeDictionary {
    if (![self isUserLogin]) {
        return nil;
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.loginUserid, @"loginUserid",
            self.loginSession, @"loginSession",
            nil];
}

- (NSDictionary *)getLoginDictionary {
    if (![self isUserLogin]) {
        return nil;
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:self.loginUserid, @"USERID", self.loginSession, @"LOGINSESSION", nil];
}

- (BOOL)isLoginExpired:(NSInteger)status {
    if (status == -1012 || status == -1009 || status == -1000 || status == 10011) {
        return YES;
    } else {
        return NO;
    }
}

- (void)queryOauthBindInfo:(nullable void (^)(BLBindInfoResult * _Nonnull result))completionHandler{
    BLBindInfoResult *bindInfoResult = [[BLBindInfoResult alloc] init];
    
    if (![self isUserLogin]) {
        [bindInfoResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [bindInfoResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(bindInfoResult);
    }
    
    NSDictionary *head = @{
                           @"userid": self.loginUserid,
                           @"loginsession":self.loginSession
                           };
    [self.httpAccessor get:[self.apiUrls queryBindInfoUrl] head:head timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [bindInfoResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [bindInfoResult setMsg:error.localizedDescription];
            
            return completionHandler(bindInfoResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [bindInfoResult setError:BL_APPSDK_ERR_UNKNOWN];
            [bindInfoResult setMsg:error.localizedDescription];
            
            return completionHandler(bindInfoResult);
        }
        [bindInfoResult BLS_modelSetWithJSON:resultDic];
        
        NSMutableArray *bindinfolist = [NSMutableArray arrayWithCapacity:0];
        NSArray *bindinfos = [resultDic valueForKey:@"bindinfos"];
        
        if (![BLCommonTools isEmptyArray:bindinfos]) {
            for (NSDictionary *bindinfoDic in bindinfos) {
                BLBindinfo *bindinfo = [[BLBindinfo alloc]init];
                bindinfo.thirdtype = bindinfoDic[@"thirdtype"];
                bindinfo.thirdid = bindinfoDic[@"thirdid"];
                [bindinfolist addObject:bindinfo];
            }
            bindInfoResult.bindinfos = bindinfolist;
        }
        
        
        return completionHandler(bindInfoResult);
    }];
}

- (void)bindOauthAccount:(NSString *_Nonnull)thirdType thirdID:(NSString *_Nonnull)thirdID accesstoken:(NSString *_Nonnull)accesstoken topSign:(NSString *_Nonnull)topSign completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    NSDictionary *head = @{
                           @"userid": self.loginUserid,
                           @"loginsession":self.loginSession
                           };
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (accesstoken) {
        [dictionary setObject:accesstoken forKey:@"accesstoken"];
    }
    if (thirdID) {
        [dictionary setObject:thirdID forKey:@"id"];
    }
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    if (thirdType) {
        [dictionary setObject:thirdType forKey:@"thirdtype"];
    }
    if (topSign) {
        [dictionary setObject:topSign forKey:@"topSign"];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.httpAccessor generalPost:[self.apiUrls bindThirdAccount] head:head dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)unbindOauthAccount:(NSString *_Nonnull)thirdType thirdID:(NSString *_Nonnull)thirdID topSign:(NSString *_Nonnull)topSign completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    NSDictionary *head = @{
                           @"userid": self.loginUserid,
                           @"loginsession":self.loginSession
                           };
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (thirdID) {
        [dictionary setObject:thirdID forKey:@"id"];
    }
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    if (thirdType) {
        [dictionary setObject:thirdType forKey:@"thirdtype"];
    }
    if (topSign) {
        [dictionary setObject:topSign forKey:@"topSign"];
    }
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.httpAccessor generalPost:[self.apiUrls unbindThirdAccount] head:head dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)sendDestroyCodeWithPhoneOrEmail:(SendVCodeParam *)sendVCodeParam completionHandler:(void (^)(BLBaseResult * _Nonnull result))completionHandler {
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (sendVCodeParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    } else {
        if ([sendVCodeParam.getPhoneNumberOrEmail isEqualToString:@""]) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"phone or email is empty"];
            
            return completionHandler(baseResult);
        }
    }
    
    if ([BLCommonTools isEmail:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:sendVCodeParam.getPhoneNumberOrEmail]) {
        [dictionary setObject:sendVCodeParam.getPhoneNumberOrEmail forKey:@"phone"];
        
        NSString *countrycode = sendVCodeParam.getCountryCode;
        if (countrycode == nil) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"countrycode is empty"];
            
            completionHandler(baseResult);
            return;
        }
        
        [dictionary setObject:countrycode forKey:@"countrycode"];
    } else {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"username format error"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls destroyVCodeUrl] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
    
}

- (void)destroyAccount:(ModifyPhoneOrEmailParam *_Nonnull)modifyPhoneOrEmailParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (modifyPhoneOrEmailParam == nil) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:kErrorMsgInputParam];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyPhoneOrEmailParam.getPhoneOrEmail isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"phone or email is empty"];
        
        return completionHandler(baseResult);
    }
    
    if ([modifyPhoneOrEmailParam.getVCode isEqualToString:@""]) {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"vCode is empty"];
        
        return completionHandler(baseResult);
    }
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    if ([BLCommonTools isEmail:modifyPhoneOrEmailParam.getPhoneOrEmail]) {
        [dictionary setObject:modifyPhoneOrEmailParam.getPhoneOrEmail forKey:@"email"];
    } else if ([BLCommonTools isPhoneNumber:modifyPhoneOrEmailParam.getPhoneOrEmail]) {
        [dictionary setObject:modifyPhoneOrEmailParam.getPhoneOrEmail forKey:@"phone"];
        
        NSString *countrycode = modifyPhoneOrEmailParam.getCountryCode;
        if (countrycode == nil) {
            [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
            [baseResult setMsg:@"countrycode is empty"];
            
            completionHandler(baseResult);
            return;
        }
        
        [dictionary setObject:countrycode forKey:@"countrycode"];
    } else {
        [baseResult setError:BL_APPSDK_ERR_INPUT_PARAM];
        [baseResult setMsg:@"username format error"];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    [dictionary setObject:self.loginUserid forKey:@"userid"];
    [dictionary setObject:modifyPhoneOrEmailParam.getVCode forKey:@"code"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls destroyAccountUrl] head:[self getLoginDictionary] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

- (void)destroyUnBindAccountCompletionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    BLBaseResult *baseResult = [[BLBaseResult alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (![self isUserLogin]) {
        [baseResult setError:BL_APPSDK_ERR_NOT_LOGIN];
        [baseResult setMsg:kErrorMsgNotLogin];
        
        return completionHandler(baseResult);
    }
    
    [dictionary setObject:self.configParam.companyId forKey:@"companyid"];
    [dictionary setObject:self.configParam.licenseId forKey:@"lid"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.httpAccessor generalPost:[self.apiUrls destroyUnBindAccountUrl] head:[self getLoginDictionary] dataStr:jsonData timeout:self.configParam.httpTimeout completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [baseResult setError:BL_APPSDK_HTTP_REQUEST_ERR];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            [baseResult setError:BL_APPSDK_ERR_UNKNOWN];
            [baseResult setMsg:error.localizedDescription];
            
            return completionHandler(baseResult);
        }
        
        [baseResult BLS_modelSetWithJSON:resultDic];
        
        return completionHandler(baseResult);
    }];
}

@end
