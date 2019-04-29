//
//  GetUserPhoneAndEmailResult.m
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLGetUserPhoneAndEmailResult.h"

@implementation BLGetUserPhoneAndEmailResult

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userid = @"";
        self.email = @"";
        self.phone = @"";
    }
    
    return self;
}

@end
