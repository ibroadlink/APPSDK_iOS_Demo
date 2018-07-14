//
//  LoginParam.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginParam : NSObject

/**
 用户名
 */
@property (nonatomic, strong, readonly) NSString *username;

/**
 密码
 */
@property (nonatomic, strong, readonly) NSString *password;

/**
 *  初始化登录用户名及密码
 *
 *  @param username 用户名
 *  @param password 密码
 *
 *  @return LoginParam
 */
- (instancetype)initLoginParam:(NSString *)username password:(NSString *)password;

@end
