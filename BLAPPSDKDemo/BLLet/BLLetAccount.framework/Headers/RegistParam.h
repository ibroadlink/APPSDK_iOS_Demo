//
//  RegistParam.h
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegistParam : NSObject


/**
 *  用户名
 */
@property (nonatomic, strong, getter=getUsername) NSString *username;

/**
 *  密码
 */
@property (nonatomic, strong, getter=getPassword) NSString *password;

/**
 *  昵称
 */
@property (nonatomic, strong, getter=getNickname) NSString *nickname;

/**
 *  国家
 */
@property (nonatomic, strong, getter=getCountry) NSString *country;

/**
 *  国家区域码
 */
@property (nonatomic, strong, getter=getCountryCode) NSString *countryCode;

/**
 *  用户性别
 */
@property (nonatomic, strong, getter=getSex) NSString *sex;

/**
 用户生日
 */
@property (nonatomic, strong, getter=getBirthday) NSString *birthday;

/**
 *  用户头像路径
 */
@property (nonatomic, strong, getter=getIconpath) NSString *iconpath;

/**
 *
 */
@property (nonatomic, strong, getter=getCode) NSString *code;

@end
