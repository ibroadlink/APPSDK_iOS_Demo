//
//  Account.m
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLAccount.h"
#import "BLAccountImpl.h"

@implementation BLAccount {
    BLAccountImpl *_mAccountImpl;
}

+ (instancetype)sharedAccount {
    static BLAccount *sharedAccount = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedAccount = [[BLAccount alloc] init];
    });
    
    return sharedAccount;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mAccountImpl = [[BLAccountImpl alloc] init];
    }
    
    return self;
}

- (void)localLoginWithUsrid:(NSString *_Nonnull)userid session:(NSString *_Nonnull)session completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler {
    
    return[_mAccountImpl localLoginWithUsrid:userid session:session completionHandler:completionHandler];
}

- (void)login:(NSString *)username password:(NSString *)password completionHandler:(void (^)(BLLoginResult *))completionHandler {
    
    LoginParam *param = [[LoginParam alloc] initLoginParam:username password:password];
    return [_mAccountImpl login:param completionHandler:completionHandler];
}

- (void)thirdAuth:(NSString *)thirdID sdkLicense:(NSString *)sdkLicense completionHandler:(void (^)(BLLoginResult *result))completionHandler {
    return [_mAccountImpl thirdAuth:thirdID sdkLicense:sdkLicense  completionHandler:completionHandler];
}

- (void)sendRegVCode:(NSString *)phone countryCode:(NSString *)countryCode completionHandler:(void (^)(BLBaseResult *))completionHandler {
    
    SendVCodeParam *param = [[SendVCodeParam alloc] initWithPhoneNumber:phone countryCode:countryCode];
    return [_mAccountImpl sendRegVCode:param completionHandler:completionHandler];
}

- (void)sendRegVCode:(NSString *)email completionHandler:(void (^)(BLBaseResult *))completionHandler {
    
    SendVCodeParam *param = [[SendVCodeParam alloc] initWithEmail:email];
    return [_mAccountImpl sendRegVCode:param completionHandler:completionHandler];
}

- (void)regist:(NSString *)username password:(NSString *)password nickname:(NSString *)nickname vcode:(NSString *)vcode sex:(BLAccountSexEnum)sex birthday:(NSString *)birthday countryCode:(NSString *)countryCode iconPath:(NSString *)iconPath completionHandler:(void (^)(BLLoginResult *))completionHandler {
    
    RegistParam *param = [[RegistParam alloc] init];
    [param setUsername:username];
    [param setPassword:password];
    [param setNickname:nickname];
    [param setCode:vcode];
    [param setSex:(sex == BL_ACCOUNT_FEMALE) ? @"female" : @"male"];
    [param setCountryCode:countryCode];
    [param setIconpath:iconPath];
    [param setBirthday:birthday];
    
    return [_mAccountImpl regist:param iconPath:iconPath completionHandler:completionHandler];
}

- (void)modifyUserGender:(BLAccountSexEnum)gender birthday:(NSString *)birthday completionHandler:(void (^)(BLBaseResult * result))completionHandler {
    NSString *genderString = (gender == BL_ACCOUNT_FEMALE) ? @"female" : @"male";
    return [_mAccountImpl modifyUserGender:genderString birthday:birthday completionHandler:completionHandler];
}

- (void)modifyUserIcon:(NSString *)iconPath completionHandler:(void (^)(BLModifyUserIconResult *))completionHandler {
    ModifyUserIconParam *param = [[ModifyUserIconParam alloc] initWithIconPath:iconPath];
    return [_mAccountImpl modifyUserIcon:param completionHandler:completionHandler];
}

- (void)modifyUserNickname:(NSString *)nickname completionHandler:(void (^)(BLBaseResult *))completionHandler {
    ModifyUserNicknameParam *param = [[ModifyUserNicknameParam alloc] initWithNickname:nickname];
    
    return [_mAccountImpl modifyUserNickname:param completionHandler:completionHandler];
}

- (void)getUserInfo:(NSArray<NSString *> *)useridArray completionHandler:(void (^)(BLGetUserInfoResult *))completionHandler {
    GetUserInfoParam *param = [[GetUserInfoParam alloc] initWithUseridArray:useridArray];
    
    return [_mAccountImpl getUserInfo:param completionHandler:completionHandler];
}

- (void)modifyPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword completionHandler:(void (^)(BLBaseResult *))completionHandler {
    ModifyPasswordParam *param = [[ModifyPasswordParam alloc] initWithNewPassword:newPassword oldPassword:oldPassword];
    
    return [_mAccountImpl modifyPassword:param completionHandler:completionHandler];
}

- (void)sendModifyVCode:(NSString *)email completionHandler:(void (^)(BLBaseResult *))completionHandler {
    SendVCodeParam *param = [[SendVCodeParam alloc] initWithEmail:email];
    
    return [_mAccountImpl sendModifyVCode:param completionHandler:completionHandler];
}

- (void)sendModifyVCode:(NSString *)phone countryCode:(NSString *)countryCode completionHandler:(void (^)(BLBaseResult *))completionHandler {
    SendVCodeParam *param = [[SendVCodeParam alloc] initWithPhoneNumber:phone countryCode:countryCode];
    
    return [_mAccountImpl sendModifyVCode:param completionHandler:completionHandler];
}

- (void)modifyPhone:(NSString *)phone countryCode:(NSString *)countryCode vcode:(NSString *)vcode password:(NSString *)password newpassword:(NSString *)newpassword completionHandler:(void (^)(BLBaseResult *))completionHandler {
    ModifyPhoneOrEmailParam *param = [[ModifyPhoneOrEmailParam alloc] initWithPhoneNumber:phone countryCode:countryCode vCode:vcode password:password newpassword:newpassword];
    
    return [_mAccountImpl modifyPhoneOrEmail:param completionHandler:completionHandler];
}

-(void)modifyEmail:(NSString *)email vcode:(NSString *)vcode password:(NSString *)password newpassword:(NSString *)newpassword completionHandler:(void (^)(BLBaseResult *))completionHandler {
    ModifyPhoneOrEmailParam *param = [[ModifyPhoneOrEmailParam alloc] initWithEmail:email vCode:vcode password:password newpassword:newpassword];
    
    return [_mAccountImpl modifyPhoneOrEmail:param completionHandler:completionHandler];
}

- (void)sendRetriveVCode:(NSString *)username completionHandler:(void (^)(BLBaseResult *))completionHandler {
    SendVCodeParam *param = [[SendVCodeParam alloc] initWithEmail:username];
    
    return [_mAccountImpl sendRetriveVCode:param completionHandler:completionHandler];
}

- (void)retrivePassword:(NSString *)username vcode:(NSString *)vcode newPassword:(NSString *)password completionHandler:(void (^)(BLLoginResult *))completionHandler {
    RetrivePasswordParam *param = [[RetrivePasswordParam alloc] initWithUsername:username countryCode:nil vCode:vcode password:password];
    
    return [_mAccountImpl retrivePassword:param completionHandler:completionHandler];
}

- (void)checkUserPassword:(NSString *)password completionHandler:(void (^)(BLBaseResult *))completionHandler {
    return [_mAccountImpl checkPassword:password completionHandler:completionHandler];
}

- (void)getUserPhoneAndEmailWithCompletionHandler:(void (^)(BLGetUserPhoneAndEmailResult *))completionHandler {
    return [_mAccountImpl getUserPhoneAndEmailWithCompletionHandler:completionHandler];
}

- (void)fastLoginWithPhoneOrEmail:(NSString *)phoneOrEmail countrycode:(NSString *)countrycode vcode:(NSString *)vcode completionHandler:(void (^)(BLLoginResult * result))completionHandler {
    return [_mAccountImpl fastLoginWithPhoneOrEmail:phoneOrEmail countrycode:countrycode vcode:vcode completionHandler:completionHandler];
}

- (void)sendFastVCode:(NSString *)phoneOrEmail countryCode:(NSString *)countryCode completionHandler:(void (^)(BLBaseResult *result))completionHandler {
    
    SendVCodeParam *param = [[SendVCodeParam alloc] initWithPhoneNumber:phoneOrEmail countryCode:countryCode];
    return [_mAccountImpl sendFastVCode:param completionHandler:completionHandler];
}

- (void)setFastLoginPassword:(NSString *)phoneOrEmail countryCode:(NSString *)countryCode vcode:(NSString *)vcode password:(NSString *)password completionHandler:(void (^)(BLBaseResult *result))completionHandler {
    
    ModifyPhoneOrEmailParam *param = [[ModifyPhoneOrEmailParam alloc] initWithPhoneNumber:phoneOrEmail countryCode:countryCode vCode:vcode password:password newpassword:nil];
    
    return [_mAccountImpl setFastLoginPassword:param completionHandler:completionHandler];
    
}

- (void)sendFastLoginPasswordVCode:(NSString *)phoneOrEmail countryCode:(NSString *)countryCode completionHandler:(void (^)(BLBaseResult *result))completionHandler {
    
    SendVCodeParam *param = [[SendVCodeParam alloc] initWithPhoneNumber:phoneOrEmail countryCode:countryCode];
    
    return [_mAccountImpl sendFastLoginPasswordVCode:param completionHandler:completionHandler];
}

- (void)oauthLoginWithThirdType:(NSString *_Nonnull)thirdType thirdOpenId:(NSString *_Nonnull)thirdOpenId accesstoken:(NSString *_Nonnull)accesstoken nickname:(NSString *_Nullable)nickname iconUrl:(NSString *_Nullable)iconUrl topsign:(NSString *_Nullable)topsign completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler{
    
    return [_mAccountImpl oauthLoginWithThirdType:thirdType thirdOpenId:thirdOpenId accesstoken:accesstoken nickname:nickname iconUrl:iconUrl topsign:topsign completionHandler:completionHandler];
}

- (void)queryIhcAccessTokenWithUserName:(NSString *_Nonnull)username password:(NSString *_Nonnull)password cliendId:(NSString *_Nonnull)cliendId redirectUri:(NSString *_Nonnull)redirectUri completionHandler:(nullable void (^)(BLOauthResult * _Nonnull result))completionHandler {
    
    return [_mAccountImpl queryIhcAccessTokenWithUserName:username password:password cliendId:cliendId redirectUri:redirectUri completionHandler:completionHandler];
}

- (void)refreshAccessToken:(NSString *_Nonnull)token clientId:(NSString *_Nonnull)clientId clientSecret:(NSString *_Nonnull)clientSecret completionHandler:(nullable void (^)(BLOauthResult * _Nonnull result))completionHandler {
    return [_mAccountImpl refreshAccessToken:token clientId:clientId clientSecret:clientSecret completionHandler:completionHandler];
}

- (void)loginWithIhcAccessToken:(NSString *_Nonnull)accesstoken completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler {
    return [_mAccountImpl loginWithIhcAccessToken:accesstoken completionHandler:completionHandler];
}

- (BOOL)isLoginExpired:(NSInteger)status {
    if (status == -1012 || status == -1009 || status == -1000 || status == 10011) {
        return YES;
    } else {
        return NO;
    }
}

- (void)queryOauthBindInfo:(nullable void (^)(BLBindInfoResult * _Nonnull result))completionHandler {
    return [_mAccountImpl queryOauthBindInfo:completionHandler];
}

- (void)bindOauthAccount:(NSString *_Nonnull)thirdType thirdID:(NSString *_Nonnull)thirdID accesstoken:(NSString *_Nonnull)accesstoken topSign:(NSString *_Nonnull)topSign completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    return [_mAccountImpl bindOauthAccount:thirdType thirdID:thirdID accesstoken:accesstoken topSign:topSign completionHandler:completionHandler];
}

- (void)unbindOauthAccount:(NSString *_Nonnull)thirdType thirdID:(NSString *_Nonnull)thirdID topSign:(NSString *_Nonnull)topSign completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler {
    return [_mAccountImpl unbindOauthAccount:thirdType thirdID:thirdID topSign:topSign completionHandler:completionHandler];
}

- (void)sendDestroyCodeWithPhoneOrEmail:(NSString *)phoneOrEmail countryCode:(NSString *)countryCode completionHandler:(void (^)(BLBaseResult * _Nonnull result))completionHandler {
    SendVCodeParam *param = [[SendVCodeParam alloc] initWithPhoneNumber:phoneOrEmail countryCode:countryCode];
    return [_mAccountImpl sendDestroyCodeWithPhoneOrEmail:param completionHandler:completionHandler];
}

- (void)destroyAccountWithPhoneOrEmail:(NSString *)phoneOrEmail countryCode:(NSString *)countryCode vcode:(NSString *)vcode completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler{
    ModifyPhoneOrEmailParam *param = [[ModifyPhoneOrEmailParam alloc] initWithPhoneNumber:phoneOrEmail countryCode:countryCode vCode:vcode password:nil newpassword:nil];
    return [_mAccountImpl destroyAccount:param completionHandler:completionHandler];
}

- (void)destroyUnBindAccountCompletionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler{
    return [_mAccountImpl destroyUnBindAccountCompletionHandler:completionHandler];
}

#pragma mark - getter
- (NSString *)loginUserid {
    return _mAccountImpl.loginUserid;
}

- (NSString *)loginSession {
    return _mAccountImpl.loginSession;
}

@end

