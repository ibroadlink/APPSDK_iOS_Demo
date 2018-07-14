//
//  SendVCodeParam.h
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendVCodeParam : NSObject

/**
 *  手机号码或邮箱地址
 */
@property (nonatomic, strong, getter=getPhoneNumberOrEmail) NSString *phoneNumberOrEmail;

/**
 *  国家区域号
 */
@property (nonatomic, strong, getter=getCountryCode) NSString *countryCode;

/**
 *  初始化并设置邮箱地址
 *
 *  @param email 邮箱地址
 *
 *  @return 实例化
 */
- (instancetype)initWithEmail:(NSString *)email;

/**
 *  初始化并设置手机号码以及手机号码所在国家区域号
 *
 *  @param phoneNumber 手机号码
 *  @param countryCode 国家区域号
 *
 *  @return 实例化
 */
- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber
                        countryCode:(NSString *)countryCode;


@end
