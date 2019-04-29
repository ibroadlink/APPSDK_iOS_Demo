//
//  SendVCodeParam.m
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "SendVCodeParam.h"

@implementation SendVCodeParam

- (instancetype)init
{
    return [self initWithPhoneNumber:nil countryCode:nil];
}

- (instancetype)initWithEmail:(NSString *)email
{
    return [self initWithPhoneNumber:email countryCode:nil];
}

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode
{
    self = [super init];
    if (self) {
        if (phoneNumber == nil)
            _phoneNumberOrEmail = @"";
        else
            _phoneNumberOrEmail = phoneNumber;
        
        if (countryCode == nil)
            _countryCode = @"";
        else
            _countryCode = countryCode;
    }
    
    return self;
}
@end
