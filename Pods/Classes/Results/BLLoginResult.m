//
//  LoginResult.m
//  Let
//
//  Created by yzm on 16/5/13.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLLoginResult.h"

@implementation BLLoginResult

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nickname = @"";
        self.iconpath = @"";
        self.loginsession = @"";
        self.userid = @"";
        self.loginip = @"";
        self.logintime = @"";
        self.sex = @"";
        self.birthday = @"";
    }
    
    return self;
}

@end
