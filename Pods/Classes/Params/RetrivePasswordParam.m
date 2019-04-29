//
//  RetrivePasswordParam.m
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "RetrivePasswordParam.h"

@interface RetrivePasswordParam ()

@end

@implementation RetrivePasswordParam

- (instancetype)init
{
    return [self initWithUsername:nil countryCode:nil vCode:nil password:nil];
}

- (instancetype)initWithUsername:(NSString *)username countryCode:(NSString *)countryCode vCode:(NSString *)vCode password:(NSString *)password
{
    self = [super init];
    if (self) {
        if (username == nil)
            _username = @"";
        else
            _username = username;
        
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
    }
    
    return self;
}
@end
