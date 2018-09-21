//
//  ModifyPhoneOrEmailParam.h
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModifyPhoneOrEmailParam : NSObject

/**
 *  手机号码或邮箱地址
 */
@property (nonatomic, strong, getter=getPhoneOrEmail) NSString *phoneOrEmail;

/**
 *  手机号码所在国家区域号
 */
@property (nonatomic, strong, getter=getCountryCode) NSString *countryCode;

/**
 *  验证码
 */
@property (nonatomic, strong, getter=getVCode) NSString *vCode;

/**
 *  账户密码
 */
@property (nonatomic, strong, getter=getPassword) NSString *password;

/**
 *  新的账户密码
 */
@property (nonatomic, strong, getter=getnewPassword) NSString *newpassword;


/**
 *  初始化并设置手机号码以及其国家区域号
 *
 *  @param phoneNumber 手机号码
 *  @param countryCode 手机号码所在国家区域号
 *  @param vCode       手机验证码
 *  @param password    账户密码
 *
 *  @return 实例化
 */
- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
                        countryCode:(NSString *)countryCode
                              vCode:(NSString *)vCode
                           password:(NSString *)password
                        newpassword:(NSString *)newpassword;

/**
 *  初始化并设置邮箱地址
 *
 *  @param email    邮箱地址
 *  @param vCode    邮箱验证码
 *  @param password 账户密码
 *
 *  @return 实例化
 */
- (instancetype)initWithEmail:(NSString *)email
                        vCode:(NSString *)vCode
                     password:(NSString *)password
                  newpassword:(NSString *)newpassword;

@end
