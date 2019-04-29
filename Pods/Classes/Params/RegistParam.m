//
//  RegistParam.m
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "RegistParam.h"

@implementation RegistParam

- (instancetype)init
{
    self = [super init];
    if (self) {
        _username = @"";
        _password = @"";
        _nickname = @"";
        _country = @"";
        _countryCode = @"";
        _sex = @"male";
        _iconpath = @"";
        _code = @"";
    }
    
    return self;
}
@end
