//
//  ModifyPasswordParam.m
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "ModifyPasswordParam.h"
@implementation ModifyPasswordParam

- (instancetype)init
{
    return [self initWithNewPassword:nil oldPassword:nil];
}

- (instancetype)initWithNewPassword:(NSString *)theNewPassword oldPassword:(NSString *)theOldPassword
{
    self = [super init];
    if (self) {
        if (theNewPassword == nil)
            _theNewPassword = @"";
        else
            _theNewPassword = theNewPassword;
        
        if (theOldPassword == nil)
            _theOldPassword = @"";
        else
            _theOldPassword = theOldPassword;
    }
    
    return self;
}
@end
