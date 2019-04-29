//
//  ModifyPhoneOrEmailParam.m
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "ModifyPhoneOrEmailParam.h"

@interface ModifyPhoneOrEmailParam ()


@end

@implementation ModifyPhoneOrEmailParam

- (instancetype)init
{
    return [self initWithPhoneNumber:nil countryCode:nil vCode:nil password:nil newpassword:nil];
}

- (instancetype)initWithEmail:(NSString *)email vCode:(NSString *)vCode password:(NSString *)password newpassword:(NSString *)newpassword
{
    return [self initWithPhoneNumber:email countryCode:nil vCode:vCode password:password newpassword:newpassword];
}

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode vCode:(NSString *)vCode password:(NSString *)password newpassword:(NSString *)newpassword
{
    self = [super init];
    if (self) {
        if (phoneNumber == nil)
            _phoneOrEmail = @"";
        else
            _phoneOrEmail = phoneNumber;
        
        if (countryCode == nil)
            _countryCode = @"";
        else
            _countryCode = countryCode;
        
        if (vCode == nil)
            _vCode = @"";
        else
            _vCode = vCode;
        
        if (password == nil)
            _password = @"";
        else
            _password = password;
        
        if (newpassword == nil)
            _newpassword = @"";
        else
            _newpassword = newpassword;
    }
    
    return self;
}
@end
