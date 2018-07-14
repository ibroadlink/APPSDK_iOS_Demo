//
//  AccountImpl.h
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "LoginParam.h"
#import "RegistParam.h"
#import "SendVCodeParam.h"
#import "ModifyUserIconParam.h"
#import "ModifyUserNicknameParam.h"
#import "GetUserInfoParam.h"
#import "ModifyPasswordParam.h"
#import "ModifyPhoneOrEmailParam.h"
#import "RetrivePasswordParam.h"

#import "BLGetUserInfoResult.h"
#import "BLModifyUserIconResult.h"
#import "BLLoginResult.h"
#import "BLGetUserPhoneAndEmailResult.h"
#import "BLOauthResult.h"
#import "BLBindInfoResult.h"

@interface BLAccountImpl : NSObject

@property (nonatomic, strong) NSString * _Nullable loginUserid;

@property (nonatomic, strong) NSString * _Nullable loginSession;

@property (nonatomic, assign) NSUInteger accountHttpTimeout;

- (instancetype _Nullable)initWithConfigParam:(NSString *)licenseId CompanyId:(NSString *)companyId;
/**
 *  登录帐号系统
 *
 *  @param username          用户名
 *  @param password          密码
 *  @param completionHandler 登录结果: LoginResult
 */
- (void)login:(LoginParam *_Nonnull)loginParam completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 本地登录

 @param userid 本地保存userid
 @param session 本地保存userSession
 @param completionHandler 登录结果: LoginResult
 */
- (void)localLoginWithUsrid:(NSString *_Nonnull)userid session:(NSString *_Nonnull)session completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 验证码快速登录

 @param phoneOrEmail 手机/邮箱
 @param countrycode 若是手机登录，需要填手机号国家码
 @param completionHandler 登录结果
 */
- (void)fastLoginWithPhoneOrEmail:(NSString *_Nonnull)phoneOrEmail countrycode:(NSString *_Nullable)countrycode vcode:(NSString *_Nonnull)vcode completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 Login by Oauth
 
 @param thirdType Third company name - like "facebook"
 @param thirdOpenId Open id by Oauth
 @param accesstoken Token by Oauth
 @param nickname User nickname
 @param iconUrl icon url
 @param completionHandler Login result
 */
- (void)oauthLoginWithThirdType:(NSString *_Nonnull)thirdType thirdOpenId:(NSString *_Nonnull)thirdOpenId accesstoken:(NSString *_Nonnull)accesstoken nickname:(NSString *_Nullable)nickname iconUrl:(NSString *_Nullable)iconUrl topsign:(NSString *_Nullable)topsign completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 Query accessToken from ihc
 
 @param username username
 @param password password
 @param cliendId cliendId
 @param redirectUri redirectUri
 @param completionHandler query result
 */
- (void)queryIhcAccessTokenWithUserName:(NSString *_Nonnull)username password:(NSString *_Nonnull)password cliendId:(NSString *_Nonnull)cliendId redirectUri:(NSString *_Nonnull)redirectUri completionHandler:(nullable void (^)(BLOauthResult * _Nonnull result))completionHandler;


/**
 Refresh accessToken from ihc

 @param token token
 @param clientId clientId
 @param clientSecret clientSecret
 @param completionHandler completionHandler refresh result
 */
- (void)refreshAccessToken:(NSString *_Nonnull)token clientId:(NSString *_Nonnull)clientId clientSecret:(NSString *_Nonnull)clientSecret completionHandler:(nullable void (^)(BLOauthResult * _Nonnull result))completionHandler;

/**
 Login by ihc Oauth

 @param accesstoken access token return by ihc
 @param completionHandler Login result
 */
- (void)loginWithIhcAccessToken:(NSString *_Nonnull)accesstoken completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 *  发送手机或邮箱验证码
 *
 *  @param sendVCodeParam    手机或邮箱参数
 *  @param completionHandler 发送结果
 */
- (void)sendRegVCode:(SendVCodeParam *_Nonnull)sendVCodeParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 发送快速登录验证码

 @param sendVCodeParam 手机或邮箱参数
 @param completionHandler 发送结果
 */
- (void)sendFastVCode:(SendVCodeParam *_Nonnull)sendVCodeParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  注册用户
 *
 *  @param registParam       注册用户信息
 *  @param iconPath          用户头像绝对路径，头像为本地文件时有效
 *  @param completionHandler 登录结果,注册成功即登录成功: LoginResult
 */
- (void)regist:(RegistParam *_Nonnull)registParam iconPath:(NSString *_Nullable)iconPath completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 修改用户性别和生日

 @param gender 用户性别
 @param birthday 生日
 @param completionHandler 修改结果
 */
- (void)modifyUserGender:(NSString *_Nullable)gender birthday:(NSString *_Nullable)birthday completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  修改用户头像
 *
 *  @param modifyUserIconParam 修改头像信息
 *  @param completionHandler 修改结果
 */
- (void)modifyUserIcon:(ModifyUserIconParam *_Nonnull)modifyUserIconParam completionHandler:(nullable void (^)(BLModifyUserIconResult * _Nonnull result))completionHandler;

/**
 *  修改用户昵称
 *
 *  @param modifyUserNicknameParam 昵称信息
 *  @param completionHandler       修改结果
 */
- (void)modifyUserNickname:(ModifyUserNicknameParam *_Nonnull)modifyUserNicknameParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  获取用户列表的昵称和头像
 *
 *  @param getUserInfoParam  用户列表
 *  @param completionHandler 结果
 */
- (void)getUserInfo:(GetUserInfoParam *_Nonnull)getUserInfoParam completionHandler:(nullable void (^)(BLGetUserInfoResult * _Nonnull result))completionHandler;

/**
 *  修改密码
 *
 *  @param modifyPasswordParam 密码信息
 *  @param completionHandler   修改结果
 */
- (void)modifyPassword:(ModifyPasswordParam *_Nonnull)modifyPasswordParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;


/**
 设置快速登录用户密码

 @param modifyPasswordParam 密码信息
 @param completionHandler 设置结果
 */
- (void)setFastLoginPassword:(ModifyPhoneOrEmailParam *_Nonnull)modifyPhoneOrEmailParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;


/**
 发送快速登录用户设置密码验证码

 @param sendVCodeParam 获取验证码的参数
 @param completionHandler 发送结果
 */
- (void)sendFastLoginPasswordVCode:(SendVCodeParam *_Nonnull)sendVCodeParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  发送修改手机邮箱验证码
 *
 *  @param sendVCodeParam    手机邮箱信息
 *  @param completionHandler 发送结果
 */
- (void)sendModifyVCode:(SendVCodeParam *_Nonnull)sendVCodeParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  修改手机号码或邮箱地址
 *
 *  @param modifyPhoneOrEmailParam 手机号码或邮箱地址信息
 *  @param completionHandler       修改结果
 */
- (void)modifyPhoneOrEmail:(ModifyPhoneOrEmailParam *_Nonnull)modifyPhoneOrEmailParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  发送验证码 <找回密码>
 *
 *  @param sendVcodeParam    帐号信息
 *  @param completionHandler 发送结果
 */
- (void)sendRetriveVCode:(SendVCodeParam *_Nonnull)sendVcodeParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  重置密码
 *
 *  @param retrivePasswordParam 重置信息
 *  @param completionHandler    重置结果
 */
- (void)retrivePassword:(RetrivePasswordParam *_Nonnull)retrivePasswordParam completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 *  检查密码是否有效
 *
 *  @param password          密码
 *  @param completionHandler 检查结果
 */
- (void)checkPassword:(NSString *_Nonnull)password completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  获取用户的手机号码和邮箱地址
 *
 *  @param completionHandler 获取结果
 */
- (void)getUserPhoneAndEmailWithCompletionHandler:(nullable void (^)(BLGetUserPhoneAndEmailResult * _Nonnull result))completionHandler;


/**
 根据错误码判断，是否是登录过期

 @param status 错误码
 @return 是否登录过期
 */
- (BOOL)isLoginExpired:(NSInteger)status;



/**
 查询用户第三方绑定账号

 @param completionHandler 返回查询结果
 */
- (void)queryOauthBindInfo:(nullable void (^)(BLBindInfoResult * _Nonnull result))completionHandler;

/**
 绑定第三方账号

 @param thirdType 第三方oauth 类型,如wechat|taobao|qq|facebook|weibo等
 @param thirdID 第三方id
 @param accesstoken 第三方oauth token
 @param topSign 淘宝专用
 @param completionHandler 返回绑定结果
 */
- (void)bindOauthAccount:(NSString *_Nonnull)thirdType thirdID:(NSString *_Nonnull)thirdID accesstoken:(NSString *_Nonnull)accesstoken topSign:(NSString *_Nonnull)topSign completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 解除绑定第三方账号

 @param thirdType 第三方oauth 类型,如wechat|taobao|qq|facebook|weibo等
 @param thirdID 第三方id
 @param topSign 淘宝专用
 @param completionHandler 返回结果
 */
- (void)unbindOauthAccount:(NSString *_Nonnull)thirdType thirdID:(NSString *_Nonnull)thirdID topSign:(NSString *_Nonnull)topSign completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 发送注销账号验证码
 
 @param sendVCodeParam 账号信息
 @param completionHandler 结果
 */
- (void)sendDestroyCodeWithPhoneOrEmail:(SendVCodeParam *)sendVCodeParam completionHandler:(void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 注销账号
 
 @param modifyPhoneOrEmailParam 账号信息
 @param completionHandler 结果
 */
- (void)destroyAccount:(ModifyPhoneOrEmailParam *_Nonnull)modifyPhoneOrEmailParam completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 注销未注册账号
 
 @param completionHandler 结果
 */
- (void)destroyUnBindAccountCompletionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;
@end
