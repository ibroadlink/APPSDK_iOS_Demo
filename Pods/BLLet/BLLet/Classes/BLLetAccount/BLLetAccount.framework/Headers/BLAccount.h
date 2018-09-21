//
//  Account.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BLLoginResult.h"
#import "BLOauthResult.h"
#import "BLGetUserInfoResult.h"
#import "BLModifyUserIconResult.h"
#import "BLGetUserPhoneAndEmailResult.h"
#import "BLBindInfoResult.h"

@interface BLAccount : NSObject

/** Obtain loginUserid from Login result */
@property (nonatomic, strong) NSString * _Nullable loginUserid;
/** Obtain loginSession from Login result */
@property (nonatomic, strong) NSString * _Nullable loginSession;
/** Account Http timeout, default 30000ms */
@property (nonatomic, assign, getter=getAccountHttpTimeout) NSUInteger accountHttpTimeout;

/**
 *  Get Account Instance Object With Config Param
 *  This method can only be used after "sharedAccountWithlicenseId:" .
 *
 *  @return Account Instance Object
 */
+ (instancetype _Nullable)sharedAccount;
/**
 *  Get Account Instance Object With Config Param
 *
 *  @return Account Instance Object
 */
+ (instancetype _Nullable)sharedAccountWithlicenseId:(NSString *)licenseId CompanyId:(NSString *)companyId;
/**
 *  Login with username and password
 *
 *  @param username             Username
 *  @param password             Password
 *  @param completionHandler    Callback with login result
 */
- (void)login:(NSString *_Nonnull)username password:(NSString *_Nonnull)password completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 Local login with local stored userid and loginsession
 
 @param userid              Userid
 @param session             Session
 @param completionHandler   Callback with login result
 */
- (void)localLoginWithUsrid:(NSString *_Nonnull)userid session:(NSString *_Nonnull)session completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 Login with Verification code
 
 @param phoneOrEmail        Verification code send to phone or email
 @param countrycode         Phone country code. if Verification code send to email, this can be nil. (eg. 0086)
 @param vcode               Verification code
 @param completionHandler   Callback with login result
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
 Login With third party id.
 
 @param thirdID             Uniquely id in third party
 @param completionHandler   Callback with login result
 */
- (void)thirdAuth:(NSString* _Nonnull)thirdID sdkLicense:(NSString *)sdkLicense completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

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
 Send verification code to phone or email for fastLogin
 
 @param phoneOrEmail        Phone or email
 @param countryCode         Phone country code. if Verification code send to email, this can be nil. (eg. 0086)
 @param completionHandler   Callback with send result
 */
- (void)sendFastVCode:(NSString * _Nonnull)phoneOrEmail countryCode:(NSString * _Nullable)countryCode completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 Send verification code to phone for register
 
 @param phone               Phone
 @param countryCode         Phone country code. (eg. 0086)
 @param completionHandler   Callback with send result
 */
- (void)sendRegVCode:(NSString * _Nonnull)phone countryCode:(NSString * _Nonnull)countryCode completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 Send verification code to email for register
 
 @param email               Email
 @param completionHandler   Callback with send result
 */
- (void)sendRegVCode:(NSString * _Nonnull)email completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  Register Account by phone or email
 *
 *  @param username          Phone or email
 *  @param password          Password
 *  @param nickname          Nickname
 *  @param vcode             Verification code
 *  @param sex               User gender
 *  @param birthday          User birthday, this can be nil.
 *  @param countryCode       Phone country code. if Verification code send to email, this can be nil. (eg. 0086)
 *  @param iconPath          User icon path, this can be nil.
 *  @param completionHandler Callback with register result
 */
- (void)regist:(NSString *_Nonnull)username password:(NSString *_Nonnull)password nickname:(NSString *_Nonnull)nickname vcode:(NSString *_Nonnull)vcode sex:(BLAccountSexEnum)sex birthday:(NSString *_Nullable)birthday countryCode:(NSString *_Nullable)countryCode iconPath:(NSString *_Nullable)iconPath completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 Modify user gender and birthday
 
 @param gender              New user gender
 @param birthday            New user birthday, this can be nil.
 @param completionHandler   Callback with modify result
 */
- (void)modifyUserGender:(BLAccountSexEnum)gender birthday:(NSString *_Nullable)birthday completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  Modify user icon
 *
 *  @param iconPath          New user icon path,
 *  @param completionHandler Callback with modify result
 */
- (void)modifyUserIcon:(NSString *_Nonnull)iconPath completionHandler:(nullable void (^)(BLModifyUserIconResult * _Nonnull result))completionHandler;

/**
 *  Modify user nick name
 *
 *  @param nickname          New nickname
 *  @param completionHandler Callback with modify result
 */
- (void)modifyUserNickname:(NSString *_Nonnull)nickname completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  Query user info list
 *
 *  @param useridArray       User ids
 *  @param completionHandler Callback with query result
 */
- (void)getUserInfo:(NSArray<NSString *> *_Nonnull)useridArray completionHandler:(nullable void (^)(BLGetUserInfoResult * _Nonnull result))completionHandler;

/**
 Set password to fastlogin user
 
 @param phoneOrEmail        Phone or email
 @param countryCode         Phone country code. if Verification code send to email, this can be nil. (eg. 0086)
 @param vcode               Verification code
 @param password            Password
 @param completionHandler   Callback with set result
 */
- (void)setFastLoginPassword:(NSString *_Nonnull)phoneOrEmail countryCode:(NSString *_Nullable)countryCode vcode:(NSString *_Nonnull)vcode password:(NSString *_Nonnull)password completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 Send verification code to phone/email for set fastlogin user's password
 
 @param phoneOrEmail        Phone or email
 @param countryCode         Phone country code. if Verification code send to email, this can be nil. (eg. 0086)
 @param completionHandler   Callback with send result
 */
- (void)sendFastLoginPasswordVCode:(NSString *_Nonnull)phoneOrEmail countryCode:(NSString *_Nullable)countryCode completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  Modify user password
 *
 *  @param oldPassword       Old password
 *  @param newPassword       New password
 *  @param completionHandler Callback with modify result
 */
- (void)modifyPassword:(NSString *_Nonnull)oldPassword newPassword:(NSString *_Nonnull)newPassword completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  Send verification code to phone for modify password
 *
 *  @param phone             Phone
 *  @param countryCode       Phone country code. (eg. 0086)
 *  @param completionHandler Callback with send result
 */
- (void)sendModifyVCode:(NSString *_Nonnull)phone countryCode:(NSString *_Nonnull)countryCode completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  Send verification code to email for modify password
 *
 *  @param email             Email
 *  @param completionHandler Callback with send result
 */
- (void)sendModifyVCode:(NSString *_Nonnull)email completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  Modify user register phone
 *
 *  @param phone             Phone
 *  @param countryCode       Phone country code.  (eg. 0086)
 *  @param vcode             Verification code
 *  @param password          Password
 *  @param completionHandler Callback with modify result
 */
- (void)modifyPhone:(NSString *_Nonnull)phone countryCode:(NSString *_Nonnull)countryCode vcode:(NSString *_Nonnull)vcode password:(NSString *_Nonnull)password newpassword:(NSString *_Nonnull)newpassword completionHandler:(nullable void (^)(BLBaseResult *_Nonnull result))completionHandler;

/**
 *  Modify user register email
 *
 *  @param email             Email
 *  @param vcode             Verification code
 *  @param password          Password
 *  @param completionHandler Callback with modify result
 */
-(void)modifyEmail:(NSString *_Nonnull)email vcode:(NSString *_Nonnull)vcode password:(NSString *_Nonnull)password newpassword:(NSString *_Nonnull)newpassword completionHandler:(nullable void (^)(BLBaseResult *_Nonnull result))completionHandler;

/**
 *  Send verification code to phone/email for reset password
 *
 *  @param username          Phone or email
 *  @param completionHandler Callback with send result
 */
- (void)sendRetriveVCode:(NSString *_Nonnull)username completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  Reset password
 *
 *  @param username          Phone or email
 *  @param vcode             Verification code
 *  @param password          New password
 *  @param completionHandler Callback with reset password result
 */
- (void)retrivePassword:(NSString *_Nonnull)username vcode:(NSString *_Nonnull)vcode newPassword:(NSString *_Nonnull)password completionHandler:(nullable void (^)(BLLoginResult * _Nonnull result))completionHandler;

/**
 *  Check password is right or not
 *
 *  @param password          Password
 *  @param completionHandler Callback with check password result
 */
- (void)checkUserPassword:(NSString *_Nonnull)password completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 *  Query user phone and email
 *
 *  @param completionHandler Callback with query result
 */
- (void)getUserPhoneAndEmailWithCompletionHandler:(nullable void (^)(BLGetUserPhoneAndEmailResult * _Nonnull result))completionHandler;

/**
 Determine whether the login expires
 
 @param status error number
 @return is login expired
 */
- (BOOL)isLoginExpired:(NSInteger)status;

/**
 Query all bind infos with login account

 @param completionHandler bind infos
 */
- (void)queryOauthBindInfo:(nullable void (^)(BLBindInfoResult * _Nonnull result))completionHandler;

/**
 Bind Oatuh Account To Broadlink account

 @param thirdType Third company name - like "facebook"
 @param thirdID Open id by Oauth
 @param accesstoken Token by Oauth
 @param topSign topsign by Oauth,can be null
 @param completionHandler bind result
 */
- (void)bindOauthAccount:(NSString *_Nonnull)thirdType thirdID:(NSString *_Nonnull)thirdID accesstoken:(NSString *_Nonnull)accesstoken topSign:(NSString *_Nonnull)topSign completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 Unbind Oauth Account from BroadLink account

 @param thirdType Third company name - like "facebook"
 @param thirdID Open id by Oauth
 @param topSign topsign by Oauth,can be null
 @param completionHandler unbind result
 */
- (void)unbindOauthAccount:(NSString *_Nonnull)thirdType thirdID:(NSString *_Nonnull)thirdID topSign:(NSString *_Nonnull)topSign completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 destroy Send verification code
 
 @param phoneOrEmail phoneOrEmail
 @param countryCode countryCode
 @param completionHandler send verification code result
 */
- (void)sendDestroyCodeWithPhoneOrEmail:(NSString *)phoneOrEmail countryCode:(NSString *)countryCode completionHandler:(void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 destroyAccount
 
 @param phoneOrEmail phoneOrEmail
 @param countryCode countryCode
 @param vcode vcode
 @param completionHandler destroy result
 */
- (void)destroyAccountWithPhoneOrEmail:(NSString *)phoneOrEmail countryCode:(NSString *)countryCode vcode:(NSString *)vcode completionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;

/**
 destroyUnBindAccount
 
 @param completionHandler destroy result
 */
- (void)destroyUnBindAccountCompletionHandler:(nullable void (^)(BLBaseResult * _Nonnull result))completionHandler;
@end

