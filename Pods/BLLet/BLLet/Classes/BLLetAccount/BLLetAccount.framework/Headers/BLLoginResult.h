//
//  LoginResult.h
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLLoginResult : BLBaseResult

/**
 user nickname
 */
@property (nonatomic, strong, getter=getNickname) NSString *nickname;

/**
 user icon store url
 */
@property (nonatomic, strong, getter=getIconpath) NSString *iconpath;

/**
 login success, return login session
 */
@property (nonatomic, strong, getter=getLoginsession) NSString *loginsession;

/**
 login success, return user id
 */
@property (nonatomic, strong, getter=getUserid) NSString *userid;

/**
 user ip address
 */
@property (nonatomic, strong, getter=getLoginip) NSString *loginip;

/**
 user login time
 */
@property (nonatomic, strong, getter=getLogintime) NSString *logintime;

/** 
 user gender
 */
@property (nonatomic, strong, getter=getSex) NSString *sex;

/** 
 user birthday
 */
@property (nonatomic, strong) NSString *birthday;

/**
 user company ID
 */
@property (nonatomic, strong) NSString *companyid;

/**
 first name
 */
@property (nonatomic, strong) NSString *fname;

/**
 last name
 */
@property (nonatomic, strong) NSString *lname;

/**
 user type
 */
@property (nonatomic, strong) NSString *usertype;

/**
 user phone country code. eg. 0086--China
 */
@property (nonatomic, strong) NSString *countrycode;

/**
 user phone
 */
@property (nonatomic, strong) NSString *phone;

/**
 user email
 */
@property (nonatomic, strong) NSString *email;

/**
 is user password setted or not
 */
@property (nonatomic, assign) NSInteger pwdflag;

/**
 flag
 */
@property (nonatomic, assign) NSInteger flag;
@end
