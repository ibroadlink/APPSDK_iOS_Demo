//
//  ModifyUserNicknameParam.m
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "ModifyUserNicknameParam.h"

@interface ModifyUserNicknameParam ()



@end

@implementation ModifyUserNicknameParam

- (instancetype)init
{
    return [self initWithNickname:nil];
}

- (instancetype)initWithNickname:(NSString *)nickname
{
    self = [super init];
    if (self) {
        if (nickname == nil)
            _nickname = @"";
        else
            _nickname = nickname;
    }
    
    return self;
}
@end
