//
//  RetrivePasswordParam.h
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RetrivePasswordParam : NSObject

/**
 *  用户名
 */
@property (nonatomic, strong, getter=getUsername) NSString *username;

/**
 *  国家区域号
 */
@property (nonatomic, strong, getter=getCountryCode) NSString *countryCode;

/**
 *  验证码
 */
@property (nonatomic, strong, getter=getVCode) NSString *vCode;

/**
 *  新密码
 */
@property (nonatomic, strong, getter=getPassword) NSString *password;


/**
 *  初始化并设置用户名等信息
 *
 *  @param username    用户名
 *  @param countryCode 手机号码所在国家区域号
 *  @param vCode       验证码
 *  @param password    新密码
 *
 *  @return 实例化
 */
- (instancetype)initWithUsername:(NSString *)username
                     countryCode:(NSString *)countryCode
                           vCode:(NSString *)vCode
                        password:(NSString *)password;

@end
