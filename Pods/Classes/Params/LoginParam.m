//
//  LoginParam.m
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "LoginParam.h"

@implementation LoginParam

- (instancetype)initLoginParam:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        _username = username;
        _password = password;
    }
    
    return self;
}

@end
