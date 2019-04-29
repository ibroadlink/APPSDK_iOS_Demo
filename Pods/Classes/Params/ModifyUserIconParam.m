//
//  ModifyUserIconParam.m
//  Let
//
//  Created by yzm on 16/5/18.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "ModifyUserIconParam.h"

@implementation ModifyUserIconParam

- (instancetype)init
{
    return [self initWithIconPath:nil];
}

- (instancetype)initWithIconPath:(NSString *)iconPath
{
    self = [super init];
    if (self) {
        if (iconPath == nil)
            _iconPath = @"";
        else
            _iconPath = iconPath;
    }
    
    return self;
}
@end
